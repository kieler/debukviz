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
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

/*
 * Transformation for an IVariable representing a PEdge
 * 
 * @ author tit
 */
 class PEdgeTransformation extends AbstractKielerGraphTransformation {
    @Inject
    extension KNodeExtensions
    
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

    /** Specifies when to show the id. */
	val showID= ShowTextIf::ALWAYS
    /** Specifies when to show the hashCode. */
	val showHashCode= ShowTextIf::DETAILED
    /** Specifies when to show the faces. */
	val showFaces = ShowTextIf::DETAILED
    /** Specifies when to show the parent. */
	val showParent = ShowTextIf::DETAILED
    /** Specifies when to show the source. */
	val showSource = ShowTextIf::DETAILED
    /** Specifies when to show the target. */
	val showTarget = ShowTextIf::DETAILED
    /** Specifies when to show the bendPoints. */
	val showBendPoints = ShowTextIf::DETAILED
    /** Specifies when to show the number of BendPoints. */
    val showBendPointsCount = ShowTextIf::COMPACT

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
        ]
    }
    
	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
	    var retVal = if(showPropertyMap.conditionalShow(detailedView)) 2 else 1
		return retVal
	}
    
    /**
     * Creates the header node containing basic informations for this element.
     * 
     * @param rootNode
     *              The KNode the new created KNode will be placed in.
     * @param edge
     *              The IVariable representing the edge transformed in this transformation.
     * 
     * @return The new created header KNode
     */
    def addHeaderNode(KNode rootNode, IVariable edge) { 
        rootNode.addNodeById(edge) => [
            data += renderingFactory.createKRectangle => [
                
                val table = headerNodeBasics(detailedView, edge)

                // id
	            if (showID.conditionalShow(detailedView)) {
		            table.addGridElement("id:", leftColumnAlignment)
		            table.addGridElement(edge.nullOrValue("id"), rightColumnAlignment)
	            } 

                // isDirected
	            if (showHashCode.conditionalShow(detailedView)) {
		            table.addGridElement("isDirected:", leftColumnAlignment)
		            table.addGridElement(edge.nullOrValue("isDirected"), rightColumnAlignment)
	            } 
   
                // source
	            if (showSource.conditionalShow(detailedView)) {
		            table.addGridElement("source:", leftColumnAlignment)
		            table.addGridElement(edge.nullOrTypeAndID("source"), rightColumnAlignment)
	            } 

                // target
	            if (showTarget.conditionalShow(detailedView)) {
		            table.addGridElement("target:", leftColumnAlignment)
		            table.addGridElement(edge.nullOrTypeAndID("target"), rightColumnAlignment)
	            } 

	            // parent
	            if (showParent.conditionalShow(detailedView)) {
	                table.addGridElement("parent:", leftColumnAlignment)
	                table.addGridElement(edge.nullOrTypeAndID("parent"), rightColumnAlignment)
	            }

	            // leftFace
	            if (showFaces.conditionalShow(detailedView)) {
	                table.addGridElement("leftFace:", leftColumnAlignment)
	                table.addGridElement(edge.nullOrTypeAndID("leftFace"), rightColumnAlignment)
	            }

	            // rightFace
	            if (showParent.conditionalShow(detailedView)) {
	                table.addGridElement("rightFace:", leftColumnAlignment)
	                table.addGridElement(edge.nullOrTypeAndID("rightFace"), rightColumnAlignment)
	            }

                // # of bendPoints
        	    if (showBendPointsCount.conditionalShow(detailedView)) {
		            table.addGridElement("bendPoints (#):", leftColumnAlignment)
		            table.addGridElement(edge.nullOrSize("bendPoints"), rightColumnAlignment)
	            } 

                // list of bendPoints
        	    if (showBendPoints.conditionalShow(detailedView)) {
        	    	val bendPoints = edge.getVariable("bendPoints").linkedList
	            	table.addGridElement("bendPoints (x,y):", leftColumnAlignment)
	            	
                	if (bendPoints.size == 0) {
                        // no bendPoints on edge
		            	table.addGridElement("(none)", rightColumnAlignment)
                    } else {
                    	// first bendPoint
                    	table.addGridElement(bendPoints.head.nullOrKVektor(""), rightColumnAlignment)
                        // all following bendPoints
                        bendPoints.tail.forEach[IVariable bendPoint |
                            table.addBlankGridElement
                            table.addGridElement(bendPoint.nullOrKVektor(""), rightColumnAlignment)
                        ]                        
                    }
				}
            ]
        ]
    }
}