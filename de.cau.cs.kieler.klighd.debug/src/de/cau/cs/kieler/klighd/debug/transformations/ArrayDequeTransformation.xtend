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
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement

class ArrayDequeTransformation extends AbstractDebugTransformation {
    
    @Inject
    extension KNodeExtensions 
    @Inject 
    extension KPolylineExtensions 
    @Inject 
    extension KLabelExtensions
    @Inject
    extension KRenderingExtensions
    
    var IVariable previous = null
    
    override transform(IVariable model, Object transformationInfo) {
        return KimlUtil::createInitializedNode() => [
            //it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 50f)
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::RIGHT);
            val head = Integer::parseInt(model.getValue("head"));
            val tail = Integer::parseInt(model.getValue("tail"));
            val IVariable[] elements = model.getVariables("elements");
            var int index = head;
            while (index <= tail) {
                val variable = elements.get(index)
                it.children += variable.nextTransformation
                
                if (previous != null) {
                    val edge = previous.createEdgeById(variable) => [
                        it.data += renderingFactory.createKPolyline() => [
                            it.setLineWidth(2)
                            it.addArrowDecorator();
                        ]
                    ]
                    if (index == head+1)
                        previous.createLabel(edge) => [
                            it.text = "head";
                            it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::CENTER)
                            it.setLabelSize(50,50)
                        ]
                    if (index == tail)
                        previous.createLabel(edge) => [
                            it.text = "tail";
                            it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::CENTER)
                            it.setLabelSize(50,50)
                        ]
                }
                previous = variable
                index = index + 1
            }
        ]
    }
    
}