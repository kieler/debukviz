package de.cau.cs.kieler.klighd.debug.graphTransformations.pGraph

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

class PGraphTransformation extends AbstractKielerGraphTransformation {

    
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
    val leftColumnAlignment = HorizontalAlignment::RIGHT
    val rightColumnAlignment = HorizontalAlignment::LEFT
    
    val showID = ShowTextIf::DETAILED
    val showSize = ShowTextIf::DETAILED

	val showFaces = ShowTextIf::DETAILED
	val showPropertyMap = ShowTextIf::DETAILED
	val showVisualization = ShowTextIf::DETAILED
	val showType = ShowTextIf::DETAILED
	val showPosition = ShowTextIf::DETAILED
	val showNodeIndex = ShowTextIf::DETAILED
	val showEdgeIndex = ShowTextIf::DETAILED
	val showFaceIndex = ShowTextIf::DETAILED
	val showExternalFaces = ShowTextIf::DETAILED
	val showChangedFaces = ShowTextIf::DETAILED
	val showParent = ShowTextIf::DETAILED
    /**
     * {@inheritDoc}
     */
    override transform(IVariable graph, Object transformationInfo) {
        if(transformationInfo instanceof Boolean) detailedView = transformationInfo as Boolean
        
        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            it.addLayoutParam(LayoutOptions::SPACING, spacing)
            
            // create header node
            it.createHeaderNode(graph)

            // add propertyMap
            if(detailedView.conditionalShow(showPropertyMap)) 
                it.addPropertyMapAndEdge(graph.getVariable("propertyMap"), graph)

            // create the visualization
            if (detailedView.conditionalShow(showVisualization))
                it.createVisualization(graph)
            
            // create the faces visualization
            if (detailedView.conditionalShow(showFaces))
            	it.createFaces(graph)
        ]
    }
    
	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
		return if(detailedView) 4 else 1
	}
    
    def createHeaderNode(KNode rootNode, IVariable graph) {
        rootNode.addNodeById(graph) => [
            it.data += renderingFactory.createKRectangle => [

                val table = it.headerNodeBasics(detailedView, graph)

                // id of graph
	            if (detailedView.conditionalShow(showID)) {
	                table.addGridElement("id:", leftColumnAlignment)
	                table.addGridElement(nullOrValue(graph, "id"), rightColumnAlignment)
                }

	            if (detailedView.conditionalShow(showParent)) {
	                table.addGridElement("parent:", leftColumnAlignment)
	                table.addGridElement(nullOrValue(graph, "parent"), rightColumnAlignment)
                }

	            if (detailedView.conditionalShow(showChangedFaces)) {
	                table.addGridElement("changedFaces:", leftColumnAlignment)
	                table.addGridElement(nullOrValue(graph, "changedFaces"), rightColumnAlignment)
                }

	            if (detailedView.conditionalShow(showExternalFaces)) {
	                table.addGridElement("externalFace:", leftColumnAlignment)
	                table.addGridElement(typeAndId(graph, "externalFace"), rightColumnAlignment)
                }

	            if (detailedView.conditionalShow(showFaceIndex)) {
	                table.addGridElement("faceIndex:", leftColumnAlignment)
	                table.addGridElement(nullOrValue(graph, "faceIndex"), rightColumnAlignment)
                }

	            if (detailedView.conditionalShow(showEdgeIndex)) {
	                table.addGridElement("edgeIndex:", leftColumnAlignment)
	                table.addGridElement(nullOrValue(graph, "edgeIndex"), rightColumnAlignment)
                }

	            if (detailedView.conditionalShow(showNodeIndex)) {
	                table.addGridElement("nodeIndex:", leftColumnAlignment)
	                table.addGridElement(nullOrValue(graph, "nodeIndex"), rightColumnAlignment)
                }

	            if (detailedView.conditionalShow(showPosition)) {
	                table.addGridElement("pos (x,y):", leftColumnAlignment)
	                table.addGridElement("(" + graph.getValue("pos.x").round + ", " 
                                  			 + graph.getValue("pos.y").round + ")", rightColumnAlignment)
                }

	            if (detailedView.conditionalShow(showSize)) {
	                table.addGridElement("size (x,y):", leftColumnAlignment)
	                table.addGridElement("(" + graph.getValue("size.x").round + ", " 
                                  			 + graph.getValue("size.y").round + ")", rightColumnAlignment)
                }

	            if (detailedView.conditionalShow(showType)) {
	                table.addGridElement("type:", leftColumnAlignment)
	                table.addGridElement(graph.getValue("type.name"), rightColumnAlignment)
                }
            ]
        ]
    }
    
    
    def createVisualization(KNode rootNode, IVariable graph) {
        val nodes = graph.getVariable("nodes")
        
        // create outer nodes rectangle
        return rootNode.addNodeById(nodes) => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
            ]

            // create all nodes
		    nodes.hashMapToLinkedList.forEach[IVariable element |
          		it.nextTransformation(element.getVariable("key"), false)
	        ]
	        
	        // create all edges
	        it.createEdges(graph)

	        // create edge from root node to the nodes node
    	    graph.createTopElementEdge(nodes, "visualization")
        ]
    }

    def createEdges(KNode rootNode, IVariable graph) {
    	val edges = graph.getVariable("edges")
    	
    	edges.hashMapToLinkedList.forEach[IVariable element |
    		val edge = element.getVariable("key")

            // get the bendPoints assigned to the edge
            val bendPoints = edge.getVariable("bendPoints")
            val bla = bendPoints.getValue("size")
            val bendCount = bendPoints.size
            
            // IVariables the edge has to connect
            val source = edge.getVariable("source")
            var target = edge.getVariable("target")

            // true if edge is directed
            val isDirected = edge.getValue("isDirected").equals("true")
            
            // create bendPoint nodes
            if(bendCount > 0) {
                if(bendCount > 1) {
                    // more than one bendPoint: create a container node, containing the bendPoints
                    rootNode.children += bendPoints.createNode => [
                        // create container rectangle 
                        it.data += renderingFactory.createKRectangle => [
                            it.lineWidth = 4
                        ]
                        // create all bendPoint nodes
                        bendPoints.linkedList.forEach[IVariable bendPoint |
                            it.createBendPoint(bendPoint)
                        ]
                    ]
                    // create the edge from the new created node to the target node
                    bendPoints.createEdge(target) => [
                        it.data += renderingFactory.createKPolyline => [
                            it.setLineWidth(2)
                            if (isDirected) {
                                it.addArrowDecorator
                            } else {
//TODO: ist der hier wirklich hübsch?
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
                    bendPoint.createEdge(target) => [
                        it.data += renderingFactory.createKPolyline => [
                            it.setLineWidth(2)
                            it.addInheritanceTriangleArrowDecorator
                            it.setLineStyle(LineStyle::SOLID)
                        ]
                    ]
                    // set target for the "default" edge to the new created node
                    target = bendPoint                        
                }
            }
            // create first edge, from source to either new bendPoint or target node
            source.createEdge(target) => [
                it.data += renderingFactory.createKPolyline => [
                    it.setLineWidth(2)
                    if (isDirected) {
                        it.addArrowDecorator
                    } else {
                        it.addInheritanceTriangleArrowDecorator
                    }
                    it.setLineStyle(LineStyle::SOLID)
                ]
            ]
        ]
    }

    def createBendPoint(KNode rootNode, IVariable bendPoint) {
        return rootNode.addNodeById(bendPoint) => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 2
                it.ChildPlacement = renderingFactory.createKGridPlacement

                // bendPoints are just KVectors, so give a speaking name here
                it.addGridElement("bendPoint:", leftColumnAlignment)
                
                // position
                it.addGridElement("pos (x,y): (" + bendPoint.getValue("pos.x").round + ", " 
                                                 + bendPoint.getValue("pos.y").round + ")", 
                                                 rightColumnAlignment)
            ]
        ]        
    }
    
    
    def createFaces(KNode rootNode, IVariable graph) {
        val faces = graph.getVariable("faces")
        
        // create outer faces node
        faces.createNode => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
            ]
            
            // add label
            faces.createLabel(it) => [
                it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::CENTER)
                it.setLabelSize(50,20)
                it.text = "faces"
            ]
            
            val filteredFaces = faces.getVariable("map").getVariables("table").filter[e | e.valueIsNotNull]

            if (filteredFaces.size == 0) {
                // there are no faces, so create a small empty box
                it.setNodeSize(40,30)
            } else {
                //there are faces, so create nodes for all faces
                filteredFaces.forEach[IVariable face | it.nextTransformation(face.getVariable("key"))]
            }
        ]        
        // create edge from root node to the faces node
        graph.createEdge(faces) => [
            it.data += renderingFactory.createKPolyline => [
                it.setLineWidth(2)
                it.addArrowDecorator
                it.setLineStyle(LineStyle::SOLID)
            ]
        ]
    }
}