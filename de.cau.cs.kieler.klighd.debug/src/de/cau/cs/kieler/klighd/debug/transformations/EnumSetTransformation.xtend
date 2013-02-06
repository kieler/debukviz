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

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

/**
 * Transformation for a variable which is representing a variable of type "EnumSet"
 */
class EnumSetTransformation extends AbstractDebugTransformation {
    
    @Inject
    extension KNodeExtensions
    
    /**
	 * Transformation for a variable which is representing a variable of type "EnumSet"
	 * 
	 * {@inheritDoc}
	 */
    override transform(IVariable model, Object transformationInfo) {
        return KimlUtil::createInitializedNode() => [
            //it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 50f)
            
            it.data += renderingFactory.createKRectangle()
            
            val universe = model.getVariables("universe")
            val elementInt = Integer::parseInt(model.getValue("elements"))
            
            
            if (elementInt > 0) {
	            val elements = Integer::toBinaryString(elementInt)
	            var index = 0
	            val length = elements.length
	            
	            
	            // Iterate over enum universe and add an node for every set elements
	            while (index < universe.size && index < length) {
	            	var element = ""+elements.charAt(length-index-1)
	            	if (element == "1")
	            		it.addEnumElementNode(universe.get(index))
	            	index = index + 1;		
	            }
            }
			else
			{
				it.children += createNode() => [
					it.setNodeSize(80,80)
					it.data += renderingFactory.createKRectangle() => [
						it.children += renderingFactory.createKText() => [
							it.text = "empty"
						]
					]
				]
			}
        ]
    }
    	/**
    	 * Creates and adds a node associated with a given enum element to a given node
    	 * @param node node to which the created node will be added
    	 * @param enumElement variable representing an enum element
    	 */
        def addEnumElementNode(KNode node, IVariable enumElement) {
			node.children += enumElement.createNode() => [
				val name = enumElement.getValue("name")
				it.setNodeSize(name.length * 10,50)
				it.data += renderingFactory.createKRectangle() => [
						it.children += renderingFactory.createKText() => [
							it.text = enumElement.getValue("name")
						]  
				]
			]
    }
    
}