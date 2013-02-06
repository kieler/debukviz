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
package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

/**
 * Transformation for a variable representing a runtime variable if variable is of type "String"
 */
class StringTransformation extends AbstractDebugTransformation {

    @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions

   	/**
	 * Transformation for a variable representing a runtime variable if variable is of type "String"
	 * 
	 * {@inheritDoc}
	 */
    override transform(IVariable model, Object transformationInfo) {
        return KimlUtil::createInitializedNode() => [
            //it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 50f)
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::RIGHT)
            
            it.data += renderingFactory.createKRectangle()
      
			val node = it.addNodeById(model) 
	        if (node != null) 
	            node => [
	                it.setNodeSize(80,80);
	                it.data += renderingFactory.createKRectangle() => [
	                    it.childPlacement = renderingFactory.createKGridPlacement()
	                    it.children += renderingFactory.createKText() => [
	                        it.text = "<<"+model.type+">>"
	                        it.setForegroundColor(120,120,120)
	                    ]
	                    it.children += renderingFactory.createKText() => [
	                        it.text = model.value.valueString
	                    ]
	                ]
	            ]  
	        ]
    }
}