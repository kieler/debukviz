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
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions

class TreeSetTransformation extends AbstractDebugTransformation {
   
@Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
    @Inject 
    extension KPolylineExtensions 
    @Inject 
    extension KLabelExtensions 
    
    override transform(IVariable model, Object transformationInfo) {
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::DOWN)
            //it.addLayoutParam(LayoutOptions::LAYOUT_HIERARCHY, true)
            createTreeNode(model.getVariable("m.root"),"")
        ]
    }
    
     def getKey(IVariable variable) {
        variable.getVariable("key")
    }
    
    def getParent(IVariable variable) {
        variable.getVariable("parent")
    }
    
    def createTreeNode(KNode node, IVariable root, String label) {
        val left = root.getVariable("left")
        val right = root.getVariable("right")
        val key = root.key
        
        node.addNewNodeById(key)?.nextTransformation(key)
        
        if (right.valueIsNotNull) {
            node.createTreeNode(right,"right")
        }
        if (left.valueIsNotNull) {
            node.createTreeNode(left,"left")
        }
        
        if (root.parent.valueIsNotNull) {
            root.parent.key.createEdgeById(key) => [
                root.createLabel(it) => [
                    it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT,EdgeLabelPlacement::CENTER)
                    it.setLabelSize(50,50)
                    it.text = label
                ]
                it.data += renderingFactory.createKPolyline() => [
                    it.setLineWidth(2)
                    it.addArrowDecorator()
                ]
            ]
        }
    }
}