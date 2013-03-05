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
 * Transformation for a IVariable representing a FNode.
 * 
 * @ author tit
 */
 class FNodeTransformation extends AbstractKielerGraphTransformation {
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
    
    val showID = ShowTextIf::ALWAYS
    val showLabel = ShowTextIf::ALWAYS
    val showParent = ShowTextIf::DETAILED
    val showDisplacement = ShowTextIf::DETAILED
    val showPosition = ShowTextIf::DETAILED
    val showSize = ShowTextIf::DETAILED

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
     * As there is no writeDotGraph in FGraph we don't have a prototype for formatting these nodes.
     * 
     * @param rootNode
     *              The KNode the new created KNode will be placed in.
     * @param edge
     *              The IVariable representing the node transformed in this transformation.
     * 
     * @return The new created header KNode.
     */
     def addHeaderNode(KNode rootNode, IVariable node) { 
        rootNode.addNodeById(node) => [
            data += renderingFactory.createKRectangle => [
                
                val table = headerNodeBasics(detailedView, node)

                // id of node
                if(showID.conditionalShow(detailedView)) {
                    table.addGridElement("id:", leftColumnAlignment)
                    table.addGridElement(node.nullOrValue("id"), rightColumnAlignment)
                }
                
                // label of node (there is only one)
                if(showLabel.conditionalShow(detailedView)) {
                    table.addGridElement("label:", leftColumnAlignment)
                    table.addGridElement(node.nullOrValue("label"), rightColumnAlignment)
                }

                // parent
                if(showParent.conditionalShow(detailedView)) {
	                table.addGridElement("parent:", leftColumnAlignment)
                    table.addGridElement(node.nullOrTypeAndID("parent"), rightColumnAlignment)
                }
                    
                // displacement
                if(showDisplacement.conditionalShow(detailedView)) {
	                table.addGridElement("displacement (x,y):", leftColumnAlignment)
	                table.addGridElement(node.nullOrKVektor("displacement"), rightColumnAlignment)
                }

                // position
                if(showPosition.conditionalShow(detailedView)) {
	                table.addGridElement("position (x,y):", leftColumnAlignment)
	                table.addGridElement(node.nullOrKVektor("position"), rightColumnAlignment)
                }
                    
                // size
                if(showSize.conditionalShow(detailedView)) {
	                table.addGridElement("size (x,y):", leftColumnAlignment)
	                table.addGridElement(node.nullOrKVektor("size"), rightColumnAlignment)
                }
            ]
        ]
    }
}