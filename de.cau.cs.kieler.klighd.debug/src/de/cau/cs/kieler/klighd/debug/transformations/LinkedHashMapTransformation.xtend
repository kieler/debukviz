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
    
    override transform(IVariable model) {
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::UP)
            model.getVariablesByName("table").filter[variable | variable.valueIsNotNull].forEach[
                IVariable variable | it.createKeyValueNode(variable)
            ]
        ]
    }
    
    def getKey(IVariable variable) {
        return variable.getVariableByName("key")
    }
    
    def createKeyValueNode(KNode node, IVariable variable) {
       val value = variable.getVariableByName("value")
       val before = variable.getVariableByName("before")
       node.createInnerNode(variable,variable.key,"Key:")
       node.createInnerNode(variable,value,"Value:")
       variable.key.createEdge(value) => [
            it.data += renderingFactory.createKPolyline() => [
                it.setLineWidth(2);
                it.addArrowDecorator();
            ];
       ];
       if (before.key.valueIsNotNull)
	       before.key.createEdge(variable.key) => [
	            it.data += renderingFactory.createKPolyline() => [
	                it.setLineWidth(2);
	                it.addArrowDecorator();
	            ];
	       ];
    }
    
    def createInnerNode(KNode rootNode, IVariable parent, IVariable variable, String text) {
    	val node = variable.createNode() => [
            it.addLabel(text)
            it.nextTransformation(variable,null)
       	] ;
        rootNode.children += node
        return node
    }
}