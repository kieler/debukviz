/*
 * KIELER - Kiel Integrated Environment for Layout Eclipse RichClient
 *
 * http://www.informatik.uni-kiel.de/rtsys/kieler/
 * 
 * Copyright 2013 by
 * + Christian-Albrechts-University of Kiel
 *   + Department of Computer Science
 *     + Real-Time and Embedded Systems Group
 * 
 * This code is provided under the terms of the Eclipse Public License (EPL).
 * See the file epl-v10.html for the license text.
 */
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

/*
 * Transformation for an IVariable representing a PGraph
 * 
 * @ author tit
 */
class PGraphTransformation extends AbstractKielerGraphTransformation {

    
    @Inject
    extension KNodeExtensions
    @Inject 
    extension KPolylineExtensions 
    @Inject
    extension KRenderingExtensions
    @Inject
    extension PEdgeRenderer
    
    /** The layout algorithm to use. */
	val layoutAlgorithm = "de.cau.cs.kieler.klay.layered"
    /** The spacing to use. */
    val spacing = 75f
    /** The horizontal alignment for the left column of all grid layouts. */
    val leftColumnAlignment = HorizontalAlignment::RIGHT
    /** The horizontal alignment for the right column of all grid layouts. */
    val rightColumnAlignment = HorizontalAlignment::LEFT
    
    /** Specifies when to show the property map. */
	val showPropertyMap = ShowTextIf::DETAILED
    /** Specifies when to show the node with the visualization. */
	val showVisualization = ShowTextIf::DETAILED
    /** Specifies when to show the node with the faces. */
	val showFaces = ShowTextIf::DETAILED
	
    /** Specifies when to show the id. */
    val showID = ShowTextIf::DETAILED
    /** Specifies when to show the size. */
    val showSize = ShowTextIf::DETAILED
    /** Specifies when to show the type. */
	val showType = ShowTextIf::DETAILED
    /** Specifies when to show the position. */
	val showPosition = ShowTextIf::DETAILED
    /** Specifies when to show the node index. */
	val showNodeIndex = ShowTextIf::DETAILED
    /** Specifies when to show the edge index. */
	val showEdgeIndex = ShowTextIf::DETAILED
    /** Specifies when to show the face index. */
	val showFaceIndex = ShowTextIf::DETAILED
    /** Specifies when to show the external face. */
	val showExternalFace = ShowTextIf::DETAILED
    /** Specifies when to show the changed faces. */
	val showChangedFaces = ShowTextIf::DETAILED
    /** Specifies when to show the parent. */
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
    
    /**
     * Creates the header node containing basic informations for this element.
     * 
     * @param rootNode
     *              The KNode the new created KNode will be placed in.
     * @param graph
     *              The IVariable representing the graph transformed in this transformation.
     * 
     * @return The new created header KNode.
     */
    def addHeaderNode(KNode rootNode, IVariable graph) {
        rootNode.addNodeById(graph) => [
            data += renderingFactory.createKRectangle => [

                val table = headerNodeBasics(detailedView, graph)

                // id of graph
                if (showID.conditionalShow(detailedView)) {
                    table.addGridElement("id:", leftColumnAlignment)
                    table.addGridElement(graph.nullOrValue("id"), rightColumnAlignment)
                }

                // parent of graph
	            if (showParent.conditionalShow(detailedView)) {
	                table.addGridElement("parent:", leftColumnAlignment)
	                table.addGridElement(graph.nullOrValue("parent"), rightColumnAlignment)
                }

                // changed faces of graph
	            if (showChangedFaces.conditionalShow(detailedView)) {
	                table.addGridElement("changedFaces:", leftColumnAlignment)
	                table.addGridElement(graph.nullOrValue("changedFaces"), rightColumnAlignment)
                }

                // external face of graph
	            if (showExternalFace.conditionalShow(detailedView)) {
	                table.addGridElement("externalFace:", leftColumnAlignment)
	                table.addGridElement(graph.nullOrTypeAndID("externalFace"), rightColumnAlignment)
                }

                // face index of graph
	            if (showFaceIndex.conditionalShow(detailedView)) {
	                table.addGridElement("faceIndex:", leftColumnAlignment)
	                table.addGridElement(graph.nullOrValue("faceIndex"), rightColumnAlignment)
                }

                // edge index of graph
	            if (showEdgeIndex.conditionalShow(detailedView)) {
	                table.addGridElement("edgeIndex:", leftColumnAlignment)
	                table.addGridElement(graph.nullOrValue("edgeIndex"), rightColumnAlignment)
                }

                // node index of graph
	            if (showNodeIndex.conditionalShow(detailedView)) {
	                table.addGridElement("nodeIndex:", leftColumnAlignment)
	                table.addGridElement(graph.nullOrValue("nodeIndex"), rightColumnAlignment)
                }

                // position of graph
	            if (showPosition.conditionalShow(detailedView)) {
	                table.addGridElement("pos (x,y):", leftColumnAlignment)
	                table.addGridElement(graph.nullOrKVektor("pos"), rightColumnAlignment)
                }

                // size of graph
	            if (showSize.conditionalShow(detailedView)) {
	                table.addGridElement("size (x,y):", leftColumnAlignment)
	                table.addGridElement(graph.nullOrKVektor("size"), rightColumnAlignment)
                }

                // type of graph
	            if (showType.conditionalShow(detailedView)) {
	                table.addGridElement("type:", leftColumnAlignment)
	                table.addGridElement(graph.nullOrValue("type.name"), rightColumnAlignment)
                }
            ]
        ]
    }
    
    /**
     * Creates a node containing the visualization of this graph.
     * 
     * @param rootNode
     *              The KNode the new created KNode will be placed in.
     * @param graph
     *              The IVariable representing the graph transformed in this transformation.
     * 
     * @return The new created KNode.
     */
    def addVisualizationNode(KNode rootNode, IVariable graph) {
        val nodes = graph.getVariable("nodes")
        
        // create container node
        val newNode = rootNode.addNodeById(nodes) => [
            val rendering = renderingFactory.createKRectangle => [ rendering |
                data += rendering
                if(detailedView) rendering.lineWidth = 4 else rendering.lineWidth = 2
            ]

            if(nodes.linkedHashSetToLinkedList.size == 0) {
            	// graph is empty
                rendering.addKText("(none)")
            } else {
                // create all nodes
    		    nodes.linkedHashSetToLinkedList.forEach[IVariable element |
              		nextTransformation(element, false)
    	        ]
    	        
    	        // create all edges
    	        addAllEdges(graph)
            }
        ]

        // create edge from root node to the visualization node
	    graph.createTopElementEdge(nodes, "visualization")
	    
	    return newNode
    }

    /**
     * Creates a node containing the visualization of the faces of this graph.
     * 
     * @param rootNode
     *              The KNode the new created KNode will be placed in.
     * @param graph
     *              The IVariable representing the graph transformed in this transformation.
     * 
     * @return The new created KNode.
     */
    def addFacesVisualizationNode(KNode rootNode, IVariable graph) {
        val faces = graph.getVariable("faces")
        val facesList = faces.toLinkedList
        
        // create outer faces node
        val newNode = rootNode.addNodeById(faces) => [
            val rendering = renderingFactory.createKRectangle => [ rendering |
                data += rendering
                if(detailedView) rendering.lineWidth = 4 else rendering.lineWidth = 2
            ]

            if (facesList.size == 0) {
                // there are no faces
                rendering.addKText("(none)")
            } else {
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
        ]

        // create edge from root node to the faces node
        graph.createTopElementEdge(faces, "faces")
        
        return newNode
    }
}