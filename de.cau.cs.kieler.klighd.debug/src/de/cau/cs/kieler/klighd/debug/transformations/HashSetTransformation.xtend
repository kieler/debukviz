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
    
    override transform(IVariable model, Object transformationInfo) {
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::RIGHT)
            model.getVariables("map.table").filter[variable | variable.valueIsNotNull].forEach[
                IVariable variable | 
               	it.children += variable.createNodeById() => [
               		it.nextTransformation(variable.getVariable("key"))
               	]
               	val next = variable.getVariable("next");
               	if (next.valueIsNotNull)
                   	it.children += next.createNodeById() => [
                        it.nextTransformation(next.getVariable("key"))
                    ]
       		] 
		]
    }
}