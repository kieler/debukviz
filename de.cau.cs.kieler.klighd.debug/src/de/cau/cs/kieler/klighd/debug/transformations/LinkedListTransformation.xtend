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
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement

class LinkedListTransformation extends AbstractDebugTransformation {
    
    @Inject
    extension KNodeExtensions    
    @Inject 
    extension KPolylineExtensions 
    @Inject
    extension KRenderingExtensions
    @Inject
    extension KLabelExtensions
   
   
    var index = 0
    var size = 0
    /**
     * {@inheritDoc}
     */
    override transform(IVariable variable, Object transformationInfo) {
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
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
       rootNode.nextTransformation(variable.element)
       index = index + 1
       if (index < size) {
           val next = variable.getVariable("next")
           rootNode.createChildNode(next)
           variable.createEdgeById(next) => [
               next.createLabel(it) => [
                     it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::CENTER)
                     it.setLabelSize(50,50)
                     it.text = "next"
                 ]
                it.data += renderingFactory.createKPolyline() => [
                    it.setLineWidth(2)
                    it.addArrowDecorator();
                ]
            ]
       }
    }
}