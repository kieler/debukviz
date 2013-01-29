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

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions

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

    /**
     * {@inheritDoc}
     */
    override transform(IVariable node, Object transformationInfo) {
        if(transformationInfo instanceof Boolean) {
            detailedView = transformationInfo as Boolean
        }
println("LNode detailedView: " +detailedView)
        
        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            
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
        rootNode.addNewNodeById(node) => [
            // Get the nodeType
            val nodeType = node.nodeType

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
                        it.children += renderingFactory.createKText => [
                            val origin = node.getVariable("propertyMap").getValFromHashMap("origin")
                            if (origin.getType == "LNode") {
                                it.children += renderingFactory.createKText => [
                                    it.setText("Origin: " + origin.getVariable("labels").linkedList.get(0))
                                ]   
                            }
                        ]
                    }
                ]
            }

            if(detailedView) container.lineWidth = 4 else container.lineWidth = 2
            container.setForegroundColor(node)
            container.ChildPlacement = renderingFactory.createKGridPlacement

            if(detailedView){
                // Type of node
                container.addShortType(node)                

                // name of the variable
                container.children += renderingFactory.createKText => [
                    it.text = "VarName: " + node.name 
                ]
            }


            // Name of the node is the first label
            container.children += renderingFactory.createKText => [
            val labels = node.getVariable("labels").linkedList
                if(labels.isEmpty) {
                    // no name given, so display the node id instead
                    it.setText("name (first label): -")
                } else {
                    val label = labels.get(0).getValue("text")
                    if(label.length == 0) {
                        it.setText("name (first label): (empty)")
                    } else {
                        it.setText("name (first label): " + label)
                    }
                }
            ]
            
            // id of node
            container.children += createKText(node, "id", "", ": ") 

            // hashCode of node
            container.children += createKText(node, "hashCode", "", ": ")

            // following data only if detailedView
            if(detailedView) {
                // insets
                container.children += renderingFactory.createKText => [
                    it.text = "insets (b,l,r,t): (" + node.getValue("insets.bottom").round(1) + " x "
                                                    + node.getValue("insets.left").round(1) + " x "
                                                    + node.getValue("insets.right").round(1) + " x "
                                                    + node.getValue("insets.top").round(1) + ")" 
                ]
                
                //margin
                container.children += renderingFactory.createKText => [
                    it.text = "margin (b,l,r,t): (" + node.getValue("margin.bottom").round(1) + " x "
                                                    + node.getValue("margin.left").round(1) + " x "
                                                    + node.getValue("margin.right").round(1) + " x "
                                                    + node.getValue("margin.top").round(1) + ")" 
                ]
    
                //owner (layer)
                container.children += renderingFactory.createKText => [
                    it.text = "owner: layer(" + node.getValue("owner.id") + ")"
                ]
    
                // position
                container.children += renderingFactory.createKText => [
                    it.text = "pos (x,y): (" + node.getValue("pos.x").round(1) + " x " 
                                                  + node.getValue("pos.y").round(1) + ")" 
                ]
            
                // size
                container.children += renderingFactory.createKText => [
                    it.text = "size (x,y): (" + node.getValue("size.x").round(1) + " x " 
                                              + node.getValue("size.y").round(1) + ")" 
                ]
            } else {
                // # of labels
                container.children += renderingFactory.createKText => [
                    it.text = "labels (#): " + node.getValue("labels.size")
                ]

                // # of ports
                container.children += renderingFactory.createKText => [
                    it.text = "ports (#): " + node.getValue("ports.size")
                ]
                
            }
            
            // add the node-symbol to the surrounding KNode
            it.data += container
        ]
    }
    
    def addPorts(KNode rootNode, IVariable node) {
        // create a node (ports) containing the port elements
        val ports = node.getVariable("ports")
        rootNode.addNewNodeById(ports) => [
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
            KimlUtil::createInitializedLabel(it) => [
                it.setText("ports")
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