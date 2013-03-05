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
 * Transformation for an IVariable representing a FBendpoint
 * 
 * @ author tit
 */
class FBendpointTransformation extends AbstractKielerGraphTransformation {
    
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

    /** Specifies when to show the containing edge. */
    val showEdge = ShowTextIf::ALWAYS
    /** Specifies when to show the position. */
    val showPosition = ShowTextIf::ALWAYS
    /** Specifies when to show the size. */
    val showSize = ShowTextIf::DETAILED
    
    /**
     * {@inheritDoc}
     */
     override transform(IVariable bendPoint, Object transformationInfo) {
        detailedView = transformationInfo.isDetailed
        
         return KimlUtil::createInitializedNode => [
            addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            addLayoutParam(LayoutOptions::SPACING, spacing)

			addInvisibleRendering
            addHeaderNode(bendPoint)
            
            // add propertyMap
            if(showPropertyMap.conditionalShow(detailedView))
                addPropertyMapNode(bendPoint.getVariable("propertyMap"), bendPoint)
        ]
    }

	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
		return if(showPropertyMap.conditionalShow(detailedView)) 2 else 1
	}

    /**
     * Creates the header node containing basic informations for this element and adds it to the rootNode.
     * 
     * @param rootNode
     *              The KNode the new created KNode will be placed in.
     * @param layer
     *              The IVariable representing the bendPoint transformed in this transformation.
     * 
     * @return The new created header KNode.
     */
    def addHeaderNode(KNode rootNode, IVariable bendPoint) {
        rootNode.addNodeById(bendPoint) => [
            data += renderingFactory.createKEllipse => [
                
                val table = headerNodeBasics(detailedView, bendPoint)
                
                // associated edge
                if(showEdge.conditionalShow(detailedView)) {
                    table.addGridElement("edge:", leftColumnAlignment) 
                    table.addGridElement(bendPoint.nullOrValue("edge"), rightColumnAlignment) 
                }

                // position of bendPoint
                if(showPosition.conditionalShow(detailedView)) {
                    table.addGridElement("position (x,y):", leftColumnAlignment) 
                    table.addGridElement(bendPoint.nullOrKVektor("position"), rightColumnAlignment) 
                }

                // size of bendPoint
                if(showSize.conditionalShow(detailedView)) {
	                table.addGridElement("size (x,y):", leftColumnAlignment) 
	                table.addGridElement(bendPoint.nullOrKVektor("size"), rightColumnAlignment)
                }
            ]
        ]
    }
}