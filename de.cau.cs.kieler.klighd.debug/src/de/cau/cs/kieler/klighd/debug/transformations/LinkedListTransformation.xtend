package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.core.kgraph.KNode
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

class LinkedListTransformation extends AbstractDebugTransformation {
    
    @Inject
    extension KNodeExtensions    
    @Inject 
    extension KPolylineExtensions 
    @Inject
    extension KRenderingExtensions
   
   
    var index = 0
    var size = 0
    /**
     * {@inheritDoc}
     */
    override transform(IVariable variable) {
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::UP)
            size = Integer::parseInt(variable.getValue("size"))
            it.createChildNode(variable.getVariable("header.next"))
        ]
    }
    
    def getElement(IVariable variable) {
    	return variable.getVariable("element")
    }  
    
    def createChildNode(KNode rootNode, IVariable variable) {
       rootNode.addNewNodeById(variable.element)?.nextTransformation(variable.element)
       index = index + 1
       if (index < size) {
           var next = variable.getVariable("next")
           rootNode.createChildNode(next)
           variable.element.createEdgeById(next.element) => [
                it.data += renderingFactory.createKPolyline() => [
                    it.setLineWidth(2)
                    it.addArrowDecorator();
                ]
            ]
       }
    }
}