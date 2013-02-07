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
import de.cau.cs.kieler.core.krendering.KText
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation
import java.util.LinkedList
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable
import org.eclipse.jdt.debug.core.IJavaArray
import org.eclipse.jdt.debug.core.IJavaObject
import org.eclipse.jdt.debug.core.IJavaPrimitiveValue
import org.eclipse.jdt.debug.core.IJavaValue

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*
import org.eclipse.jdt.debug.core.IJavaModifiers

/**
 * Transformation for a variable representing a runtime variable which is an array
 */
class ArrayTransformation extends AbstractDebugTransformation {
       
    @Inject 
    extension KPolylineExtensions   
    @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
    @Inject
    extension KLabelExtensions


    var size = 0
    
   	/**
	 * Transformation for a variable representing a runtime variable which is an array
	 * 
	 * {@inheritDoc}
	 */
    override transform(IVariable model, Object transformationInfo) {
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            //it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 50f)
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::RIGHT)
            
            it.data += renderingFactory.createKRectangle()

            size = size + 1
            it.createArrayNode(model)
        ]
    }
    
    def boolean isNullObject(IVariable variable) {
        return variable.type.equals("Object")
    }
    
    def boolean isPrimitiveOrNull(IVariable variable) {
        val value = variable.value
        return value instanceof IJavaPrimitiveValue || 
              (value instanceof IJavaValue && (value as IJavaValue).isNull())
    }
    
    def createArrayNode(KNode rootNode, IVariable choice) {
            if (choice.value instanceof IJavaArray) {
	            val node = rootNode.addNodeById(choice)
	         	if (node != null) {
    	         	node => [
    	         		it.setNodeSize(80,80);
    	            	it.data += renderingFactory.createKRectangle() => [
    	                	it.childPlacement = renderingFactory.createKGridPlacement()
    	                	it.children += renderingFactory.createKText() => [
    	                		it.text = choice.type
    	            		]
    	            	]
    	            ]
    	            
                	choice.value.variables.forEach[
                    	IVariable variable |
                    	size = size + 1
                    	rootNode.createArrayNode(variable)
                    	choice.createEdgeById(variable) => [
                    		variable.createLabel(it) => [
                                it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::CENTER)
                                it.setLabelSize(50,50)
                                it.text = variable.name.replaceAll("[\\[\\]]","");
                    		]
        	                it.data += renderingFactory.createKPolyline() => [
                                it.setLineWidth(2)
                                it.addArrowDecorator()
                            ]
                    	]
                    ]       
                }  
        } else if (!choice.isPrimitiveOrNull && !choice.isNullObject) {
                rootNode.nextTransformation(choice)
        } else
        	rootNode.createValueNode(choice)
    }
    
    def createValueNode(KNode rootNode, IVariable choice) {
        size = size + 1
        val node = rootNode.addNodeById(choice) 
        if (node != null) 
            node => [
                it.setNodeSize(80,80);
                it.data += renderingFactory.createKRectangle() => [
                    it.childPlacement = renderingFactory.createKGridPlacement()
                    it.children += renderingFactory.createKText() => [
                        it.text = "<<"+choice.type+">>"
                        it.setForegroundColor(120,120,120)
                    ]
                    it.children += renderingFactory.createKText() => [
                        it.text = choice.value.valueString
                    ]
                ]
            ]
    }
   

    override getNodeCount(IVariable model) {
        return size
    }
    
}