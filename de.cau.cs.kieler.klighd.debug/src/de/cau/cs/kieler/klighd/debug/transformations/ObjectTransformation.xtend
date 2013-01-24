package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.core.krendering.KText
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation
import java.util.LinkedList
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

class ObjectTransformation extends AbstractDebugTransformation {
         
    @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions

    override transform(IVariable model) {
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered");
            it.addLayoutParam(LayoutOptions::SPACING, 75f);
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::RIGHT);
            it.data += renderingFactory.createKRectangle() => [
                it.backgroundVisibility = false
                it.childPlacement = renderingFactory.createKGridPlacement()
                getValueText(model.type,"null").forEach[
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