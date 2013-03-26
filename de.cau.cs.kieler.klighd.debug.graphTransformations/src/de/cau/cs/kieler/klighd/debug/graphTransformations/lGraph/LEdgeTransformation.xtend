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
package de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph

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
 * Transformation for an IVariable representing a LEdge.
 * 
 * @ author tit
 */
class LEdgeTransformation extends AbstractKielerGraphTransformation {
    @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
    
    /** The layout algorithm to use. */
    val layoutAlgorithm = "de.cau.cs.kieler.kiml.ogdf.planarization"
    /** The spacing to use. */
    val spacing = 75f
    /** The horizontal alignment for the left column of all grid layouts. */
    val leftColumnAlignment = HorizontalAlignment::RIGHT
    /** The horizontal alignment for the right column of all grid layouts. */
    val rightColumnAlignment = HorizontalAlignment::LEFT

    /** Specifies when to show the property map. */
    val showPropertyMap = ShowTextIf::DETAILED
    /** Specifies when to show the labels node. */
    val showLabelsNode = ShowTextIf::DETAILED
    
    /** Specifies when to show the number of labels. */
    val showLabelsCount = ShowTextIf::COMPACT
    /** Specifies when to show the number of bendPoints. */
	val showBendPointsCount = ShowTextIf::COMPACT
    /** Specifies when to show the bendPoints. */
	val showBendPoints = ShowTextIf::DETAILED
    /** Specifies when to show the target. */
	val showTarget = ShowTextIf::DETAILED
    /** Specifies when to show the source. */
	val showSource = ShowTextIf::DETAILED
    /** Specifies when to show the hashCode. */
	val showHashCode = ShowTextIf::DETAILED
    /** Specifies when to show the id. */
	val showID = ShowTextIf::ALWAYS
    
    /**
     * {@inheritDoc}
     */    
    override transform(IVariable edge, Object transformationInfo) {
        detailedView = transformationInfo.isDetailed

        return KimlUtil::createInitializedNode => [
            addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            addLayoutParam(LayoutOptions::SPACING, spacing)

			addInvisibleRendering
            addHeaderNode(edge)
            
            // add propertyMap
            if(showPropertyMap.conditionalShow(detailedView))
                addPropertyMapNode(edge.getVariable("propertyMap"), edge)
            
            // add labels node
            if(showLabelsNode.conditionalShow(detailedView))
                addLabelsNode(edge)
        ]
    }
    
	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
	    var retVal = if(showPropertyMap.conditionalShow(detailedView)) 2 else 1
        if(showLabelsNode.conditionalShow(detailedView)) (retVal = retVal + 1)
        return retVal
	}
    
    /**
     * Creates the header node containing basic informations for this element and adds it to the rootNode.
     * 
     * @param rootNode
     *              The KNode the new created KNode will be placed in.
     * @param edge
     *              The IVariable representing the edge transformed in this transformation.
     * 
     * @return The new created header KNode.
     */
     def addHeaderNode(KNode rootNode, IVariable edge) { 
        rootNode.addNodeById(edge) => [
            data += renderingFactory.createKRectangle => [
                
                val table = headerNodeBasics(detailedView, edge)

                // id of edge
                if (showID.conditionalShow(detailedView)) {
                    table.addGridElement("id:", leftColumnAlignment)
                    table.addGridElement(edge.nullOrValue("id"), rightColumnAlignment)
                } 

                // hashCode of edge
                if (showHashCode.conditionalShow(detailedView)) {
                    table.addGridElement("hashCode:", leftColumnAlignment)
                    table.addGridElement(edge.nullOrValue("hashCode"), rightColumnAlignment)
                } 
   
                // source of edge
                if (showSource.conditionalShow(detailedView)) {
                    table.addGridElement("source:", leftColumnAlignment)
                    table.addGridElement(edge.nullOrTypeAndID("source"), rightColumnAlignment)
                } 

                // target of edge
                if (showTarget.conditionalShow(detailedView)) {
                    table.addGridElement("target:", leftColumnAlignment)
                    table.addGridElement(edge.nullOrTypeAndID("target"), rightColumnAlignment)
                } 

                // list of bendPoints
                if (showBendPoints.conditionalShow(detailedView)) {
                    table.addGridElement("bendPoints (x,y):", leftColumnAlignment)
                    if (edge.getValue("bendPoints.size").equals("0")) {
                        // no bendPoints on edge
                        table.addGridElement("(none)", rightColumnAlignment)
                    } else {
                        // first BendPoint
                        val head = edge.getVariable("bendPoints").linkedList.head
                        table.addGridElement(head.nullOrKVektor(""), rightColumnAlignment)
                        // create list of bendPoints
                        for (bendPoint : edge.getVariable("bendPoints").linkedList.tail) {
                            table.addGridElement(bendPoint.nullOrKVektor(""), rightColumnAlignment)
                        }
                    }
                }
                 
                // # of bendPoints
                if (showBendPointsCount.conditionalShow(detailedView)) {
                    table.addGridElement("bendPoints (#):", leftColumnAlignment)
                    table.addGridElement(edge.nullOrSize("bendPoints"), rightColumnAlignment)
                }
                    
                // # of labels of port
                if (showLabelsCount.conditionalShow(detailedView)) {
                    table.addGridElement("labels (#):", leftColumnAlignment)
                    table.addGridElement(edge.nullOrSize("labels"), rightColumnAlignment)
                }
            ]
        ]
    }

    /**
     * Creates a node containing all labels of this edge and creates an edge from header node to it.
     * 
     * @param rootNode
     *              The KNode the new created KNode will be placed in.
     * @param edge
     *              The IVariable representing the edge transformed in this transformation.
     * 
     * @return The new created KNode.
     */
     def addLabelsNode(KNode rootNode, IVariable edge) {
        val labels = edge.getVariable("labels")
        
        // create container node
        val newNode = rootNode.addNodeById(labels) => [
            val rendering = renderingFactory.createKRectangle => [ rendering |
                data += rendering
                if(detailedView) rendering.lineWidth = 4 else rendering.lineWidth = 2
                rendering.ChildPlacement = renderingFactory.createKGridPlacement
            ]
                
            if (labels.getValue("size").equals("0")) {
                // there are no labels
                rendering.addKText("(none)")
            } else {
                // create all nodes for labels
                labels.linkedList.forEach [ label |
                    nextTransformation(label, false)
                ]
            }
        ]
        
        // create edge from header node to labels node
		edge.createTopElementEdge(labels, "labels")
		
		return newNode
    }
}
