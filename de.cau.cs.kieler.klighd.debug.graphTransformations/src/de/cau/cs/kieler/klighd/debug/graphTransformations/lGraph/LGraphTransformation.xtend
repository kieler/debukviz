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
    
    
    private static val KRenderingFactory renderingFactory = KRenderingFactory::eINSTANCE

    /**
     * {@inheritDoc}
     */
	override transform(IVariable variable) {
        return KimlUtil::createInitializedNode=> [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
      		it.createHeaderNode(variable)
      		it.createLayerlessNodes(variable.getVariableByName("layerlessNodes"))
      		it.createLayeredNodes(variable.getVariableByName("layers"))
      		it.createEdges(variable.getVariableByName("layerlessNodes"))
      		variable.getVariableByName("layers").linkedList.forEach[IVariable layer |
      			it.createEdges(layer)	
      		]
        ]

	}
	
	def createHeaderNode(KNode rootNode, IVariable variable) {
		rootNode.children += variable.createNode().putToLookUpWith(variable) => [
//    		it.setNodeSize(120,80)
    		it.data += renderingFactory.createKRectangle() => [
    			it.lineWidth = 4
    			it.ChildPlacement = renderingFactory.createKGridPlacement()
    			
                it.children += renderingFactory.createKText() => [
                    it.setText("name: " + variable.name)
                ]
                
                it.children += renderingFactory.createKText() => [
                    it.setText("hashCode: " + variable.getValueByName("hashCode"))
                ]
    			
    			it.children += renderingFactory.createKText() => [
    				it.setText("size (x,y): (" + variable.getValueByName("size.x").roundTo(1) + ", " 
    				                           + variable.getValueByName("size.y").roundTo(1) + ")" 
                    )
            	]
    			
    			it.children += renderingFactory.createKText() => [
                	it.setText("insets (t,r,b,l): (" + variable.getValueByName("insets.top").roundTo(1) + ", "
                	                                 + variable.getValueByName("insets.right").roundTo(1) + ", "
                	                                 + variable.getValueByName("insets.bottom").roundTo(1) + ", "
                	                                 + variable.getValueByName("insets.left").roundTo(1) + ")"
                	)
            	]
    			
    			it.children += renderingFactory.createKText() => [
                	it.setText("offset (x,y): (" + variable.getValueByName("offset.x").roundTo(1) + ", "
                	                             + variable.getValueByName("offset.y").roundTo(1) + ")"
                	)
            	]
            ]
		]
	}

/*	
	def createLayerlessNodes(KNode rootNode, IVariable variable) {
	    variable.linkedList.forEach[IVariable node |
            rootNode.children += node.createNode().putToLookUpWith(node) => [
            	it.nextTransformation(node, -1)
            ]
        ]
	}
*/

	def createLayerlessNodes(KNode rootNode, IVariable variable) {
	    variable.linkedList.forEach[IVariable node |
	    	rootNode.nextTransformation(node, -1)
        ]
	}
	
	def createLayeredNodes(KNode rootNode, IVariable variable) {
		var i = 0
		for (layer : variable.linkedList) {
			for (node : layer.getVariableByName("nodes").linkedList)
            	rootNode.nextTransformation(node, i)
			i = i+1
		}
	}

    def createEdges(KNode rootNode, IVariable layer) {
//    	rootNode.children += layer.createNode.putToLookUpWith(layer) => [
//    		it.setNodeSize(50,50)
//    	]
        layer.linkedList.forEach[IVariable node |
        	node.getVariableByName("ports").linkedList.forEach[IVariable port |
        		port.getVariableByName("outgoingEdges").linkedList.forEach[IVariable edge |
        			edge.getVariableByName("source.owner").createEdge(edge.getVariableByName("target.owner")) => [
//        			edge.getVariableByName("source.owner").createEdge(layer) => [
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
    
    def getEdgeType(IVariable variable) {
    	val type = variable.getVariableByName("propertyMap").getValFromHashMap("EDGE_TYPE")
    	if (type == null) {
	        return "NORMAL"
    	} else {
	        return type.getValueByName("name")   
    	}
    }
}