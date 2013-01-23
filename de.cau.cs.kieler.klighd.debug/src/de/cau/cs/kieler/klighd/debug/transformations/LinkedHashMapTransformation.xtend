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

class LinkedHashMapTransformation extends AbstractDebugTransformation {
   
    @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
    @Inject 
    extension KPolylineExtensions 
    
    var index = 0;
    var size = 0;
    
    override transform(IVariable model) {
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::RIGHT)
            size = Integer::parseInt(model.getValue("size"))
            it.createKeyValueNode(model.getVariable("header.after"))
        ]
    }
    
    def createKeyValueNode(KNode node, IVariable variable) {
        val key = variable.getVariable("key")
        val value = variable.getVariable("value")
        val beforeKey = variable.getVariable("before.key")
        val after = variable.getVariable("after")
        
        index = index + 1
        
        node.children += variable.createNode() => [
            it.addLabel("Key:")
            it.nextTransformation(key)
        ]
        if (!value.nodeExists)
	        node.children += value.createNodeById() => [
	            it.addLabel("Value:")
	            it.nextTransformation(value)
	        ]
        /*variable.createEdgeById(value) => [
            it.data += renderingFactory.createKPolyline() => [
                it.setLineWidth(2);
                it.addArrowDecorator();
            ]
        ]
        
        if(index < size) {
        	node.createKeyValueNode(after)
        	variable.createEdgeById(after) => [
        		it.data += renderingFactory.createKPolyline() => [
                	it.setLineWidth(2);
                	it.addArrowDecorator();
                ]
            ]
        }*/
    }
}