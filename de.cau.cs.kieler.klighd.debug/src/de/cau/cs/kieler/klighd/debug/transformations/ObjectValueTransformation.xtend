package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.KRenderingFactory
import de.cau.cs.kieler.core.krendering.KText
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation
import java.util.LinkedList
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.transformations.ObjectValueTransformation.*

class ObjectValueTransformation extends AbstractDebugTransformation {
   
    @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
    
    private static val KRenderingFactory renderingFactory = KRenderingFactory::eINSTANCE   
    
    override transform(IVariable model) {
        return 
        KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            it.children += it.createValueNode(model,getValueText(model.type,model.getValueByName("value")))
        ]
    }
    
    def KNode createValueNode(KNode node, IVariable variable, LinkedList<KText> text) {
        return variable.createNode().putToLookUpWith(variable) => [
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
   
}