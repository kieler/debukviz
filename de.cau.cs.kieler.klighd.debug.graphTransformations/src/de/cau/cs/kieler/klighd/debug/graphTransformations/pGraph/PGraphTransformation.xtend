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
        detailedView = transformationInfo.isDetailed
        
        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            it.addLayoutParam(LayoutOptions::SPACING, spacing)

			it.addInvisibleRendering
            it.addHeaderNode(graph)

            // add propertyMap
            if(showPropertyMap.conditionalShow(detailedView)) 
                it.addPropertyMapNode(graph.getVariable("propertyMap"), graph)

            // create the visualization
            if (showVisualization.conditionalShow(detailedView))
                it.addVisualizationNode(graph)
            
            // create the faces visualization
            if (showFaces.conditionalShow(detailedView))
            	it.addFacesNode(graph)
        ]
    }
    
	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
	    var retVal = if(showPropertyMap.conditionalShow(detailedView)) 2 else 1
	    if (showVisualization.conditionalShow(detailedView)) retVal = retVal + 1
	    if (showFaces.conditionalShow(detailedView)) retVal = retVal + 1
		return retVal
	}
    
    def addHeaderNode(KNode rootNode, IVariable graph) {
        rootNode.addNodeById(graph) => [
            it.data += renderingFactory.createKRectangle => [

                val table = it.headerNodeBasics(detailedView, graph)

                if (showID.conditionalShow(detailedView)) {
                    table.addGridElement("id:", leftColumnAlignment)
                    table.addGridElement(graph.nullOrValue("id"), rightColumnAlignment)
                }

	            if (showParent.conditionalShow(detailedView)) {
	                table.addGridElement("parent:", leftColumnAlignment)
	                table.addGridElement(graph.nullOrValue("parent"), rightColumnAlignment)
                }

	            if (showChangedFaces.conditionalShow(detailedView)) {
	                table.addGridElement("changedFaces:", leftColumnAlignment)
	                table.addGridElement(graph.nullOrValue("changedFaces"), rightColumnAlignment)
                }

	            if (showExternalFaces.conditionalShow(detailedView)) {
	                table.addGridElement("externalFace:", leftColumnAlignment)
	                table.addGridElement(graph.nullOrTypeAndID("externalFace"), rightColumnAlignment)
                }

	            if (showFaceIndex.conditionalShow(detailedView)) {
	                table.addGridElement("faceIndex:", leftColumnAlignment)
	                table.addGridElement(graph.nullOrValue("faceIndex"), rightColumnAlignment)
                }

	            if (showEdgeIndex.conditionalShow(detailedView)) {
	                table.addGridElement("edgeIndex:", leftColumnAlignment)
	                table.addGridElement(graph.nullOrValue("edgeIndex"), rightColumnAlignment)
                }

	            if (showNodeIndex.conditionalShow(detailedView)) {
	                table.addGridElement("nodeIndex:", leftColumnAlignment)
	                table.addGridElement(graph.nullOrValue("nodeIndex"), rightColumnAlignment)
                }

	            if (showPosition.conditionalShow(detailedView)) {
	                table.addGridElement("pos (x,y):", leftColumnAlignment)
	                table.addGridElement(graph.nullOrKVektor("pos"), rightColumnAlignment)
                }

	            if (showSize.conditionalShow(detailedView)) {
	                table.addGridElement("size (x,y):", leftColumnAlignment)
	                table.addGridElement(graph.nullOrKVektor("size"), rightColumnAlignment)
                }

	            if (showType.conditionalShow(detailedView)) {
	                table.addGridElement("type:", leftColumnAlignment)
	                table.addGridElement(graph.nullOrValue("type.name"), rightColumnAlignment)
                }
            ]
        ]
    }
    
    
    def addVisualizationNode(KNode rootNode, IVariable graph) {
        val nodes = graph.getVariable("nodes")
        
        // create outer nodes rectangle
        return rootNode.addNodeById(nodes) => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
                if(nodes.linkedHashSetToLinkedList.size == 0) {
                    it.addGridElement("none", HorizontalAlignment::CENTER)
                }
            ]

            // create all nodes
		    nodes.linkedHashSetToLinkedList.forEach[IVariable element |
          		it.nextTransformation(element, false)
	        ]
	        
	        // create all edges
	        it.createEdges(graph)

	        // create edge from root node to the nodes node
    	    graph.createTopElementEdge(nodes, "visualization")
        ]
    }

    def createEdges(KNode rootNode, IVariable graph) {
    	val edges = graph.getVariable("edges")
    	edges.linkedHashSetToLinkedList.forEach[IVariable edge |

            // get the bendPoints assigned to the edge
            val bendPoints = edge.getVariable("bendPoints")
            val bendCount = Integer::parseInt(bendPoints.getValue("size"))
            
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
                    bendPoint.createEdge(target) => [
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
            source.createEdgeById(target) => [
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
    
    
    def addFacesNode(KNode rootNode, IVariable graph) {
        val faces = graph.getVariable("faces")
        val filteredFaces = faces.linkedHashSetToLinkedList
        
        // create outer faces node
        return rootNode.addNodeById(faces) => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
                if (filteredFaces.size == 0) {
                    // there are no faces
                    it.ChildPlacement = renderingFactory.createKGridPlacement
                    it.addGridElement("none", HorizontalAlignment::CENTER)
                }
            ]
            if (filteredFaces.size > 0) {
                //there are faces, so create nodes for all faces
                filteredFaces.forEach[IVariable face | it.nextTransformation(face)]
            }
                
            // create edge from root node to the faces node
            graph.createTopElementEdge(faces, "faces")
        ]
    }
}