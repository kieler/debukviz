package de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.LineStyle
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKNodeTransformation
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

class LGraphTransformation extends AbstractKNodeTransformation {
    
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
	override transform(IVariable graph) {
        return KimlUtil::createInitializedNode=> [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            
     		it.createHeaderNode(graph)
      		it.createPropertyMap(graph)
      		it.createAllNodes(graph)

      		it.createEdges(graph.getVariable("layerlessNodes"))
      		graph.getVariable("layers").linkedList.forEach[IVariable layer |
      			it.createEdges(layer)	
      		]
        ]

	}
	
	def createHeaderNode(KNode rootNode, IVariable graph) {
		rootNode.children += graph.createNode => [
//    		it.setNodeSize(120,80)
    		it.data += renderingFactory.createKRectangle => [
    			it.lineWidth = 4
    			it.ChildPlacement = renderingFactory.createKGridPlacement

                // type of the graph
                it.children += renderingFactory.createKText => [
                    it.setForegroundColor(120,120,120)
                    it.text = graph.ShortType
                ]
                
                // name of the variable
                it.children += renderingFactory.createKText => [
                    it.text = "VarName: " + graph.name 
                ]
                
                // hashCode of graph
                it.children += createKText(graph, "hashCode", "", ": ")
    			
    			// hashCodeCounter of graph
    			it.children += renderingFactory.createKText => [
                    it.text = "hashCodeCounter: " + graph.getValue("hashCodeCounter.count")
              	]
              	
              	// id of graph
              	it.children += createKText(graph, "id", "", ": ")
              	
              	// size of graph
                it.children += renderingFactory.createKText => [
                    it.text = "size (x,y): (" + graph.getValue("size.x").round(1) + " x " 
                                              + graph.getValue("size.y").round(1) + ")" 
                ]
    			
    			// insets of graph
    			it.children += renderingFactory.createKText => [
                	it.text = "insets (t,r,b,l): (" + graph.getValue("insets.top").round(1) + " x "
                	                                + graph.getValue("insets.right").round(1) + " x "
                	                                + graph.getValue("insets.bottom").round(1) + " x "
                	                                + graph.getValue("insets.left").round(1) + ")"
            	]
    			
    			// offset of graph
    			it.children += renderingFactory.createKText => [
                	it.text = "offset (x,y): (" + graph.getValue("offset.x").round(1) + " x "
                	                            + graph.getValue("offset.y").round(1) + ")"
            	]
            ]
		]
	}


	def createAllNodes(KNode rootNode, IVariable graph) {
		// the node has to be registered to a specific object.
		// we are using the layerlessNodes element here
		val dummy = graph.getVariable("layerlessNodes")
        rootNode.children += dummy.createNode => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
            ]
	  		it.createLayerlessNodes(graph.getVariable("layerlessNodes"))
	  		it.createLayeredNodes(graph.getVariable("layers"))
  		]
  		
	    // create edge from graph to propertyMap
        graph.createEdge(dummy) => [
            it.data += renderingFactory.createKPolyline => [
                it.setLineWidth(2)
                it.addArrowDecorator
                it.setLineStyle(LineStyle::SOLID)
            ]
            KimlUtil::createInitializedLabel(it) => [
                it.setText("visualization")
            ]
        ]   
	}
	
	def createLayerlessNodes(KNode rootNode, IVariable layerlessNodes) {
	    layerlessNodes.linkedList.forEach[IVariable node |
	    	rootNode.nextTransformation(node, -1)
        ]
	}
	
	def createLayeredNodes(KNode rootNode, IVariable layers) {
		var i = 0
		for (layer : layers.linkedList) {
			for (node : layer.getVariable("nodes").linkedList)
            	rootNode.nextTransformation(node, i)
			i = i+1
		}
	}

    def createEdges(KNode rootNode, IVariable layer) {
        layer.linkedList.forEach[IVariable node |
        	node.getVariable("ports").linkedList.forEach[IVariable port |
        		port.getVariable("outgoingEdges").linkedList.forEach[IVariable edge |
                    edge.getVariable("source.owner")
                        .createEdge(edge.getVariable("target.owner")) => [
        				it.data += renderingFactory.createKPolyline => [
	            		    it.setLineWidth(2)
                            it.addArrowDecorator
                            
                            switch edge.edgeType {
                                case "COMPOUND_DUMMY" : it.setLineStyle(LineStyle::DASH)
                                case "COMPOUND_SIDE" : it.setLineStyle(LineStyle::DOT)
                                default : it.setLineStyle(LineStyle::SOLID)
                            }
    	    			]
        			]
        		]
        	]
        ]
    }
    
    def getEdgeType(IVariable edge) {
    	val type = edge.getVariable("propertyMap").getValFromHashMap("EDGE_TYPE")
    	if (type == null) {
	        return "NORMAL"
    	} else {
	        return type.getValue("name")   
    	}
    }
    
    def createPropertyMap(KNode rootNode,IVariable propertyMapHolder) {
    	val propertyMap = propertyMapHolder.getVariable("propertyMap")
    	
    	// create propertyMap node
        rootNode.children += propertyMap.createNode => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
    			it.ChildPlacement = renderingFactory.createKGridPlacement

                // type of the graph
                it.children += renderingFactory.createKText => [
                    it.setForegroundColor(120,120,120)
                    it.text = propertyMap.ShortType
                ]

                // add all non null properties
                propertyMap.getVariables("table").filter[e | e.valueIsNotNull].forEach[IVariable property |
	                it.children += renderingFactory.createKText => [
	                    it.text = property.getValue("key.id") + ": " + property.getValue("key")
	                ]
                ]
            ]
        ]
        
        // create edge from graph to propertyMap
        propertyMapHolder.createEdge(propertyMap) => [
            it.data += renderingFactory.createKPolyline => [
                it.setLineWidth(2)
                it.addArrowDecorator
                it.setLineStyle(LineStyle::SOLID)
            ]
            KimlUtil::createInitializedLabel(it) => [
                it.setText("propertyMap")
            ]
        ]    
    }
}




