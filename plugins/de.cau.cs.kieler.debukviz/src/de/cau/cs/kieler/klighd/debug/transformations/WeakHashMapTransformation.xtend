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
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.AbstractDebugTransformation
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

/**
 * Transformation for a variable which is representing a variable of type "WeakHashMap"
 */
class WeakHashMapTransformation extends AbstractDebugTransformation {
   
    @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
    @Inject 
    extension KPolylineExtensions
    @Inject 
    extension KLabelExtensions 
    
    var size = 0
	/**
	 * Transformation for a variable which is representing a variable of type "WeakHashMap"
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
            
            size = Integer::parseInt(model.getValue("size"))
            if (size > 0)   
	            model.getVariables("table").filter[variable | variable.valueIsNotNull].forEach[
	                IVariable variable | 
	                    it.createKeyValueNode(variable)
	                    val next = variable.getVariable("next");
	                    if (next.valueIsNotNull)
	                        it.createKeyValueNode(next)
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
    
    def createKeyValueNode(KNode node, IVariable variable) {
        val key = variable.getVariable("referent")
        val value = variable.getVariable("value")

        node.nextTransformation(key)
        
        node.nextTransformation(value)
    
        key.createEdgeById(value) => [
            value.createLabel(it) => [
                it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT,EdgeLabelPlacement::CENTER)
                it.setLabelSize(50,50)
                it.text = "value"
            ]
            it.data += renderingFactory.createKPolyline() => [
                it.setLineWidth(2)
                it.addArrowDecorator()
            ]
        ]
    }

    override getNodeCount(IVariable model) {
        if (size > 0)
            return size * 2
        else
            return 1
    }
    
}