package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

class LinkedListEntryTransformation extends AbstractDebugTransformation {
    
    @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
    @Inject
    extension KColorExtensions
   
   
    var index = 0
    /**
     * {@inheritDoc}
     */
    override transform(IVariable variable) {
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::UP); 
            it.nextTransformation(variable.element,null)
        ]
    }
    
    def IVariable getElement(IVariable variable) {
        return variable.getVariableByName("element");
    }
}