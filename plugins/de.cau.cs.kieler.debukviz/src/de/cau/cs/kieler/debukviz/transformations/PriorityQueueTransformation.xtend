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
package de.cau.cs.kieler.debukviz.transformations

import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.debukviz.AbstractDebugTransformation
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

/**
 * Transformation for a variable which is representing a variable of type "PriorityQueue"
 */
class PriorityQueueTransformation extends AbstractDebugTransformation {
    
    @Inject
    extension KNodeExtensions 
    @Inject 
    extension KPolylineExtensions 
    @Inject
    extension KRenderingExtensions
    
    var IVariable previous = null
    var size = 0
	/**
	 * Transformation for a variable which is representing a variable of type "PriorityQueue"
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
            
            // Gather necessary information
            size = Integer::parseInt(model.getValue("size"))
            
            if (size > 0)
	            // Perform nextTransformation and add an edge to the previous element for every element in the queue
	            model.getVariables("queue").subList(0,size).forEach[
	                IVariable variable |
	                    it.nextTransformation(variable)
	                    if (previous != null)
	                        previous.createEdgeById(variable) => [
	                            it.data += renderingFactory.createKPolyline() => [
	                                it.setLineWidth(2)
	                                it.addArrowDecorator();
	                            ]
	                        ]
	                    previous = variable
	                ]
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
    

    override getNodeCount(IVariable model) {
        if (size > 0)
            return size
        else
            return 1
    }
    
}