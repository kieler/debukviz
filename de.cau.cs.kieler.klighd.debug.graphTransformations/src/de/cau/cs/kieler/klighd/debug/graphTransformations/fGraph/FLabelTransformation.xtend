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
 * Transformation for an IVariable representing a FLabel.
 * This class still uses the deprecated KTextIterableField class.
 * 
 * @ author tit
 */
 class FLabelTransformation extends AbstractKielerGraphTransformation {
    @Inject
    extension KNodeExtensions
    
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
        
    /** Specifies when to show the text. */
    val showText = ShowTextIf::ALWAYS
    /** Specifies when to show the edge. */
    val showEdge = ShowTextIf::DETAILED
    /** Specifies when to show the position. */
    val showPos = ShowTextIf::DETAILED
    /** Specifies when to show the size. */
    val showSize = ShowTextIf::DETAILED

    /**
     * {@inheritDoc}
     */
    override transform(IVariable label, Object transformationInfo) {
        detailedView = transformationInfo.isDetailed

        return KimlUtil::createInitializedNode => [
            addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            addLayoutParam(LayoutOptions::SPACING, spacing)

			addInvisibleRendering
            addHeaderNode(label)
            
            // add propertyMap
            if(showPropertyMap.conditionalShow(detailedView))
                addPropertyMapNode(label.getVariable("propertyMap"), label)
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
     * @param edge
     *              The IVariable representing the label transformed in this transformation.
     * 
     * @return The new created header KNode.
     */
    def addHeaderNode(KNode rootNode, IVariable label) { 
        rootNode.addNodeById(label) => [
            data += renderingFactory.createKRectangle => [

                val field = new KTextIterableField(topGap, rightGap, bottomGap, leftGap, vGap, hGap)
                headerNodeBasics(field, detailedView, label, leftColumnAlignment, rightColumnAlignment)
                var row = field.rowCount
                
                // text of label
                if(showText.conditionalShow(detailedView)) {
                    field.set("text:", row, 0, leftColumnAlignment)
                    field.set(label.nullOrValue("text"), row, 1, rightColumnAlignment)
                    row = row + 1
                }

                // edge of label
                if(showEdge.conditionalShow(detailedView)) {
                    field.set("edge:", row, 0, leftColumnAlignment)
                    field.set(label.nullOrTypeAndID("edge"), row, 1, rightColumnAlignment)
                    row = row + 1
                }
                
                // position of label
                if(showPos.conditionalShow(detailedView)) {
                    field.set("position (x,y):", row, 0, leftColumnAlignment)
                    field.set(label.nullOrKVektor("position"), row, 1, rightColumnAlignment)
                    row = row + 1
                }

                // size of label
                if(showSize.conditionalShow(detailedView)) {
                    field.set("size (x,y):", row, 0, leftColumnAlignment)
                    field.set(label.nullOrKVektor("size"), row, 1, rightColumnAlignment)
                    row = row + 1
                }

                // fill the KText into the ContainerRendering
                for (text : field) {
                    children += text
                }
            ]
        ]
    }
}