/*
 * DebuKViz - Kieler Debug Visualization
 * 
 * A part of OpenKieler
 * https://github.com/OpenKieler
 * 
 * Copyright 2014 by
 * + Christian-Albrechts-University of Kiel
 *   + Department of Computer Science
 *     + Real-Time and Embedded Systems Group
 * 
 * This code is provided under the terms of the Eclipse Public License (EPL).
 * See the file epl-v10.html for the license text.
 */
package de.cau.cs.kieler.debukviz.transformations

import com.google.inject.Inject
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KContainerRenderingExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.debukviz.VariableTransformation
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.KlighdConstants
import org.eclipse.debug.core.model.IVariable

/**
 * Transformation for a variable representing a runtime variable if variable is of type "String"
 */
class StringTransformation extends VariableTransformation {

    @Inject extension KColorExtensions
    @Inject extension KContainerRenderingExtensions
    @Inject extension KRenderingExtensions
    
    val NODE_INSETS = 5

   	/**
	 * Transformation for a variable representing a runtime variable if variable is of type "String"
	 * 
	 * {@inheritDoc}
	 */
    override transform(IVariable model, Object transformationInfo) {
        return KimlUtil::createInitializedNode() => [
            // FIXME: Shouldn't we check this before we create the actual node?
			val node = it.addNodeById(model) 
	        if (node != null) {
	            node.addRoundedRectangle(5, 5) => [ rect |
	                // Design stuff
	                rect.foreground = "gray".color
	                rect.setBackgroundGradient("#FFFFFF".color, "#F0F0F0".color, 90)
	                rect.shadow = "black".color;
                    rect.shadow.XOffset = 4;
                    rect.shadow.YOffset = 4;
                    
                    // Placement algorithm
                    rect.setGridPlacement(1)
                        .from(LEFT, NODE_INSETS, 0, TOP, NODE_INSETS, 0)
                        .to(RIGHT, NODE_INSETS, 0, BOTTOM, NODE_INSETS, 0)
                    
                    rect.children += renderingFactory.createKText() => [
                        it.text = model.type
                        it.fontSize = KlighdConstants.DEFAULT_FONT_SIZE - 2
                        it.foreground = "#627090".color
                    ]
                    rect.children += renderingFactory.createKText() => [
                        it.text = "\"" + model.value.valueString + "\""
                        it.setForegroundColor(50, 50, 50)
                    ]
                ]
            }
        ]
    }

    override getNodeCount(IVariable model) {
       return 1
    }
    
}