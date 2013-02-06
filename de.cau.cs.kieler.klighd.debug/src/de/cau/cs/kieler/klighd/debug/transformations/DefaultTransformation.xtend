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

class DefaultTransformation extends AbstractDebugTransformation {
       
    @Inject 
    extension KPolylineExtensions   
    @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
    @Inject
    extension KLabelExtensions

   	/**
	 * Transformation for a variable representing a runtime variable if no specific transformation is registered as an extension
	 */
    override transform(IVariable model, Object transformationInfo) {
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            //it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 50f)
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::RIGHT)
            
            it.data += renderingFactory.createKRectangle()
      
            // primitive datatypes or null or null object
            if (model.isPrimitiveOrNull || model.isNullObject)
               	it.createValueNode(model)
            // objecttypes
            else if (model.isObject) {
            	it.createObjectNode(model)
            }   
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
    
    def boolean isObject(IVariable variable) {
        return variable.value instanceof IJavaObject
    }
    
    def createValueNode(KNode rootNode, IVariable choice) {
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
    
    def filterVariable(IVariable variable) {
        if (variable instanceof IJavaModifiers) {
            val mod = variable as IJavaModifiers
            return !mod.isStatic()
        }
    }
    
    def createObjectNode(KNode rootNode, IVariable choice) {
            val thisNode = rootNode.addNodeById(choice)
            if (thisNode != null) {
                val primitiveList = new LinkedList<KText>()
                choice.value.variables.filter[it.filterVariable].forEach[IVariable variable |
                    if (variable.isPrimitiveOrNull)
                        primitiveList += renderingFactory.createKText() => [
                            var text = ""
                            if (!variable.type.equals("null"))
                                text = text + variable.type + " "
                            text = text + variable.name + ": " + variable.value.valueString 
                            it.text = text  
                        ]
                    else {
                    	if (variable.transformationExists)
                        	rootNode.children += variable.nextTransformation
                        else
                        	rootNode.createObjectNode(variable)
                        if (variable.nodeExists)
	                        choice.createEdgeById(variable) => [
	                            variable.createLabel(it) => [
	                                 val String name = variable.name
	                                 it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::CENTER)
	                                 it.setLabelSize(name.length*10,50)
	                                 it.text = name
	                             ]
	                             it.data += renderingFactory.createKPolyline() => [
	                                 it.setLineWidth(2)
	                                 it.addArrowDecorator()
	                             ]
	                        ]
                    }
                ]
                thisNode => [
                    it.data += renderingFactory.createKRectangle() => [
                        it.childPlacement = renderingFactory.createKGridPlacement()
                        it.children += renderingFactory.createKText() => [
                            it.text = choice.name
                        ]
                        it.children += renderingFactory.createKText() => [
                            it.text = "Variables without id"
                        ]
                        it.children += renderingFactory.createKText() => [
                            it.text = "--------------------"
                        ]
                        primitiveList.forEach[KText text |
                            it.children += text
                        ]
                    ]
                ]
            }
        
        } 
}