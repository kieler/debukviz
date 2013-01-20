package de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph

import de.cau.cs.kieler.core.krendering.KContainerRendering
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKNodeTransformation
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

class LNodeTransformation extends AbstractKNodeTransformation {

	@Inject 
    extension KNodeExtensions
	@Inject 
    extension KEdgeExtensions
	@Inject 
    extension KRenderingExtensions
	@Inject 
    extension KColorExtensions

    //TODO: create ports
    //TODO: add all labels

    /**
     * Creates a representation of a LNode
     * @param rootNode The KNode this node is placed into
     * @param variable The IVariable containing the data for this LNode
     */
     override transform(IVariable node) {
        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            it.children += node.createNode => [
				it.setNodeSize(120,80)
//                it.addLayoutParam(LayoutOptions::LABEL_SPACING, 75f)
//                it.addLayoutParam(LayoutOptions::SPACING, 75f)
                
                // Get the nodeType
                val nodeType = node.nodeType
                // Get the ports
                val ports = node.getVariable("ports").linkedList
                // Get the labels
                val labels = node.getVariable("labels").linkedList
                
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
                
                container.lineWidth = 2 
                container.setForegroundColor(node)
                container.ChildPlacement = renderingFactory.createKGridPlacement

                // Type of node
                container.children += renderingFactory.createKText => [
                    it.setForegroundColor(120,120,120)
                    it.text = node.ShortType
                ]

                // Name of the node is the first label
                container.children += renderingFactory.createKText => [
	                if(labels.isEmpty) {
                        // no name given, so display the node id instead
                        it.setText("name (first label): -")
                    } else {
                        it.setText("name (first label): " + labels.get(0).getValue("text"))
                    }
                ]
                
                // hashCode of node
                container.children += createKText(node, "hashCode", "", ": ")

                // id of node
                container.children += createKText(node, "id", "", ": ") 

                //insets
                container.children += renderingFactory.createKText => [
                    it.text = "insets (b,l,r,t): (" + node.getValue("insets.bottom").round(1) + " x "
								                    + node.getValue("insets.left").round(1) + " x "
								                    + node.getValue("insets.right").round(1) + " x "
								                    + node.getValue("insets.top").round(1) + ")" 
                ]
                
                //TODO: labels
                
                //margin
                container.children += renderingFactory.createKText => [
                    it.text = "margin (b,l,r,t): (" + node.getValue("margin.bottom").round(1) + " x "
								                    + node.getValue("margin.left").round(1) + " x "
								                    + node.getValue("margin.right").round(1) + " x "
								                    + node.getValue("margin.top").round(1) + ")" 
                ]
                //owner
                container.children += renderingFactory.createKText => [
                	it.text = "owner: layer(" + node.getValue("layer.id") + ")"
                ]
                //ports
                //pos
                //propertyMap
                //size
//                
//                    it.children += node.createKText("label", "", ": ")
//                    
//                    
//                    it.children += renderingFactory.createKText => [
//                        it.text = "position (x,y): (" + node.getValueByName("position.x").round(1) + " x " 
//                                                      + node.getValueByName("position.y").round(1) + ")" 
//                    ]
//                    
//                    it.children += renderingFactory.createKText => [
//                        it.text = "size (x,y): (" + node.getValueByName("size.x").round(1) + " x " 
//                                                  + node.getValueByName("size.y").round(1) + ")" 
//                    ]                
                // Layer # of node
                container.children += renderingFactory.createKText => [
                    it.setText("Layer: " + transformationInfo)
                ] 
                
                // add the node-symbol to the surrounding KNode
                it.data += container
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
        switch (node.getNodeType) {
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
        val type = node.getVariable("propertyMap").getValFromHashMap("nodeType")
        if (type == null) {
            return "NORMAL"
        } else {
            return type.getValue("name")   
        }
    }
}