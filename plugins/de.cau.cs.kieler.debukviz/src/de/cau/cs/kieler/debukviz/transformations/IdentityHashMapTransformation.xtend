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
import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.debukviz.VariableTransformation
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import org.eclipse.debug.core.model.IVariable
import de.cau.cs.kieler.debukviz.VariableTransformationContext

/**
 * Transformation for a variable which is representing a variable of type "IdentityHashMap"
 */
class IdentityHashMapTransformation extends VariableTransformation {
    
    override transform(IVariable variable, KNode graph, VariableTransformationContext context) {
        throw new UnsupportedOperationException("TODO: auto-generated method stub")
    }
   
//    @Inject
//    extension KNodeExtensions
//    @Inject
//    extension KRenderingExtensions
//    @Inject 
//    extension KPolylineExtensions 
//    @Inject 
//    extension KLabelExtensions 
//    
//    var size = 0
//   	/**
//	 * Transformation for a variable which is representing a variable of type "IdentityHashMap"
//	 * 
//	 * {@inheritDoc}
//	 */
//    override transform(IVariable model, Object transformationInfo) {
//        return KimlUtil::createInitializedNode() => [
//            //it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
//            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
//            it.addLayoutParam(LayoutOptions::SPACING, 50f)
//            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::UP)
//            
//            it.data += renderingFactory.createKRectangle()
//            
//            // Gather necessary information
//            var index = 0
//            size = Integer::parseInt(model.getValue("size"))
//            val table = model.getVariables("table")
//            if (size > 0)
//	            // Add a pair of nodes associated with key and value for every entry
//	            while (size > 0) {
//	            	// element is a key if index % 2 == 0 and element not null
//	            	var IVariable key = table.get(index)
//	            	if (key.valueIsNotNull) {
//	            		// the element after the key element is the value element
//	                	var IVariable value = table.get(index+1)
//	                	// add the pair of nodes
//	                	it.addKeyValueNode(key,value)
//	                	size = size - 1
//	            	}
//	            	index = index + 2
//	            }
//            else
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
//        ]
//    }
//    
//    /**
//     * Adds a pair of nodes associated with the given key and the given value to the given node
//     * The pair is connected by an edge
//     * @param node node to which the created node will be added
//     * @param key variable representing a key
//     * @param value variable representing a value
//     */
//    def addKeyValueNode(KNode node, IVariable key, IVariable value) {
//        node.nextTransformation(key)
//        node.nextTransformation(value)
//        
//        key.createEdgeById(value) => [
//            value.createLabel(it) => [
//                it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT,EdgeLabelPlacement::CENTER)
//                it.text = "value";
//            ]
//            it.data += renderingFactory.createKPolyline() => [
//                it.setLineWidth(2);
//                it.addArrowDecorator();
//            ]
//        ]
//    }
//
//    override getNodeCount(IVariable model) {
//        if (size > 0)
//            return size * 2
//        else
//            return 1
//    }
    
}