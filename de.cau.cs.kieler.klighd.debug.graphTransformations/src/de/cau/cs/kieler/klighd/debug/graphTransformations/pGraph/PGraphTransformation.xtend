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
    @Inject
    extension PEdgeRenderer
    
	val layoutAlgorithm = "de.cau.cs.kieler.klay.layered"
    val spacing = 75f
    val leftColumnAlignment = HorizontalAlignment::RIGHT
    val rightColumnAlignment = HorizontalAlignment::LEFT
    
	val showPropertyMap = ShowTextIf::DETAILED
	val showVisualization = ShowTextIf::DETAILED
	val showFaces = ShowTextIf::DETAILED
	
    val showID = ShowTextIf::DETAILED
    val showSize = ShowTextIf::DETAILED
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

            // create the graph visualization
            if (showVisualization.conditionalShow(detailedView))
                it.addVisualizationNode(graph)
            
            // create the faces visualization
            if (showFaces.conditionalShow(detailedView))
            	it.addFacesVisualizationNode(graph)
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
        
        // create rectangle for outer node 
        return rootNode.addNodeById(nodes) => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
                if(nodes.linkedHashSetToLinkedList.size == 0) {
                	// graph is empty
                    it.addGridElement("(none)", HorizontalAlignment::CENTER)
                }
            ]

            // create all nodes
		    nodes.linkedHashSetToLinkedList.forEach[IVariable element |
          		it.nextTransformation(element, false)
	        ]
	        
	        // create all edges
	        it.addAllEdges(graph)

	        // create edge from root node to the visualization node
    	    graph.createTopElementEdge(nodes, "visualization")
        ]
    }

    def addFacesVisualizationNode(KNode rootNode, IVariable graph) {
        val faces = graph.getVariable("faces")
        val facesList = faces.toLinkedList
        
        // create outer faces node
        return rootNode.addNodeById(faces) => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
                if (facesList.size == 0) {
                    // there are no faces
                    it.ChildPlacement = renderingFactory.createKGridPlacement
                    it.addGridElement("(none)", HorizontalAlignment::CENTER)
                }
            ]
            if (facesList.size > 0) {
                // create nodes for all faces
                facesList.forEach[IVariable face | it.nextTransformation(face, false)]
                
                // create edges between the faces. check all edges in original graph and add an edge 
                // to the faces visualization:
                // source of new edge: leftFace of original edge
                // target of new edge: rightFace of original edge
                graph.getVariable("edges").toLinkedList.forEach[ edge |
                	val source = edge.getVariable("leftFace")
                	val target = edge.getVariable("rightFace")
                	source.createEdgeById(target) => [
		                it.data += renderingFactory.createKPolyline => [
	            	        it.setLineWidth(2)
	                        it.addArrowDecorator
		                    it.setLineStyle(LineStyle::SOLID)
	                    ]
	                    it.addLabel(
	                        "[" + edge.getValue("source.id") + " -> " + edge.getValue("target.id") + "]", 
                            EdgeLabelPlacement::HEAD
	                    )
            		]
                ]
            }
                
            // create edge from root node to the faces node
            graph.createTopElementEdge(faces, "faces")
        ]
    }
}