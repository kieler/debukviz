package de.cau.cs.kieler.klighd.debug.graphTransformations.pGraph

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.HorizontalAlignment
import de.cau.cs.kieler.core.krendering.LineStyle
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

class PGraphTransformation extends AbstractKielerGraphTransformation {

    
    @Inject
    extension KNodeExtensions
    @Inject 
    extension KPolylineExtensions 
    @Inject
    extension KRenderingExtensions
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
            addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            addLayoutParam(LayoutOptions::SPACING, spacing)

			addInvisibleRendering
            addHeaderNode(graph)

            // add propertyMap
            if(showPropertyMap.conditionalShow(detailedView)) 
                addPropertyMapNode(graph.getVariable("propertyMap"), graph)

            // create the graph visualization
            if (showVisualization.conditionalShow(detailedView))
                addVisualizationNode(graph)
            
            // create the faces visualization
            if (showFaces.conditionalShow(detailedView))
            	addFacesVisualizationNode(graph)
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
            data += renderingFactory.createKRectangle => [

                val table = headerNodeBasics(detailedView, graph)

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
            data += renderingFactory.createKRectangle => [
                lineWidth = 4
                if(nodes.linkedHashSetToLinkedList.size == 0) {
                	// graph is empty
                    addGridElement("(none)", HorizontalAlignment::CENTER)
                }
            ]

            // create all nodes
		    nodes.linkedHashSetToLinkedList.forEach[IVariable element |
          		nextTransformation(element, false)
	        ]
	        
	        // create all edges
	        addAllEdges(graph)

	        // create edge from root node to the visualization node
    	    graph.createTopElementEdge(nodes, "visualization")
        ]
    }

    def addFacesVisualizationNode(KNode rootNode, IVariable graph) {
        val faces = graph.getVariable("faces")
        val facesList = faces.toLinkedList
        
        // create outer faces node
        return rootNode.addNodeById(faces) => [
            data += renderingFactory.createKRectangle => [
                lineWidth = 4
                if (facesList.size == 0) {
                    // there are no faces
                    ChildPlacement = renderingFactory.createKGridPlacement
                    addGridElement("(none)", HorizontalAlignment::CENTER)
                }
            ]
            if (facesList.size > 0) {
                // create nodes for all faces
                facesList.forEach[IVariable face | nextTransformation(face, false)]
                
                // create edges between the faces. check all edges in original graph and add an edge 
                // to the faces visualization:
                // source of new edge: leftFace of original edge
                // target of new edge: rightFace of original edge
                graph.getVariable("edges").toLinkedList.forEach[ edge |
                	val source = edge.getVariable("leftFace")
                	val target = edge.getVariable("rightFace")
                	source.createEdgeById(target) => [
		                data += renderingFactory.createKPolyline => [
	            	        setLineWidth(2)
	                        addArrowDecorator
		                    setLineStyle(LineStyle::SOLID)
	                    ]
	                    addLabel(
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