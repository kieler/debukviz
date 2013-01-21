package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.KText
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.Direction
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

	var index = 0

    override transform(IVariable model) {
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered");
            it.addLayoutParam(LayoutOptions::SPACING, 75f);
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::RIGHT);
            val value = model.value
            // Array
            if (value instanceof IJavaArray)
                it.children += it.arrayTransform(model)
            // Types without a transformation
            // primitive datatypes and null
            else if (value instanceof IJavaPrimitiveValue || (value instanceof IJavaValue && (value as IJavaValue).isNull()))
                	it.children += it.createValueNode(model)
            // objecttypes
            else if (value instanceof IJavaObject) {
            	value.variables.forEach[
            		IVariable variable |
            		val value_ = variable.value
            		// TODO: handle primitive types and null values
            		if (value_ instanceof IJavaObject) {
            			it.children += it.createObjectNode(variable)	
            		}
            	]
            }   
        ]
    }
    
    def KNode createObjectNode(KNode node, IVariable variable) {
    	variable.createNodeById() => [
    	    it.addLabel(variable.name)
    	    it.nextTransformation(variable)
    	]
    }
    
    def KNode arrayTransform(KNode node, IVariable choice) {
            if (choice.value instanceof IJavaArray) {
	            val result = choice.getNode() => [
	         		it.setNodeSize(80,80);
	            	it.data += renderingFactory.createKRectangle() => [
	                	it.childPlacement = renderingFactory.createKGridPlacement()
	                	it.children += renderingFactory.createKText() => [
	                		it.text = choice.type.substring(choice.type.lastIndexOf('.')+1)
	            		]
	            	]
	            ]
	            
            	choice.value.variables.forEach[
                	IVariable variable |
                	node.children += node.arrayTransform(variable)
                	choice.createEdge(variable) => [
    	                it.data += renderingFactory.createKPolyline() => [
                            it.setLineWidth(2)
                            it.addArrowDecorator()
                        ]
                	]
                ]                       
            return result
        } else {
            return choice.createNode() => [
                it.addLabel(""+index)
                index = index + 1
                it.nextTransformation(choice)
            ]
        } 
    }
    
    def KNode createValueNode(KNode node, IVariable variable) {
        return variable.createNode() => [
            it.setNodeSize(80,80);
            it.data += renderingFactory.createKRectangle() => [
                it.childPlacement = renderingFactory.createKGridPlacement()
                getValueText(variable.type,variable.value.valueString).forEach[
                    KText t |
                    it.children += t
                ]
            ]
        ]
    }
        
    def LinkedList<KText> getValueText(String type, String value) {
        return new LinkedList<KText>() => [
            it += renderingFactory.createKText() => [
                it.text = "<<"+type+">>"
                it.setForegroundColor(120,120,120)
            ]
            it += renderingFactory.createKText() => [
                it.text = value
            ]
        ]
    }    
}