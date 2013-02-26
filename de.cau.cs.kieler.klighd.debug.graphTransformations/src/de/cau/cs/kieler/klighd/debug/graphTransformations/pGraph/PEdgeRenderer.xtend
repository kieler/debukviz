package de.cau.cs.kieler.klighd.debug.graphTransformations.pGraph

import de.cau.cs.kieler.core.kgraph.KNode
import org.eclipse.debug.core.model.IVariable
import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.core.krendering.KRenderingFactory
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import org.eclipse.debug.core.model.IVariable
import javax.inject.Inject
import de.cau.cs.kieler.core.krendering.LineStyle
import de.cau.cs.kieler.core.properties.IProperty
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.klighd.debug.graphTransformations.KTextIterableField
import de.cau.cs.kieler.core.krendering.HorizontalAlignment
import de.cau.cs.kieler.core.krendering.VerticalAlignment
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf
import de.cau.cs.kieler.core.krendering.KRenderingFactory
import java.util.HashMap
import de.cau.cs.kieler.core.kgraph.KEdge
import de.cau.cs.kieler.core.kgraph.KLabeledGraphElement

class PEdgeRenderer extends AbstractKielerGraphTransformation {
	
// Inject does not work here. So I had to extend AbstractKielerGraphTransformation to have access to 
// the helper methods from that class.
//    @Inject
//    extension AbstractKielerGraphTransformation
    @Inject
    extension KNodeExtensions
    @Inject
    extension KEdgeExtensions
    @Inject 
    extension KPolylineExtensions 
    @Inject
    extension KRenderingExtensions
    @Inject
    extension KLabelExtensions
    
    val leftColumnAlignment = HorizontalAlignment::RIGHT
    val rightColumnAlignment = HorizontalAlignment::LEFT
    
    val KRenderingFactory renderingFactory = KRenderingFactory::eINSTANCE
    
