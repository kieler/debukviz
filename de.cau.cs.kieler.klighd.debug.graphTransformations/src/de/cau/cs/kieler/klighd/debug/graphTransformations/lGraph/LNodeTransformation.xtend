package de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph

import de.cau.cs.kieler.core.krendering.KContainerRendering
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.LayoutOptions

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.klighd.debug.graphTransformations.KTextIterableField

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

class LNodeTransformation extends AbstractKielerGraphTransformation {

	@Inject 
    extension KNodeExtensions
	@Inject 
    extension KEdgeExtensions
    @Inject 
    extension KPolylineExtensions 
    @Inject
    extension KRenderingExtensions
	@Inject 
    extension KColorExtensions
    @Inject
    extension KLabelExtensions
    
    val layoutAlgorithm = "de.cau.cs.kieler.kiml.ogdf.planarization"
    val spacing = 75f
    val leftColumnAlignment = KTextIterableField$TextAlignment::RIGHT
    val rightColumnAlignment = KTextIterableField$TextAlignment::LEFT
    val topGap = 4
    val rightGap = 5
    val bottomGap = 5
    val leftGap = 4
    val vGap = 3
    val hGap = 5
    
    /**
     * {@inheritDoc}
     */
    override transform(IVariable node, Object transformationInfo) {
        if(transformationInfo instanceof Boolean) detailedView = transformationInfo as Boolean
        
        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            it.addLayoutParam(LayoutOptions::SPACING, spacing)
            
            // create KNode for given LNode
            it.createHeaderNode(node)
            
            // add nodes for propertymap and ports, if in detailed mode
            if (detailedView) {
                // addpropertymap
                it.addPropertyMapAndEdge(node.getVariable("propertyMap"), node)
                
                //add node for ports
                it.addPorts(node)
            }        
        ]
    }
    
    def createHeaderNode(KNode rootNode, IVariable node) {
        rootNode.addNodeById(node) => [
            // Get the nodeType
            val nodeType = node.nodeType

            val field = new KTextIterableField(topGap, rightGap, bottomGap, leftGap, vGap, hGap)

            var KContainerRendering container
            
            if (nodeType == "NORMAL" ) {
                /*
                 * Normal nodes. (If nodeType is null, the default type is taken, which is "NORMAL")
                 *  - are represented by an rectangle  
                 */ 
                 container = renderingFactory.createKRectangle
            } else {
                /*
                 * Dummy nodes.
                 *  - are represented by an ellipses
                 *  - if they are a "NORTH_SOUTH_PORT"-node, and the origin is a LNode:
                 *    add first label of origin as text
                 */
                container = renderingFactory.createKEllipse => [
                    if (nodeType == "NORTH_SOUTH_PORT") {
                        val origin = node.getVariable("propertyMap").getValFromHashMap("origin")
                        if (origin.getType == "LNode") {
                            field.set("origin:", 0, 0, leftColumnAlignment)
//TODO: dass stimmt hier nocht nicht!!!!
                            field.set("" + origin.getVariable("labels").linkedList.get(0), 0, 1, rightColumnAlignment)
                        }
                    }
                ]
            }

            container.headerNodeBasics(field, detailedView, node, leftColumnAlignment, rightColumnAlignment)
            var row = field.rowCount

            container.setForegroundColor(node)

            // Name of the node is the first label
            field.set("name:", row, 0, leftColumnAlignment)
            val labels = node.getVariable("labels").linkedList
            var labelText = ""
            if(labels.isEmpty) {
                // no name given
                labelText = "-"
            } else {
                val label = labels.get(0).getValue("text")
                if(label.length == 0) {
                    labelText = "(empty)"
                } else {
                    labelText = label
                }
            }
            field.set(labelText, row, 1, rightColumnAlignment)
            row = row + 1

            // id of node
            field.set("id:", row, 0, leftColumnAlignment)
            field.set(nullOrValue(node, "id"), row, 1, rightColumnAlignment)
            row = row + 1

            //owner (layer)
            field.set("owner:", row, 0, leftColumnAlignment)
            field.set("layer (" + node.getValue("owner.hashCode") + ")", row, 1, rightColumnAlignment)
            row = row + 1

            // following data only if detailedView
            if(detailedView) {
	            // hashCode of node
	            field.set("hashCode:", row, 0, leftColumnAlignment)
	            field.set(nullOrValue(node, "hashCode"), row, 1, rightColumnAlignment)
	            row = row + 1

                // insets
                field.set("insets (b,l,r,t):", row, 0, leftColumnAlignment)
                field.set("(" + node.getValue("insets.bottom").round + " x "
                              + node.getValue("insets.left").round + " x "
                              + node.getValue("insets.right").round + " x "
                              + node.getValue("insets.top").round + ")", row, 1, rightColumnAlignment)
                row = row + 1
                
                //margin
                field.set("margin (b,l,r,t):", row, 0, leftColumnAlignment)
                field.set("(" + node.getValue("margin.bottom").round + " x "
                              + node.getValue("margin.left").round + " x "
                              + node.getValue("margin.right").round + " x "
                              + node.getValue("margin.top").round + ")", row, 1, rightColumnAlignment)
                row = row + 1

                // position
                field.set("pos (x,y):", row, 0, leftColumnAlignment)
                field.set("(" + node.getValue("pos.x").round + " x " 
                              + node.getValue("pos.y").round + ")", row, 1, rightColumnAlignment)
                row = row + 1
                
                // size
                field.set("size (x,y):", row, 0, leftColumnAlignment)
                field.set("(" + node.getValue("size.x").round + " x " 
                              + node.getValue("size.y").round + ")", row, 1, rightColumnAlignment)
                row = row + 1

            } else {
                // # of labels
                field.set("labels (#):", row, 0, leftColumnAlignment)
                field.set(node.getValue("labels.size"), row, 1, rightColumnAlignment)
                row = row + 1

                // # of ports
                field.set("ports (#):", row, 0, leftColumnAlignment)
                field.set(node.getValue("ports.size"), row, 1, rightColumnAlignment)
                row = row + 1
            }
            
            // fill the KText into the ContainerRendering
            for (text : field) {
                container.children += text
            }
            
            // add the node-symbol to the surrounding KNode
            it.data += container
        ]
    }
    
    def addPorts(KNode rootNode, IVariable node) {
        // create a node (ports) containing the port elements
        val ports = node.getVariable("ports")
        rootNode.addNodeById(ports) => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
            ]
            // create all ports
            ports.linkedList.forEach [ port |
                it.children += nextTransformation(port, false)
            ]
        ]
        // create edge from header node to ports node
        node.createEdgeById(ports) => [
            it.data += renderingFactory.createKPolyline => [
                it.setLineWidth(2)
                it.addArrowDecorator
            ]
            ports.createLabel(it) => [
                it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::CENTER)
                it.setLabelSize(50,20)
                it.text = "ports"
            ]
        ]   
    }
    
    def setForegroundColor(KContainerRendering rendering, IVariable node) {
       /*
        *  original values from de.cau.cs.kieler.klay.layered.properties.NodeType:
        *  case "COMPOUND_SIDE": return "#808080"
        *  case "EXTERNAL_PORT": return "#cc99cc"
        *  case "LONG_EDGE": return "#eaed00"
        *  case "NORTH_SOUTH_PORT": return "#0034de"
        *  case "LOWER_COMPOUND_BORDER": return "#18e748"
        *  case "LOWER_COMPOUND_PORT": return "#2f6d3e"
        *  case "UPPER_COMPOUND_BORDER": return "#fb0838"
        *  case "UPPER_COMPOUND_PORT": return "#b01d38"
        *  default: return "#000000"
        *  coding: #RGB", where each component is given as a two-digit hexadecimal value.
        */
        val type = node.nodeType
        switch (type) {
            case "COMPOUND_SIDE": rendering.setForegroundColor(128,128,128)
            case "EXTERNAL_PORT": rendering.setForegroundColor(204,153,204)
            case "LONG_EDGE": rendering.setForegroundColor(234,237,0)
            case "NORTH_SOUTH_PORT": rendering.setForegroundColor(0,52,222)
            case "LOWER_COMPOUND_BORDER": rendering.setForegroundColor(24,231,72)
            case "LOWER_COMPOUND_PORT": rendering.setForegroundColor(47,109,62)
            case "UPPER_COMPOUND_BORDER": rendering.setForegroundColor(251,8,56)
            case "UPPER_COMPOUND_PORT": rendering.setForegroundColor(176,29,56)
            default: return rendering.setForegroundColor(0,0,0)
        }
    }
    
    def getNodeType(IVariable node) {
    	val map =  node.getVariable("propertyMap")
        val type = map.getValFromHashMap("nodeType")
        if (type == null) {
            return "NORMAL"
        } else {
            return type.getValue("name")   
        }
    }
}