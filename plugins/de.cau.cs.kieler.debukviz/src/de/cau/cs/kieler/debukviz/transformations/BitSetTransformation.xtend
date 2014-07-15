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
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.debukviz.AbstractDebugTransformation
import de.cau.cs.kieler.kiml.util.KimlUtil
import org.eclipse.debug.core.model.IVariable

/**
 * Transformation for a variable which is representing a variable of type "BitSet"
 */
class BitSetTransformation extends AbstractDebugTransformation {
    
    @Inject
    extension KRenderingExtensions
    
    /**
     * Transformation for a variable which is representing a variable of type "BitSet"
     * 
     * {@inheritDoc}
     */
    override transform(IVariable model, Object transformationInfo) {
        return KimlUtil::createInitializedNode() => [
        	
        	it.data += renderingFactory.createKRectangle()
        	
        	it.addNodeById(model) => [
            	it.data += renderingFactory.createKRectangle() => [
	                // Iterate over used words and put bit streams together
	                var bitStream = ""
	            	for (IVariable variable : model.getVariables("words"))
	                	bitStream = bitStream + Integer::toBinaryString(Integer::parseInt(variable.value.valueString))
					
					it.childPlacement = renderingFactory.createKGridPlacement()
	                // add type
	                it.children += renderingFactory.createKText() => [
	                    it.text = "<<BitSet>>"
	                	it.setForegroundColor(120,120,120)
	                ]
	                    
	                // add words in use
	                it.children += renderingFactory.createKText() => [
	                	it.text = "Words in use: "+model.getValue("wordsInUse")
					]
	                
	                // add bitStream 
	                val streamText = renderingFactory.createKText()
	                streamText.text = bitStream
	                it.children +=  streamText
                ]        
            ]
        ]
    }
    

    override getNodeCount(IVariable model) {
        return 1
    }
    
}