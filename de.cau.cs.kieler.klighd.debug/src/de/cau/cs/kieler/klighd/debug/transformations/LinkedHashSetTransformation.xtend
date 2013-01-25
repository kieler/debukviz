package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement

class LinkedHashSetTransformation extends AbstractDebugTransformation {
   
   @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
    @Inject 
    extension KPolylineExtensions
    @Inject 
    extension KLabelExtensions 
    
    var index = 0;
    var size = 0;
    
    override transform(IVariable model) {
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::RIGHT)
            size = Integer::parseInt(model.getValue("map.size"))
            it.createKeyValueNode(model.getVariable("map.header.after"))
        ]
    }
    
    def createKeyValueNode(KNode node, IVariable variable) {
        val key = variable.getVariable("key")
        val after = variable.getVariable("after")
        
        index = index + 1
        
        node.addNewNodeById(key)?.nextTransformation(key)
    
        if (index < size) {
            node.createKeyValueNode(after)
            key.createEdgeById(after.getVariable("key")) => [
                key.createLabel(it) => [
                    it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT,EdgeLabelPlacement::CENTER)
                    it.setLabelSize(50,50)
                    it.text = "after"
                ]
                it.data += renderingFactory.createKPolyline() => [
                    it.setLineWidth(2)
                    it.addArrowDecorator()
                ]
            ]
        }
    }
}