	def addAllEdges(KNode rootNode, IVariable graph) {
    	val nodes = graph.getVariable("nodes").toLinkedList
    	
    	// edgeMap holds all created KEdges, so we can later add the labels
    	// labelMap holds all labels we still have to add to edges (to the head) not yet created 
    	
    	val edgeMap = new HashMap<String, KEdge>
    	val labelMap = new HashMap<String, Integer>

    	// use the edges list of the nodes, as we need the index of the edge in this list for labeling
    	nodes.forEach[node |
    		val nodeID = node.getValueString
    		val edges = node.getVariable("edges").toLinkedList
    		
    		for (Integer i: 0..(edges.size -1)) {
    			val edge = edges.get(i)
    			var KEdge newEdge1

	            // IVariables the edge has to connect
	            val source = edge.getVariable("source")
	            var target = edge.getVariable("target")

				// to prevent double creations: only create edge if current node is it's source  	
    			if (source.getValueString.equals(nodeID)) {
		            val bendPoints = edge.getVariable("bendPoints")
		            val bendCount = Integer::parseInt(bendPoints.getValue("size"))
		            val isDirected = edge.getValue("isDirected").equals("true")
		            
		            // create bendPoint nodes
		            if(bendCount > 0) {
		                if(bendCount > 1) {
		                    // more than one bendPoint: create a container node, containing the bendPoints
		                    rootNode.children += bendPoints.createNode => [
		                        it.data += renderingFactory.createKRectangle => [
		                            it.lineWidth = 4
		                        ]
		                        bendPoints.linkedList.forEach[IVariable bendPoint |
		                            it.createBendPoint(bendPoint)
		                        ]
		                    ]
		                    // create the edge from the new created node to the target node
		                    newEdge1 = bendPoints.createEdge(target) => [
//				    			edgeMap.put(edge.getValueString, it)
				    			putToMap(edgeMap, edge.getValueString, it)
		                        it.data += renderingFactory.createKPolyline => [
		                            it.setLineWidth(2)
		                            if (isDirected) {
		                                it.addArrowDecorator
		                            } else {
										//TODO: ist der hier wirklich gut?
		                                it.addInheritanceTriangleArrowDecorator
		                            }
		                            it.setLineStyle(LineStyle::SOLID)
		                        ];
		                    ]
		                    // set target for the "default" edge to the new created container node
		                    target = bendPoints  
		                    
		                } else {
		                    // exactly one bendPoint, create a single bendPoint node
		                    val bendPoint = bendPoints.linkedList.get(0)
		                    rootNode.createBendPoint(bendPoint)
		                    // create the edge from the new created node to the target node
		                    newEdge1 = bendPoint.createEdge(target) => [
//				    			edgeMap.put(edge.getValueString, it)
				    			putToMap(edgeMap, edge.getValueString, it)
		                        it.data += renderingFactory.createKPolyline => [
		                            it.setLineWidth(2)
									//TODO: ist der hier wirklich gut?
		                            it.addInheritanceTriangleArrowDecorator
		                            it.setLineStyle(LineStyle::SOLID)
		                        ]
		                    ]
		                    // set target for the "default" edge to the new created node
		                    target = bendPoint                        
		                }
		            }
		            
		            // create first edge, from source to either new bendPoint or target node
		            val newEdge2 = source.createEdgeById(target) => [
		                it.data += renderingFactory.createKPolyline => [
		                    it.setLineWidth(2)
		                    if (isDirected) {
		                        it.addArrowDecorator
		                    } else {
		                        it.addInheritanceTriangleArrowDecorator
		                    }
		                    it.setLineStyle(LineStyle::SOLID)
		                ]
	                    it.addLabel(i.toString, EdgeLabelPlacement::TAIL)
		            ]
		            
		            // check if there is already a header label we have to add
//		            if(labelMap.containsKey(edge.getValueString)) {
		            if(checkInMap(labelMap, edge.getValueString)) {
		            	if (bendCount == 0) {
//			            	newEdge2.addLabel(labelMap.get(edge.getValueString).toString, EdgeLabelPlacement::HEAD)
			            	newEdge2.addLabel(getFromMap(labelMap, edge.getValueString).toString, EdgeLabelPlacement::HEAD)
		            	} else {
//		            		newEdge1.addLabel(labelMap.get(edge.getValueString).toString, EdgeLabelPlacement::HEAD)
		            		newEdge1.addLabel(getFromMap(labelMap, edge.getValueString).toString, EdgeLabelPlacement::HEAD)
		            	}
		            }
    			} else {
    				// current node is target of current edge, handle the header label
//    				if(edgeMap.containsKey(edge.getValueString)) {
    				if(checkInMap(edgeMap, edge.getValueString)) {
    					// edge is already in the graph, add the label
//    					edgeMap.get(edge.getValueString).addLabel(i.toString, EdgeLabelPlacement::HEAD)
    					val KEdge bla = getFromMap(edgeMap, edge.getValueString) as KEdge
    					bla.addLabel(i.toString, EdgeLabelPlacement::HEAD)
    				} else {
    					// edge is not in the graph, store label for later adding
//    					labelMap.put(edge.getValueString, i)
    					putToMap(labelMap, edge.getValueString, i)
    				}
    			}
	    	}
    	]
	}
	
	def putToMap(HashMap map, Object key, Object value) {
		println("putting into " + map + " :: " + key + "=" + value)
		map.put(key, value)
	}
	
	def getFromMap(HashMap map, Object key) {
		val retVal = map.get(key) 
		println("getting from " + map + " :: " + key + "=" + retVal)
		return retVal
	}
	
	def checkInMap (HashMap map, Object key) {
		val retVal = map.containsKey(key)
		println("checking in " + map + " :: " + key + "=" + retVal)
		return retVal
	}
	
	
	def addLabel(KLabeledGraphElement element, String text, EdgeLabelPlacement placement) {
		element.createLabel => [
            it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, placement)
            it.setLabelSize(30,15)
            it.text = text
		]
	}
	
    def createBendPoint(KNode rootNode, IVariable bendPoint) {
        return rootNode.addNodeById(bendPoint) => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 2
                it.ChildPlacement = renderingFactory.createKGridPlacement => [
	                it.numColumns = 1
                ]

                // bendPoints are just KVectors, so give a speaking name here
                it.addGridElement("bendPoint", leftColumnAlignment)
                
                // position
                it.addGridElement("pos (x,y): " + bendPoint.nullOrKVektor("pos"), leftColumnAlignment)
            ]
        ]
    }

	override getNodeCount(IVariable model) {
		throw new UnsupportedOperationException("Auto-generated function stub")
	}
	
	override transform(IVariable model, Object transformationInfo) {
		throw new UnsupportedOperationException("Auto-generated function stub")
	}
	
}