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
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

/*
 * Transformation for an IVariable representing a PFace
 * 
 * @ author tit
 */
class PFaceTransformation extends AbstractKielerGraphTransformation {
    @Inject
    extension KNodeExtensions
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
    /** Specifies when to show the node with the face visualization. */
	val showVisualization = ShowTextIf::DETAILED
        
    /** Specifies when to show the id. */
	val showID = ShowTextIf::ALWAYS
    /** Specifies when to show the adjacent nodes. */
	val showAdjacentNodes = ShowTextIf::ALWAYS
    /** Specifies when to show the adjacent edges. */
	val showAdjacentEdges = ShowTextIf::DETAILED
    /** Specifies when to show the number of edges. */
	val showEdgeCount = ShowTextIf::NEVER
    /** Specifies when to show the number of nodes. */
	val showNodeCount = ShowTextIf::NEVER

    /**
     * {@inheritDoc}
     */
    override transform(IVariable face, Object transformationInfo) {
        detailedView = transformationInfo.isDetailed

        return KimlUtil::createInitializedNode => [
            addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            addLayoutParam(LayoutOptions::SPACING, spacing)

			addInvisibleRendering
            addHeaderNode(face)

            // add propertyMap
            if(showPropertyMap.conditionalShow(detailedView))
                addPropertyMapNode(face.getVariable("propertyMap"), face)
                
            // create the graph visualization
            if(showVisualization.conditionalShow(detailedView))
     	       addVisualization(face)
    	]
    }
    
	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
		return if(showPropertyMap.conditionalShow(detailedView)) 2 else 1
	}

    /**
     * Creates the header node containing basic informations for this element.
     * 
     * @param rootNode
     *              The KNode the new created KNode will be placed in.
     * @param face
     *              The IVariable representing the face transformed in this transformation.
     * 
     * @return The new created header KNode.
     */
    def addHeaderNode(KNode rootNode, IVariable face) {
        rootNode.addNodeById(face) => [
            data += renderingFactory.createKRectangle => [
                
                val table = headerNodeBasics(detailedView, face)
                
                // id of face
                if (showID.conditionalShow(detailedView)) {
                    table.addGridElement("id:", leftColumnAlignment)
                    table.addGridElement(face.nullOrValue("id"), rightColumnAlignment)
                }
                
                // adjacent nodes
                if (showAdjacentNodes.conditionalShow(detailedView)) {
                    table.addGridElement("nodes:", leftColumnAlignment)
                    val nodes = face.getVariable("nodes").toLinkedList
                    if (nodes.size == 0) {
                    	table.addGridElement("(none)", rightColumnAlignment)
                    } else {
                    	table.addGridElement(nodes.head.getValue("id"), rightColumnAlignment)
                    	nodes.tail.forEach[ n |
                    		table.addBlankGridElement;
                    		table.addGridElement(n.getValue("id"), rightColumnAlignment)
                    	]
                    }
                }
                
                // adjacent edges
                if (showAdjacentEdges.conditionalShow(detailedView)) {
                    table.addGridElement("edges:", leftColumnAlignment)
                    val edges = face.getVariable("edges").toLinkedList
                    if (edges.size == 0) {
                    	table.addGridElement("(none)", rightColumnAlignment)
                    } else {
                    	table.addGridElement(edges.head.edgeString, rightColumnAlignment)
                    	edges.tail.forEach[ e |
                    		table.addBlankGridElement;
                    		table.addGridElement(e.edgeString, rightColumnAlignment)
                    	]
                    }
                }

                // number of nodes
                if (showNodeCount.conditionalShow(detailedView)) {
                    table.addGridElement("nodes (#):", leftColumnAlignment)
                    table.addGridElement(face.nullOrSize("nodes.map"), rightColumnAlignment)
                }

                // number of edges
                if (showEdgeCount.conditionalShow(detailedView)) {
                    table.addGridElement("edges (#):", leftColumnAlignment)
                    table.addGridElement(face.nullOrSize("edges.map"), rightColumnAlignment)
                }
            ]
        ]
    }

    /**
     * Creates a node containing the visualization of this face (all surrounding nodes and edges).
     * 
     * @param rootNode
     *              The KNode the new created KNode will be placed in.
     * @param face
     *              The IVariable representing the face transformed in this transformation.
     * 
     * @return The new created KNode.
     */
	def addVisualization(KNode rootNode, IVariable face) {
        val nodes = face.getVariable("nodes")
        val nodeList = nodes.toLinkedList

        // create container node
        val newNode = rootNode.addNodeById(nodes) => [
            val rendering = renderingFactory.createKRectangle => [ rendering |
                data += rendering
                if(detailedView) rendering.lineWidth = 4 else rendering.lineWidth = 2
            ]

            if(nodeList.size == 0) {
            	// face is empty
                rendering.addKText("(none)")
            } else {
                // create all nodes
                nodeList.forEach[IVariable node |
                    nextTransformation(node, false)
                ]
                
                // create all edges
                addAllEdges(face)
            }
        ]

        // create edge from header node to visualization
        face.createTopElementEdge(nodes, "visualization")
        
        return newNode
	}
    
    /**
     * Returns a string for labeling the edge in the form "'sourceID' -> 'targetID'".
     * This method does not change the edge (i.e. place the label to it) 
     * 
     * @param edge
     *              The edge the label will be created for.
     * @return The created String.
     */
     def edgeString (IVariable edge) {
    	return edge.getValueString + 
    		   " " + 
    		   edge.getVariable("source").getValue("id") +
    		   " -> " + 
    		   edge.getVariable("target").getValue("id")
    }
}
