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
import de.cau.cs.kieler.core.krendering.KContainerRendering
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
 * Transformation for an IVariable representing a PNode
 * 
 * @ author tit
 */
class PNodeTransformation extends AbstractKielerGraphTransformation {
    
    @Inject 
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
        
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
    /** Specifies when to show the property map. */
	val showEdges = ShowTextIf::DETAILED

	val showID = ShowTextIf::ALWAYS
	val showSize = ShowTextIf::DETAILED
	val showPos = ShowTextIf::DETAILED
    val showType = ShowTextIf::DETAILED
    val showParent = ShowTextIf::DETAILED      

    /**
     * {@inheritDoc}
     */
    override transform(IVariable node, Object transformationInfo) {
        detailedView = transformationInfo.isDetailed

        return KimlUtil::createInitializedNode => [
        
            addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            addLayoutParam(LayoutOptions::SPACING, spacing)

			addInvisibleRendering
            addHeaderNode(node)

            // add propertyMap
            if(showPropertyMap.conditionalShow(detailedView))
                addPropertyMapNode(node.getVariable("propertyMap"), node)

            // add edges node
            if(showEdges.conditionalShow(detailedView))
            	addEdgesNode(node)
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
     * @param node
     *              The IVariable representing the node transformed in this transformation.
     * 
     * @return The new created header KNode.
     */
    def addHeaderNode(KNode rootNode, IVariable node) {
        rootNode.addNodeById(node) => [
            // either an ellipse or a rectangle
            var KContainerRendering container
            val type = node.getValue("type.name")

            // comments at PGraph.writeDotGraph is not consistent to the code in the method
            // here I am following the display style implemented
            switch type {
                case "NORMAL" : {
                    // Normal nodes are represented by an ellipse
                    container = renderingFactory.createKEllipse
                    container.lineWidth = 2
                }
                case "FACE" : {
                    // Face nodes are represented by an rectangle
                    container = renderingFactory.createKRectangle
                    container.lineWidth = 2
                }
                default : {
                    // other nodes are represented by a bold ellipse
                    // in writeDotGraph they were originally represented by a filled circle
                    container = renderingFactory.createKEllipse
                    container.lineWidth = 4
                }
                // coloring is ignored
            }

            // add the rendering to the new created rootNode
            data += container
            
            val table = container.headerNodeBasics(detailedView, node)

            // PNodes don't have a name or labels
            // id of node
            if (showID.conditionalShow(detailedView)) {
                table.addGridElement("id:", leftColumnAlignment)
                table.addGridElement(node.nullOrValue("id"), rightColumnAlignment)
            }
            
            // type
            if (showType.conditionalShow(detailedView)) {
                table.addGridElement("type:", leftColumnAlignment)
                table.addGridElement(type, rightColumnAlignment)
            }
            
            // parent
            if (showParent.conditionalShow(detailedView)) {
                table.addGridElement("parent:", leftColumnAlignment)
                table.addGridElement(node.nullOrTypeAndID("parent"), rightColumnAlignment)
            }
            
            // size
            if (showSize.conditionalShow(detailedView)) {
                table.addGridElement("size (x,y):", leftColumnAlignment)
                table.addGridElement(node.nullOrKVektor("size"), rightColumnAlignment)
            }

            // position
            if (showPos.conditionalShow(detailedView)) {
                table.addGridElement("pos (x,y):", leftColumnAlignment)
                table.addGridElement(node.nullOrKVektor("pos"), rightColumnAlignment)
            }

        ]
    }
                
    /**
     * Creates a node containing all edges of this Node.
     * 
     * @param rootNode
     *              The KNode the new created KNode will be placed in.
     * @param node
     *              The IVariable representing the node transformed in this transformation.
     * 
     * @return The new created KNode.
     */
	def addEdgesNode(KNode rootNode, IVariable node) {
        val edges = node.getVariable("edges")
        
        // create rectangle for outer node 
        val newNode = rootNode.addNodeById(edges) => [
            val rendering = renderingFactory.createKRectangle => [ rendering |
                data += rendering
                if(detailedView) rendering.lineWidth = 4 else rendering.lineWidth = 2
            ]

            if(edges.linkedList.size == 0) {
            	// no edges to this node
                rendering.addKText("(none)")
            } else {
                // create nodes for all edges
    		    edges.linkedList.forEach[IVariable element | nextTransformation(element, false)]
            }
        ]

        // create edge from root node to the visualization node
	    node.createTopElementEdge(edges, "edges")

        return newNode
	}
}