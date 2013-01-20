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

class PriorityQueueTransformation extends AbstractDebugTransformation {
    
    @Inject
    extension KNodeExtensions 
    @Inject 
    extension KPolylineExtensions 
    @Inject
    extension KRenderingExtensions
    
    var IVariable previous = null
    var index = 0
    
    override transform(IVariable model) {
       return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::UP)
            
            model.getVariables("queue").filter[variable | variable.valueIsNotNull].forEach[
                IVariable variable |
                    it.children += variable.createNode() => [
                    	if (index == 0)
                    		it.addLabel("head")
                    	else
                    		it.addLabel(""+index)
                    	index= index +1
                        it.nextTransformation(variable)
                        if (previous != null)
                            previous.createEdge(variable) => [
                                it.data += renderingFactory.createKPolyline() => [
                                    it.setLineWidth(2)
                                    it.addArrowDecorator();
                                ]
                            ]
                        previous = variable
                    ]
            ]
            
       ]
    }
    
}