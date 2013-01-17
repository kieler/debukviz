package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

class HashSetTransformation extends AbstractDebugTransformation {
   
    @Inject
    extension KNodeExtensions
    
    override transform(IVariable model) {
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::UP)
            model.getVariables("map.table").filter[variable | variable.valueIsNotNull].forEach[
                IVariable variable | 
               	it.children += createNode() => [
               		it.data += renderingFactory.createKChildArea
               		it.nextTransformation(variable.getVariable("key"))
               	]
       		] 
		]
    }
}