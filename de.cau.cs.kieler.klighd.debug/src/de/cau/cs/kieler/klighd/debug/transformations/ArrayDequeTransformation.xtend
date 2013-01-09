package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

class ArrayDequeTransformation extends AbstractDebugTransformation {
    
    @Inject
    extension KNodeExtensions 
    @Inject 
    extension KPolylineExtensions 
    @Inject
    extension KRenderingExtensions
    
    var IVariable previous = null
    
    override transform(IVariable model) {
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::UP);
            val head = Integer::parseInt(model.getValueByName("head"));
            val tail = Integer::parseInt(model.getValueByName("tail"));
            val IVariable[] elements = model.getVariablesByName("elements");
            var int index = head;
            while (index <= tail) {
                val variable = elements.get(index)
                val node = variable.createNode().putToKNodeMap(variable) => [
                    it.nextTransformation(variable,null)
                    if (previous != null)
                        previous.createEdge(variable) => [
                            it.data += renderingFactory.createKPolyline() => [
                                it.setLineWidth(2)
                                it.addArrowDecorator();
                            ]
                        ]
                    previous = variable
                ]
                if (index == head)
                    node.children += "head".label
                if (index == tail)
                    node.children += "tail".label
                it.children += node;
                index = index + 1
            }
        ]
    }
    
}