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
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

/*
 * Transformation for an IVariable representing a LLabel.
 * 
 * @ author tit
 */
class LLabelTransformation extends AbstractKielerGraphTransformation {
    @Inject
    extension KNodeExtensions
        
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
        
    /** Specifies when to show the ID. */
    val showID = ShowTextIf::ALWAYS
    /** Specifies when to show the hashCode. */
    val showHashCode = ShowTextIf::ALWAYS
    /** Specifies when to show the text. */
    val showText = ShowTextIf::DETAILED
    /** Specifies when to show the position. */
    val showPos = ShowTextIf::DETAILED
    /** Specifies when to show the size. */
    val showSize = ShowTextIf::DETAILED
    /** Specifies when to show the side. */
    val showSide = ShowTextIf::DETAILED

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
     * @param label
     *              The IVariable representing the label transformed in this transformation.
     * 
     * @return The new created header KNode.
     */
     def addHeaderNode(KNode rootNode, IVariable label) { 
        rootNode.addNodeById(label) => [
            data += renderingFactory.createKRectangle => [

                val table = headerNodeBasics(detailedView, label)
                
                // id of label
                if(showID.conditionalShow(detailedView)) {
                    table.addGridElement("id:", leftColumnAlignment) 
                    table.addGridElement(label.nullOrValue("id"), rightColumnAlignment) 
                }
   
                // hashCode of label
                if(showHashCode.conditionalShow(detailedView)) {
                    table.addGridElement("hashCode:", leftColumnAlignment) 
                    table.addGridElement(label.nullOrValue("hashCode"), rightColumnAlignment) 
                }

                // text of label
                if(showText.conditionalShow(detailedView)) {
                    table.addGridElement("text:", leftColumnAlignment) 
                    table.addGridElement(label.nullOrValue("text"), rightColumnAlignment) 
                }
                
                // position of label
                if(showPos.conditionalShow(detailedView)) {
                    table.addGridElement("pos (x,y):", leftColumnAlignment) 
                    table.addGridElement(label.nullOrKVektor("pos"), rightColumnAlignment) 
                }
                    
                // size of label
                if(showSize.conditionalShow(detailedView)) {
                    table.addGridElement("size (x,y):", leftColumnAlignment) 
                    table.addGridElement(label.nullOrKVektor("size"), rightColumnAlignment) 
                }

                // side of label
                if(showSide.conditionalShow(detailedView)) {
                    table.addGridElement("side::", leftColumnAlignment) 
                    table.addGridElement(label.nullOrName("side"), rightColumnAlignment) 
                }
            ]
        ]
    }
}