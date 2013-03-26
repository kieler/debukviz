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
 * Transformation for an IVariable representing a LPort
 * 
 * @ author tit
 */
 class LPortTransformation extends AbstractKielerGraphTransformation {
    
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
    /** Specifies when to show the node with connected edges. */
    val showEdgesNode = ShowTextIf::DETAILED
    /** Specifies when to show the node with added labels. */
    val showLabelsNode = ShowTextIf::DETAILED

    /** Specifies when to show the number of edges. */
    val showEdgesCount = ShowTextIf::COMPACT
    /** Specifies when to show the number of labels. */
    val showLabelsCount = ShowTextIf::COMPACT
    /** Specifies when to show the size. */
    val showSize = ShowTextIf::DETAILED
    /** Specifies when to show the side. */
    val showSide = ShowTextIf::ALWAYS
    /** Specifies when to show the position. */
    val showPosition = ShowTextIf::DETAILED
    /** Specifies when to show the owner. */
    val showOwner = ShowTextIf::DETAILED
    /** Specifies when to show the margin. */
    val showMargin = ShowTextIf::DETAILED
    /** Specifies when to show the anchor. */
    val showAnchor = ShowTextIf::DETAILED
    /** Specifies when to show the hashCode. */
    val showHashCode = ShowTextIf::DETAILED
    
    /**
     * {@inheritDoc}
     */
    override transform(IVariable port, Object transformationInfo) {
        detailedView = transformationInfo.isDetailed

        return KimlUtil::createInitializedNode => [
            addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            addLayoutParam(LayoutOptions::SPACING, spacing)

			addInvisibleRendering
            addHeaderNode(port)

            // add propertyMap
            if(showPropertyMap.conditionalShow(detailedView))
                addPropertyMapNode(port.getVariable("propertyMap"), port)
                
            // add incoming/outgoing edges node
            if(showEdgesNode.conditionalShow(detailedView)) {
                addEdgesNode(port, port.getVariable("incomingEdges"))
                addEdgesNode(port, port.getVariable("outgoingEdges"))
            }
                
            // add labels
            if(showLabelsNode.conditionalShow(detailedView))
                addLabelsNode(port)
        ]
    }
    
	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
	    var retVal = if(showPropertyMap.conditionalShow(detailedView)) 2 else 1
	    if(showEdgesNode.conditionalShow(detailedView)) retVal = retVal + 1
		if(showLabelsNode.conditionalShow(detailedView)) retVal = retVal + 1
	    return retVal
	}

    /**
     * Creates the header node containing basic informations for this element.
     * 
     * @param rootNode
     *              The KNode the new created KNode will be placed in.
     * @param port
     *              The IVariable representing the port transformed in this transformation.
     * 
     * @return The new created header KNode.
     */
    def addHeaderNode(KNode rootNode, IVariable port) { 
        rootNode.addNodeById(port) => [
            data += renderingFactory.createKRectangle => [

                val table = headerNodeBasics(detailedView, port)

                // id of node
                table.addGridElement("id:", leftColumnAlignment)
                if(detailedView) {
                    table.addGridElement(port.nullOrValue("id"), rightColumnAlignment)
                } else {
                    table.addGridElement(port.nullOrValue("id") + port.getValueString, rightColumnAlignment)
                }
   
                // hashCode of port
                if(showHashCode.conditionalShow(detailedView)) {
                    table.addGridElement("hashCode:", leftColumnAlignment)
                    table.addGridElement(port.nullOrValue("hashCode"), rightColumnAlignment)
                }
            
                // anchor of port
                if(showAnchor.conditionalShow(detailedView)) {
                    table.addGridElement("anchor (x,y):", leftColumnAlignment)
                    table.addGridElement(port.nullOrKVektor("anchor"), rightColumnAlignment)
                }

                // margin of port
                if(showMargin.conditionalShow(detailedView)) {
                    table.addGridElement("margin (t,r,b,l):", leftColumnAlignment)
                    table.addGridElement(port.nullOrLInsets("margin"), rightColumnAlignment)
                }

                // owner of port
                if(showOwner.conditionalShow(detailedView)) {
                    table.addGridElement("owner:", leftColumnAlignment)
                    table.addGridElement(port.nullOrTypeAndHashAndIDs("owner"), rightColumnAlignment)
                }

                // position of port
                if(showPosition.conditionalShow(detailedView)) {
                    table.addGridElement("pos (x,y):", leftColumnAlignment)
                    table.addGridElement(port.nullOrKVektor("pos"), rightColumnAlignment)
                }
                
                // side of port
                if(showSide.conditionalShow(detailedView)) {
                    table.addGridElement("side:", leftColumnAlignment)
                    table.addGridElement(port.nullOrName("side"), rightColumnAlignment)
                }

                // size of port
                if(showSize.conditionalShow(detailedView)) {
                    table.addGridElement("size (x,y):", leftColumnAlignment)
                    table.addGridElement(port.nullOrKVektor("size"), rightColumnAlignment)
                }

                // # of incoming/outgoing edges of port
                if(showEdgesCount.conditionalShow(detailedView)) {
                    table.addGridElement("incomingEdges (#):", leftColumnAlignment)
                    table.addGridElement(port.nullOrSize("incomingEdges"), rightColumnAlignment)
                    table.addGridElement("outgoingEdges (#):", leftColumnAlignment)
                    table.addGridElement(port.nullOrSize("outgoingEdges"), rightColumnAlignment)
                }

                // # of labels of port
                if(showLabelsCount.conditionalShow(detailedView)) {
                    table.addGridElement("labels (#):", leftColumnAlignment)
                    table.addGridElement(port.nullOrSize("labels"), rightColumnAlignment)
                }
            ]
        ]
    }

    /**
     * Creates a node containing all labels of this port.
     * 
     * @param rootNode
     *              The KNode the new created KNode will be placed in.
     * @param port
     *              The IVariable representing the port transformed in this transformation.
     * 
     * @return The new created KNode.
     */
    def addLabelsNode(KNode rootNode, IVariable port) {
        val labels = port.getVariable("labels")

        // create container node
        val newNode = rootNode.addNodeById(labels) => [
            val rendering = renderingFactory.createKRectangle => [ rendering |
                data += rendering
                if(detailedView) rendering.lineWidth = 4 else rendering.lineWidth = 2
            ]
            
            if (labels.getValue("size").equals("0")) {
                // no labels
                rendering.addKText("(none)")
            } else {
                // create all labels
                labels.linkedList.forEach [ label |
                    nextTransformation(label, false)
                ]
            }
        ]
        // create edge from header node to labels node
        port.createTopElementEdge(labels, "labels")
        
        return newNode
    }
    
    /**
     * Creates a node containing all edges of this port.
     * 
     * @param rootNode
     *              The KNode the new created KNode will be placed in.
     * @param port
     *              The IVariable representing the port transformed in this transformation.
     * 
     * @return The new created header KNode.
     */
    def addEdgesNode(KNode rootNode, IVariable port, IVariable edges) {
        // create container node
        val newNode = rootNode.addNodeById(edges) => [
            val rendering = renderingFactory.createKRectangle => [ rendering |
                data += rendering
                if(detailedView) rendering.lineWidth = 4 else rendering.lineWidth = 2
            ]

            if (edges.getValue("size").equals("0")) {
                // no edges
                rendering.addKText("(none)")
            } else {
                // create all edges
                edges.linkedList.forEach [ edge | nextTransformation(edge, false)]
            }
        ]
        
        // create edge from header node to labels node
        port.createTopElementEdge(edges, edges.name)
        
        return newNode
    }
}