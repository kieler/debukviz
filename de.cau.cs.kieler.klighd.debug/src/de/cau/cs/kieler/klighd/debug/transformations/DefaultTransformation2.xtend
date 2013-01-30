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
import org.eclipse.jdt.debug.core.IJavaModifiers

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

class DefaultTransformation extends AbstractDebugTransformation {
       
    @Inject 
    extension KPolylineExtensions   
    @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
    @Inject
    extension KLabelExtensions

    override transform(IVariable model, Object transformationInfo) {
        return KimlUtil::createInitializedNode() => [
            //it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 50f)
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::RIGHT)
            // Array
            if (model.isArray)
                it.createArrayNode(model)
            // primitive datatypes or null or null object
            else if (model.isPrimitiveOrNull || model.isNullObject || model.type.equals("String"))
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
    
    def boolean isArray(IVariable variable) {
        return variable.value instanceof IJavaArray
    }
    
    def boolean isPrimitiveOrNull(IVariable variable) {
        val value = variable.value
        return value instanceof IJavaPrimitiveValue || 
              (value instanceof IJavaValue && (value as IJavaValue).isNull())
    }
    
    def boolean isObject(IVariable variable) {
        return variable.value instanceof IJavaObject
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
                rootNode.children += choice.nextTransformation
        } else
        	rootNode.createValueNode(choice)
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
                    rootNode.createObjectNode(variable)
                    choice.createEdgeById(variable) => [
                        variable.createLabel(it) => [
                             val String name = variable.name
                             it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::CENTER)
                             it.setLabelSize(name.length*20,50)
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
                        it.text = "<<"+choice.type+">>"
                        it.setForegroundColor(120,120,120)
                    ]
                    it.children += renderingFactory.createKText() => [
                        it.text = choice.name
                    ]
                    if (!primitiveList.empty) {
                        it.children += renderingFactory.createKText() => [
                            it.text = "--------------------"
                        ]
                        primitiveList.forEach[KText text |
                            it.children += text
                        ]                      
                    }
                ]
            ]
        }
    } 
}