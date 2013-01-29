package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
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
    
    var String bitString = ""
    
    override transform(IVariable model, Object transformationInfo) {
        return KimlUtil::createInitializedNode() => [
            model.getVariables("words").forEach[IVariable variable |
                bitString = bitString + Integer::toBinaryString(Integer::parseInt(variable.value.valueString))
            ]
            it.addNewNodeById(model) => [
                it.data += renderingFactory.createKRectangle() => [
                    it.childPlacement = renderingFactory.createKGridPlacement()
                    it.children += renderingFactory.createKText() => [
                                it.text = "<<BitSet>>"
                                it.setForegroundColor(120,120,120)
                    ]
                    
                    it.children += renderingFactory.createKText() => [
                                it.text = "Words in use: "+model.getValue("wordsInUse")
                    ]
                    it.children += renderingFactory.createKText() => [
                                it.text = bitString
                    ]
                ]        
            ]
        ]
    }
    
}