package de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.KRenderingFactory
import de.cau.cs.kieler.core.krendering.KContainerRendering

import static de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph.LNodeTransformation.*

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
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
//            it.children += variable.createNode().putToLookUpWith(variable) => [
        	println("KNode:" + node.getValue.getValueString)
            it.children += node.createNode().putToKNodeMap(node) => [
//                it.addLayoutParam(LayoutOptions::LABEL_SPACING, 75f)
//                it.addLayoutParam(LayoutOptions::SPACING, 75f)
                
                // Get the nodeType
                val nodeType = node.nodeType
                // Get the ports
                val ports = node.getVariableByName("ports").linkedList
                // Get the labels
                val labels = node.getVariableByName("labels").linkedList
                
                if (nodeType == "NORMAL" ) {
	                /*
	                 * Normal nodes. (If nodeType is null, the default type is taken, which is "NORMAL")
	                 *  - show their name (if set) or their node ID
	                 *  - are represented by an rectangle  
	                 */ 
                    it.data += renderingFactory.createKRectangle => [
                    	it.lineWidth = 2 
                        it.setBackgroundColor(node)
                        it.ChildPlacement = renderingFactory.createKGridPlacement                    
                        
                        // Name of the node is the first label
                        it.children += renderingFactory.createKText => [
                            if(labels.isEmpty) {
                                // no name given
                                it.setText("name: -")
                            } else {
                                it.setText("name: " + labels.get(0).getValueByName("text"))
                            }
                        ]
                        it.children += renderingFactory.createKText => [
                           it.setText("Layer: " + transformationInfo)
                        ] 
                    ]
                } else {
                    /*
                     * Dummy nodes.
                     *  - show their name (if set) or their node ID
                     *  - are represented by an ellipses  
                     */
                    it.data += renderingFactory.createKEllipse => [
                        it.lineWidth = 2
                        it.setBackgroundColor(node)
                        it.ChildPlacement = renderingFactory.createKGridPlacement
                        // Name of the node is the first label
                        it.children += renderingFactory.createKText => [
                            if(labels.isEmpty) {
                                // no name given, so display the node id instead
                                it.setText("nodeID: " + node.getValueByName("id"))
                            } else {
                                it.setText("name: " + labels.get(0).getValueByName("text"))
                            }
	                        it.children += renderingFactory.createKText => [
	                           it.setText("Layer: " + transformationInfo)
	                        ] 
                            if (nodeType == "NORTH_SOUTH_PORT") {
                                val origin = node.getVariableByName("propertyMap").getValFromHashMap("origin")
                                if (origin.getType == "LNode") {
                                    it.children += renderingFactory.createKText => [
                                        it.setText("Origin: " + origin.getVariableByName("labels").linkedList.get(0))
                                    ]   
                                }
                            }
                        ]
                    ]
                }
            ]
        ]
    }
    
    def setBackgroundColor(KContainerRendering rendering, IVariable node) {
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
        val type = node.getVariableByName("propertyMap").getValFromHashMap("nodeType")
        if (type == null) {
            return "NORMAL"
        } else {
            return type.getValueByName("name")   
        }
    }
}