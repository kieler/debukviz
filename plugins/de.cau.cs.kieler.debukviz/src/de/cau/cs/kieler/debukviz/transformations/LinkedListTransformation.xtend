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
 * Transformation for a variable which is representing a variable of type "LinkedList"
 */
class LinkedListTransformation extends VariableTransformation {
    
    override transform(IVariable variable, KNode graph, VariableTransformationContext context) {
        throw new UnsupportedOperationException("TODO: auto-generated method stub")
    }
    
//    @Inject
//    extension KNodeExtensions    
//    @Inject 
//    extension KPolylineExtensions 
//    @Inject
//    extension KRenderingExtensions
//    @Inject
//    extension KLabelExtensions
//    
//    var size = 0
//	/**
//	 * Transformation for a variable which is representing a variable of type "LinkedList"
//	 * 
//	 * {@inheritDoc}
//	 */
//    override transform(IVariable variable, Object transformationInfo) {
//        return KimlUtil::createInitializedNode() => [
//            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
//            //it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
//            it.addLayoutParam(LayoutOptions::SPACING, 50f)
//            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::RIGHT)
//            
//            it.data += renderingFactory.createKRectangle()
//            
//            size = Integer::parseInt(variable.getValue("size"))
//            if (size > 0)
//              it.addChildNode(variable.getVariable("header","next"),size-1)
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
//     * Gets the variable with name "element" which is stored in a given variable.
//     * Just syntactic sugar
//     * @param variable variable in which the variable with name "element" is stored
//     * @return variable with name "element"
//     */
//    def getElement(IVariable variable) {
//    	return variable.getVariable("element")
//    }  
//    
//    
//    /**
//     * Creates and adds a node associated with an entry and adds an edge between this and the next entry to a given node
//     * @param rootNode node to which the created node will be added
//     * @param variable variable representing the actual entry
//     * @param size remaining count of elements that had to be transformed
//     */
//    def addChildNode(KNode rootNode, IVariable variable, int size) {
//       rootNode.nextTransformation(variable.element)
//       if (size > 0) {
//           val next = variable.getVariable("next")
//           rootNode.addChildNode(next,size-1)
//           variable.element.createEdgeById(next.element) => [
//               next.createLabel(it) => [
//                     it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::CENTER)
//                     it.setLabelSize(50,50)
//                     it.text = "next"
//                 ]
//                it.data += renderingFactory.createKPolyline() => [
//                    it.setLineWidth(2)
//                    it.addArrowDecorator();
//                ]
//            ]
//       }
//    }
//
//    override getNodeCount(IVariable model) {
//        if (size > 0)
//            return size
//        else
//            return 1
//    }
    
}