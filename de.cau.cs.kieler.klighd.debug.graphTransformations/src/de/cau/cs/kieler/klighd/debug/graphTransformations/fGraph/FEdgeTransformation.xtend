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
 package de.cau.cs.kieler.klighd.debug.graphTransformations.fGraph

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.klighd.debug.graphTransformations.KTextIterableField
import de.cau.cs.kieler.klighd.debug.graphTransformations.KTextIterableField$TextAlignment
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

/*
 * Transformation for a IVariable representing a FEdge.
 * This class still uses the deprecated KTextIterableField class.
 * 
 * @ author tit
 */
class FEdgeTransformation extends AbstractKielerGraphTransformation {
    @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
        
    /** The layout algorithm to use. */
    val layoutAlgorithm = "de.cau.cs.kieler.klay.layered"
    /** The spacing to use. */
    val spacing = 75f
    /** The horizontal alignment for the left column of all KTextIterableFields. */
    val leftColumnAlignment = KTextIterableField$TextAlignment::RIGHT
    /** The horizontal alignment for the right column of all KTextIterableFields. */
    val rightColumnAlignment = KTextIterableField$TextAlignment::LEFT
    /** The top outer gap of the KTextIterableField. */
    val topGap = 4
    /** The right outer gap of the KTextIterableField. */
    val rightGap = 5
    /** The bottom outer gap of the KTextIterableField. */
    val bottomGap = 5
    /** The left outer gap of the KTextIterableField. */
    val leftGap = 4
    /** The vertical inner gap of the KTextIterableField. */
    val vGap = 3
    /** The horizontal inner gap of the KTextIterableField. */
    val hGap = 5
    
    /** Specifies when to show the property map. */
    val showPropertyMap = ShowTextIf::DETAILED
    /** Specifies when to show the node containing the labels. */
    val showLabelsNode = ShowTextIf::DETAILED
    /** Specifies when to show the node containing the bendPoints. */
    val showBendPointsNode = ShowTextIf::DETAILED
    
    /** Specifies when to show the source. */
    val showSource = ShowTextIf::ALWAYS
    /** Specifies when to show the target. */
    val showTarget = ShowTextIf::ALWAYS
    /** Specifies when to show the number of labels. */
    val showLabelCount = ShowTextIf::COMPACT
    /** Specifies when to show the number of bendPoints. */
    val showBendPointCount = ShowTextIf::COMPACT

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
                
            // add bendPoints node
            if(showBendPointsNode.conditionalShow(detailedView))
                addBendPointsNode(edge)
        ]
    }
    
	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
	    var retVal = if(showPropertyMap.conditionalShow(detailedView)) 2 else 1
        if(showLabelsNode.conditionalShow(detailedView)) retVal = retVal + 1
        if(showBendPointsNode.conditionalShow(detailedView)) retVal = retVal + 1
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

                val field = new KTextIterableField(topGap, rightGap, bottomGap, leftGap, vGap, hGap)
                headerNodeBasics(field, detailedView, edge, leftColumnAlignment, rightColumnAlignment)
                var row = field.rowCount

                // source of edge
                if(showSource.conditionalShow(detailedView)) {
                    field.set("source:", row, 0, leftColumnAlignment)
                    field.set("FNode " + edge.getValue("source.id") + " " 
                                       + edge.getVariable("source").getValueString, row, 1, rightColumnAlignment)
                    row = row + 1
                }

                // target of edge
                if(showTarget.conditionalShow(detailedView)) {
                    field.set("target:", row, 0, leftColumnAlignment)
                    field.set("FNode " + edge.getValue("target.id") + " " 
                                       + edge.getVariable("target").getValueString, row, 1, rightColumnAlignment)
                    row = row + 1
                }

                // # of bendPoints
                if(showBendPointCount.conditionalShow(detailedView)) {
                    field.set("bendPoints (#):", row, 0, leftColumnAlignment)
                    field.set(edge.nullOrSize("bendpoints"), row, 1, rightColumnAlignment)
                    row = row + 1
                }
                
                // # of labels of port
                if(showLabelCount.conditionalShow(detailedView)) {
                    field.set("labels (#):", row, 0, leftColumnAlignment)
                    field.set(edge.nullOrSize("labels"), row, 1, rightColumnAlignment)
                    row = row + 1
                }

                // fill the KText into the ContainerRendering
                for (text : field) {
                    children += text
                }
            ]
        ]
    }
    
    /**
     * Creates a node containing all labels of this edge and creates an edge from header node to 
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
            } 
            else {
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

    /**
     * Creates a node containing all bendPoints of this edge and creates an edge from header node to 
     * 
     * @param rootNode
     *              The KNode the new created KNode will be placed in.
     * @param edge
     *              The IVariable representing the edge transformed in this transformation.
     * 
     * @return The new created KNode.
     */
    def addBendPointsNode(KNode rootNode, IVariable edge) {
        val bendPoints = edge.getVariable("bendpoints")
        
        // create container node
        val newNode = rootNode.addNodeById(bendPoints) => [
            val rendering = renderingFactory.createKRectangle => [ rendering |
                data += rendering
                if(detailedView) rendering.lineWidth = 4 else rendering.lineWidth = 2
                rendering.ChildPlacement = renderingFactory.createKGridPlacement
            ]
                
            if (bendPoints.getValue("size").equals("0")) {
                // there are no bendPoints
                rendering.addKText("(none)")
            } else {
                // create all nodes for bendPoints
                bendPoints.linkedList.forEach [ bendPoint |
                    nextTransformation(bendPoint, false)
                ]
            }
        ]
        
        // create edge from header node to bendPoints node
        edge.createTopElementEdge(bendPoints, "bendPoints")
        
        return newNode
    }
}