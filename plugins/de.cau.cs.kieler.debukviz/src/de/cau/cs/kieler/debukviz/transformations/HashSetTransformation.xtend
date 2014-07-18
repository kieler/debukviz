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
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.debukviz.VariableTransformation
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import org.eclipse.debug.core.model.IVariable
import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.debukviz.VariableTransformationContext

/**
 * Transformation for a variable which is representing a variable of type "HashSet"
 */
class HashSetTransformation extends VariableTransformation {
    
    override transform(IVariable variable, KNode graph, VariableTransformationContext context) {
        throw new UnsupportedOperationException("TODO: auto-generated method stub")
    }
   
//    @Inject
//    extension KNodeExtensions
//    
//    var size = 0
//    /**
//	 * Transformation for a variable which is representing a variable of type "HashSet"
//	 * 
//	 * {@inheritDoc}
//	 */
//    override transform(IVariable model, Object transformationInfo) {
//        return KimlUtil::createInitializedNode() => [
//            //it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
//            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
//            it.addLayoutParam(LayoutOptions::SPACING, 50f)
//            
//            it.data += renderingFactory.createKRectangle()
//            
//            size = Integer::parseInt(model.getValue("map","size"))
//            if (size > 0)
//	            // Iterate over the table of the map and perform nextTransformation for every not null value
//	            model.getVariables("map","table").filter[variable | variable.valueIsNotNull].forEach[
//	                IVariable variable | 
//	               	it.nextTransformation(variable.getVariable("key"))
//	               	val next = variable.getVariable("next");
//	               	if (next.valueIsNotNull)
//	               	   it.nextTransformation(next.getVariable("key"))
//	       		]
//	       	else
//			{
//				it.children += createNode() => [
//					it.setNodeSize(80,80)
//					it.data += renderingFactory.createKRectangle() => [
//						it.children += renderingFactory.createKText() => [
//							it.text = "empty"
//						]
//					]
//				]
//			}
//		]
//    }
//
//    override getNodeCount(IVariable model) {
//        if (size > 0)
//            return size
//        else
//            return 1
//    }
    
}