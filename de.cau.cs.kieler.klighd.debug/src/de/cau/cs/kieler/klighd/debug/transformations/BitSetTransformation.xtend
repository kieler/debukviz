package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

class BitSetTransformation extends AbstractDebugTransformation {
    
    @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
    
    var String bitStream = ""
    
    override transform(IVariable model) {
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::UP);
            model.getVariablesByName("words").forEach[IVariable variable |
                bitStream = bitStream + Integer::toBinaryString(Integer::parseInt(variable.getValueByName("")))
            ]
            it.children += createNode() => [
                it.data += renderingFactory.createKRectangle() => [
                    it.childPlacement = renderingFactory.createKGridPlacement()
                    it.children += renderingFactory.createKText() => [
                                it.text = "<<BitSet>>"
                                it.setForegroundColor(120,120,120)
                    ]
                    
                    it.children += renderingFactory.createKText() => [
                                it.text = "Words in use: "+model.getValueByName("wordsInUse")
                    ]
                    it.children += renderingFactory.createKText() => [
                                it.text = bitStream
                    ]
                ]        
            ]
        ]
    }
    
}