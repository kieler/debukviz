package de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.KRenderingFactory
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph.LGraphTransformation.*
import javax.inject.Inject
import de.cau.cs.kieler.core.krendering.LineStyle
import de.cau.cs.kieler.core.properties.IProperty

class LGraphTransformation extends AbstractKNodeTransformation {
    
    @Inject
    extension KNodeExtensions
    @Inject
    extension KEdgeExtensions
    @Inject
    extension KRenderingExtensions
    @Inject
    extension KColorExtensions
    
    /**
     * {@inheritDoc}
     */
	override transform(IVariable graph) {
        return KimlUtil::createInitializedNode=> [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
      		it.createHeaderNode(graph)
      		it.createLayerlessNodes(graph.getVariableByName("layerlessNodes"))
      		it.createLayeredNodes(graph.getVariableByName("layers"))
      		it.createEdges(graph.getVariableByName("layerlessNodes"))
      		graph.getVariableByName("layers").linkedList.forEach[IVariable layer |
      			it.createEdges(layer)	
      		]
        ]

	}
	
	def createHeaderNode(KNode rootNode, IVariable graph) {
		rootNode.children += graph.createNode().putToKNodeMap(graph) => [
//		rootNode.children += graph.createNode().putToLookUpWith(variable) => [
//    		it.setNodeSize(120,80)
    		it.data += renderingFactory.createKRectangle() => [
    			it.lineWidth = 4
    			it.ChildPlacement = renderingFactory.createKGridPlacement()
    			
                it.children += renderingFactory.createKText() => [
                    it.setText("name: " + graph.name)
                ]
                
                it.children += renderingFactory.createKText() => [
                    it.setText("hashCode: " + graph.getValueByName("hashCode"))
                ]
    			
    			it.children += renderingFactory.createKText() => [
    				it.setText("size (x,y): (" + graph.getValueByName("size.x").round(1) + ", " 
    				                           + graph.getValueByName("size.y").round(1) + ")" 
                    )
            	]
    			
    			it.children += renderingFactory.createKText() => [
                	it.setText("insets (t,r,b,l): (" + graph.getValueByName("insets.top").round(1) + ", "
                	                                 + graph.getValueByName("insets.right").round(1) + ", "
                	                                 + graph.getValueByName("insets.bottom").round(1) + ", "
                	                                 + graph.getValueByName("insets.left").round(1) + ")"
                	)
            	]
    			
    			it.children += renderingFactory.createKText() => [
                	it.setText("offset (x,y): (" + graph.getValueByName("offset.x").round(1) + ", "
                	                             + graph.getValueByName("offset.y").round(1) + ")"
                	)
            	]
            ]
		]
	}

/*	
	def createLayerlessNodes(KNode rootNode, IVariable variable) {
	    variable.linkedList.forEach[IVariable node |
//            rootNode.children += node.createNode().putToKNodeMap(node) => [
            rootNode.children += node.createNode().putToLookUpWith(node) => [
            	it.nextTransformation(node, -1)
            ]
        ]
	}
*/

	def createLayerlessNodes(KNode rootNode, IVariable layerlessNodes) {
	    layerlessNodes.linkedList.forEach[IVariable node |
	    	rootNode.nextTransformation(node, -1)
        ]
	}
	
	def createLayeredNodes(KNode rootNode, IVariable layers) {
		var i = 0
		for (layer : layers.linkedList) {
			for (node : layer.getVariableByName("nodes").linkedList)
            	rootNode.nextTransformation(node, i)
			i = i+1
		}
	}

    def createEdges(KNode rootNode, IVariable layer) {
        layer.linkedList.forEach[IVariable node |
        	node.getVariableByName("ports").linkedList.forEach[IVariable port |
        		port.getVariableByName("outgoingEdges").linkedList.forEach[IVariable edge |
        			val source = edge.getVariableByName("source.owner")
        			val target = edge.getVariableByName("target.owner")
						println("Edge: " + source.getValue.getValueString + "->" + target.getValue.getValueString);
        			source.createEdge(target) => [ 
//        			edge.getVariableByName("source.owner").createEdge(edge.getVariableByName("target.owner")) => [
        				it.data += renderingFactory.createKPolyline() => [
	            		    it.setLineWidth(2)
	            		    if (edge.edgeType == "COMPOUND_DUMMY") {
		        				it.setLineStyle(LineStyle::DASH)
	            		    } else if (edge.edgeType == "COMPOUND_SIDE") {
        						it.setLineStyle(LineStyle::DOT)
	            		    } else {
	            		    	it.setLineStyle(LineStyle::SOLID)
	            		    }
    	    			]
        			]
        		]
        	]
        ]
    }
    
    def getEdgeType(IVariable edge) {
    	val type = edge.getVariableByName("propertyMap").getValFromHashMap("EDGE_TYPE")
    	if (type == null) {
	        return "NORMAL"
    	} else {
	        return type.getValueByName("name")   
    	}
    }
}