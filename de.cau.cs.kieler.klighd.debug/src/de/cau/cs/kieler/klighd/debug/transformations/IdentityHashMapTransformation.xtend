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

class IdentityHashMapTransformation extends AbstractDebugTransformation {
   
    @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
    @Inject 
    extension KPolylineExtensions 
    
    override transform(IVariable model) {
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::UP)
            var index = 0
            val IVariable[] table = model.getVariablesByName("table").filter[variable | variable.valueIsNotNull]
            println(table.size)
            while (index < table.size) {
            	var IVariable key = table.get(index)
            	var IVariable value = table.get(index+1)
            	it.createKeyValueNode(key,value)
            	index = index + 2
            }            
        ]
    }
    
    def createKeyValueNode(KNode node, IVariable key, IVariable value) {
       node.createInnerNode(key,"Key:")
       node.createInnerNode(value,"Value:")
       key.createEdge(value) => [
            it.data += renderingFactory.createKPolyline() => [
                it.setLineWidth(2);
                it.addArrowDecorator();
            ];
        ]; 
    }
    
    def createInnerNode(KNode node, IVariable variable, String text) {
        node.children += variable.createNode().putToKNodeMap(variable) => [
            it.addLabel(text)
            it.nextTransformation(variable,null)
       ] 
    }
}