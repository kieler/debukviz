package de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.HorizontalAlignment
import de.cau.cs.kieler.core.krendering.KContainerRendering
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

class LNodeTransformation extends AbstractKielerGraphTransformation {

	@Inject 
    extension KNodeExtensions
    @Inject 
    extension KPolylineExtensions 
    @Inject
    extension KRenderingExtensions
    @Inject
    extension KLabelExtensions
    
    val layoutAlgorithm = "de.cau.cs.kieler.kiml.ogdf.planarization"
    val spacing = 75f
    val leftColumnAlignment = HorizontalAlignment::RIGHT
    val rightColumnAlignment = HorizontalAlignment::LEFT

    val showPropertyMap = ShowTextIf::DETAILED
    val showPorts = ShowTextIf::DETAILED

    val showSize = ShowTextIf::DETAILED
    val showPos = ShowTextIf::DETAILED
    val showMargin = ShowTextIf::DETAILED
    val showInsets = ShowTextIf::DETAILED
    val showOwner = ShowTextIf::DETAILED
    val showID = ShowTextIf::ALWAYS
    val showHashCode = ShowTextIf::ALWAYS
    val showPortsCount = ShowTextIf::COMPACT
    val showLabelsCount = ShowTextIf::COMPACT
    
    /**
     * {@inheritDoc}
     */
    override transform(IVariable node, Object transformationInfo) {
        detailedView = transformationInfo.isDetailed
        
        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            it.addLayoutParam(LayoutOptions::SPACING, spacing)

			it.addInvisibleRendering
            it.addHeaderNode(node)
            
            // addpropertymap
            if(showPropertyMap.conditionalShow(detailedView))
                it.addPropertyMapNode(node.getVariable("propertyMap"), node)
                
            //add node for ports
            if(showPorts.conditionalShow(detailedView))
                it.addPorts(node)
        ]
    }

	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
	    var retVal = if(showPropertyMap.conditionalShow(detailedView)) 2 else 1
	    if(showPorts.conditionalShow(detailedView)) retVal = retVal + 1
		return retVal
	}
    
    def addHeaderNode(KNode rootNode, IVariable node) {
        rootNode.addNodeById(node) => [
            // Get the nodeType
            val nodeType = node.nodeType
            var KContainerRendering container

            val table = container.headerNodeBasics(detailedView, node)
            
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
                    val origin = node.getVariable("propertyMap").getValFromHashMap("origin")
                    table.addGridElement("origin:", leftColumnAlignment) 
                    if (nodeType == "NORTH_SOUTH_PORT" && origin.getType == "LNode") {
                        table.addGridElement("" + origin.getVariable("labels").linkedList.get(0), rightColumnAlignment) 
                    } else {
                        table.addGridElement("" + origin.nullOrTypeAndID(""), rightColumnAlignment) 
                    }
                ]
            }

            container.setForegroundColor(node)

            // Name of the node is the first label
            val labels = node.getVariable("labels").linkedList
            var labelText = ""
            if(labels.isEmpty) {
                // no name given
                labelText = "(null)"
            } else {
                val label = labels.get(0).getValue("text")
                if(label.length == 0) {
                    labelText = "(empty String)"
                } else {
                    labelText = label
                }
            }
            if(!detailedView) {
                labelText = labelText + node.getValueString
            }
            table.addGridElement("name:", leftColumnAlignment) 
            table.addGridElement(labelText, leftColumnAlignment) 

            // id of node
            if(showID.conditionalShow(detailedView)) {
                table.addGridElement("id:", leftColumnAlignment) 
                table.addGridElement(node.nullOrValue("id"), rightColumnAlignment) 
            }

            //owner (layer)
            if(showOwner.conditionalShow(detailedView)) {
                table.addGridElement("owner:", leftColumnAlignment) 
                table.addGridElement(node.nullOrTypeAndID("owner"), rightColumnAlignment) 
            }

            // hashCode of node
            if(showHashCode.conditionalShow(detailedView)) {
                table.addGridElement("hashCode:", leftColumnAlignment) 
                table.addGridElement(node.nullOrValue("hashCode"), rightColumnAlignment) 
            }

            // insets
            if(showInsets.conditionalShow(detailedView)) {
                table.addGridElement("insets (b,l,r,t):", leftColumnAlignment) 
                table.addGridElement(node.nullOrLInsets("insets"), rightColumnAlignment)
            }
                
            //margin
            if(showMargin.conditionalShow(detailedView)) {
                table.addGridElement("margin (b,l,r,t):", leftColumnAlignment) 
                table.addGridElement(node.nullOrLInsets("margin"), rightColumnAlignment)
            }

            // position
            if(showPos.conditionalShow(detailedView)) {
                table.addGridElement("pos (x,y):", leftColumnAlignment) 
                table.addGridElement(node.nullOrKVektor("pos"), rightColumnAlignment)
            }
                
            // size
            if(showSize.conditionalShow(detailedView)) {
                table.addGridElement("size (x,y):", leftColumnAlignment) 
                table.addGridElement(node.nullOrKVektor("size"), rightColumnAlignment)
            }

            // # of labels
            if(showLabelsCount.conditionalShow(detailedView)) {
                table.addGridElement("labels (#):", leftColumnAlignment) 
                table.addGridElement(node.nullOrSize("labels"), rightColumnAlignment) 
            }

            // # of ports
            if(showPortsCount.conditionalShow(detailedView)) {
                table.addGridElement("ports (#):", leftColumnAlignment) 
                table.addGridElement(node.nullOrValue("ports"), rightColumnAlignment) 
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
                it.nextTransformation(port, false)
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