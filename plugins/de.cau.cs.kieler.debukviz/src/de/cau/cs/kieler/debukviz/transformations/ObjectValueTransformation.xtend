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
import de.cau.cs.kieler.core.krendering.KRenderingFactory
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.debukviz.AbstractDebugTransformation
import de.cau.cs.kieler.kiml.util.KimlUtil
import org.eclipse.debug.core.model.IVariable

/**
 * Transformation for a variable which is representing a variable of type "Number","Boolean" or "Character"
 */
class ObjectValueTransformation extends AbstractDebugTransformation {
   
    @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
    
    private static val KRenderingFactory renderingFactory = KRenderingFactory::eINSTANCE   
    
    /**
	 * Transformation for a variable which is representing a variable of type "Number","Boolean" or "Character"
	 * 
	 * {@inheritDoc}
	 */
    override transform(IVariable model, Object transformationInfo) {
        return 
        KimlUtil::createInitializedNode() => [
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
                            it.text = model.getValue("value")
                        ]
    	            ]
                ]
        ]
    }
   

    override getNodeCount(IVariable model) {
        return 1
    }
    
}