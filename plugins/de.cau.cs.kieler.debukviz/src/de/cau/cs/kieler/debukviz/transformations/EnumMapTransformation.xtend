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

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.debukviz.AbstractDebugTransformation
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

/**
* Transformation for a variable which is representing a variable of type "EnumMap"
*/
class EnumMapTransformation extends AbstractDebugTransformation {
   
    @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
    @Inject 
    extension KPolylineExtensions 
    @Inject 
    extension KLabelExtensions 
    
    /**
	 * Transformation for a variable which is representing a variable of type "EnumMap"
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
            val keyUniverse = model.getVariables("keyUniverse")
            val size = Integer::parseInt(model.getValue("size"))
            var index = 0;
            
            if (size > 0)
	            // Iterate over the list of values "vals" and add a pair of nodes for key and value
	            for (value : model.getVariables("vals")) {
	            	if (value.valueIsNotNull)
	                	it.addKeyValueNode(keyUniverse.get(index),value)
	                index = index + 1;
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
     * Creates and adds a pair of nodes associated with the given key and with the given value to the given rootNode
     * The pair is connected by an edge
     * @param rootNode node to which die pair of nodes will be added
     * @param key variable representing the key of the current entry
     * @param value variable representing the value of the current entry
     */
    def addKeyValueNode(KNode rootNode, IVariable key, IVariable value) {
		// Add key node
		val node = rootNode.addNodeById(key)
		if (node != null)
			node => [
				val name= key.getValue("name")
				it.setNodeSize(name.length * 20,50)
				it.data += renderingFactory.createKRectangle() => [
					it.children += renderingFactory.createKText() => [
						it.text = name
					]
				] 	
			]

		// Add value node
		rootNode.nextTransformation(value)
		
		// Add edge between key node and value node
		key.createEdgeById(value) => [
            value.createLabel(it) => [
                it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT,EdgeLabelPlacement::CENTER)
                it.text = "value";
                it.setLabelSize(50,50)
            ]
        	it.data += renderingFactory.createKPolyline() => [
            	it.setLineWidth(2);
            	it.addArrowDecorator();
        	];
    	]; 
    }

    override getNodeCount(IVariable model) {
        val size = Integer::parseInt(model.getValue("size")) 
        if (size > 0)
            return size * 2
        else 
            return 1
    }
    
}