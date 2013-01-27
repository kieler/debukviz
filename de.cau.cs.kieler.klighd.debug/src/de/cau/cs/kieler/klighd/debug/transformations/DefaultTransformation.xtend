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

class DefaultTransformation extends AbstractDebugTransformation {
       
    @Inject 
    extension KPolylineExtensions   
    @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
    @Inject
    extension KLabelExtensions

    override transform(IVariable model) {
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered");
            it.addLayoutParam(LayoutOptions::SPACING, 75f);
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::RIGHT);
            // Array
            if (model.isArray)
                it.createArrayNode(model)
            // primitive datatypes or null or null object
            else if (model.isPrimitiveOrNull || model.isNullObject)
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
    
    def createArrayNode(KNode node, IVariable choice) {
            if (choice.value instanceof IJavaArray) {
	            node.addNewNodeById(choice)=> [
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
                	node.createArrayNode(variable)
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
        } else if (!choice.isPrimitiveOrNull && !choice.isNullObject) {
            node.addNewNodeById(choice)?.nextTransformation(choice)
        } else
        	node.addNewNodeById(choice)?.createValueNode(choice)
    }
    
    def createValueNode(KNode rootNode, IVariable choice) {
        rootNode.children += createNode() => [
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
    
    def createObjectNode(KNode rootNode, IVariable choice) {
        if (choice.isNullObject) {}
        else {
            val primitiveList = new LinkedList<KText>()
            choice.value.variables.forEach[IVariable variable |
                if (variable.isPrimitiveOrNull)
                    primitiveList += renderingFactory.createKText() => [
                        var text = ""
                        if (!variable.type.equals("null"))
                            text = text + variable.type + " "
                        text = text + variable.name + ": " + variable.value.valueString 
                        it.text = text  
                    ]
                else {
                    rootNode.addNewNodeById(variable)?.nextTransformation(variable)
                }
            ]
            rootNode.children += createNode() => [
                it.addLayoutParam(LayoutOptions::BORDER_SPACING, 5.0f);
                it.data += renderingFactory.createKRectangle() => [
                    it.childPlacement = renderingFactory.createKGridPlacement()
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