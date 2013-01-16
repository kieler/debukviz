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
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::UP);
            if (model.type.endsWith("[]")) {
                // Array
                it.children += it.arrayTransform(model)
            } else
                // Types without a transformation
                it.children += it.createValueNode(model,getValueText(model.type,model.value.valueString))
        ]
    }
    
    def KNode arrayTransform(KNode node, IVariable choice) {
        if (choice.type.endsWith("[]")) {
            val result = node.createValueNode(choice,getTypeText(choice.type))
            choice.value.variables.forEach[
                IVariable variable |
                node.children += node.arrayTransform(variable)
                choice.createEdge(variable) => [
                    it.data += renderingFactory.createKPolyline() => [
                        it.setLineWidth(2);
                        it.addArrowDecorator();
                    ]  
                ]           
            ]
            return result
        } else {
            return choice.createNode() => [
                it.setNodeSize(80,80);
                it.addLabel(""+index)
                index = index + 1
                it.data += renderingFactory.createKRectangle() => [
                    it.childPlacement = renderingFactory.createKGridPlacement()
                ]
                it.nextTransformation(choice)
            ]
        } 
    }
    
    def KNode createValueNode(KNode node, IVariable variable, LinkedList<KText> text) {
        return variable.createNode() => [
            it.setNodeSize(80,80);
            it.data += renderingFactory.createKRectangle() => [
                it.childPlacement = renderingFactory.createKGridPlacement()
                text.forEach[
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
    
    def LinkedList<KText> getTypeText(String type) {
        return new LinkedList<KText>() => [
            it += renderingFactory.createKText() => [
                it.text = type
            ]
        ]
    }       
}