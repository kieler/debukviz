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
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
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
 * Transformation for a variable which is representing a variable of type "HashMap" and "HashTable"
 */
class KeyValueTransformation extends VariableTransformation {
    
    override transform(IVariable variable, KNode graph, VariableTransformationContext context) {
        throw new UnsupportedOperationException("TODO: auto-generated method stub")
    }
   
//    @Inject extension KColorExtensions
//    @Inject extension KLabelExtensions
//    @Inject extension KNodeExtensions
//    @Inject extension KPolylineExtensions
//    @Inject extension KRenderingExtensions
//    
//    var size = 0
//    
//	/**
//	 * Transformation for a variable which is representing a variable of type "HashMap" and "HashTable"
//	 * 
//	 * {@inheritDoc}
//	 */
//    override transform(IVariable model, Object transformationInfo) {
//        return KimlUtil::createInitializedNode() => [
//            //it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
//            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
//            it.addLayoutParam(LayoutOptions::SPACING, 50f)
//            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::RIGHT)
//            
//            it.data += renderingFactory.createKRectangle()
//            val sizeString = model.getValue("size")
//            if (!sizeString.equals("null"))
//                size = Integer::parseInt(sizeString)
//            else 
//                size = Integer::parseInt(model.getValue("count"))
//            if (size > 0)   
//	            // Add a pair of nodes for every entry that is not null
//	            model.getVariables("table").filter[variable | variable.valueIsNotNull].forEach[
//	                IVariable variable | 
//	                    it.createKeyValueNode(variable)
//	                    val next = variable.getVariable("next");
//	                    if (next.valueIsNotNull)
//	                        it.createKeyValueNode(next)
//	            ]
//			else
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
//     * Adds a pair of nodes associated with the key and the value stored in a given variable to the given node.
//     * The pair is connected by an edge
//     * @param node node to which the created node will be added
//     * @param variable variable in which the variable representing a key element and the variable representing a value element are stored
//     */
//    def createKeyValueNode(KNode node, IVariable variable) {
//       	val key = variable.getVariable("key")
//       	val value = variable.getVariable("value")
//
//	   	node.nextTransformation(key)
//	   	
//	   	node.nextTransformation(value)
//	
//        key.createEdgeById(value) => [
//            value.createLabel(it) => [
//                it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT,EdgeLabelPlacement::CENTER)
//                it.setLabelSize(50,50)
//                it.text = "value"
//            ]
//            it.data += renderingFactory.createKPolyline() => [
//                it.setLineWidth(2)
//                it.addArrowDecorator()
//                it.foreground = "#323232".color
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