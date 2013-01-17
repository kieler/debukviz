package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

class EnumSetTransformation extends AbstractDebugTransformation {
    
    @Inject
    extension KNodeExtensions
    
    override transform(IVariable model) {
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::UP);
            val universe = model.getVariables("universe")
            val elements = Integer::toBinaryString(Integer::parseInt(model.getValue("elements")))
            var index = 0
            val length = elements.length
            while (index < universe.size && index < length) {
            	var element = ""+elements.charAt(length-index-1)
            	if (element == "1")
            		it.createEnumElementNode(universe.get(index))
            	index = index + 1;		
            }
        ]
    }
    
        def createEnumElementNode(KNode node, IVariable enumElement) {
			node.children += enumElement.createNode() => [
				it.children += createNode() => [
					it.data += renderingFactory.createKText() => [
						it.text = enumElement.getValue("name")
					]  
				]
			]
    }
    
}