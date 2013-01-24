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

class TreeMapTransformation extends AbstractDebugTransformation {
   
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
           	createTreeNode(model.getVariable("root"),"")
        ]
    }
    
    def getParent(IVariable variable) {
    	variable.getVariable("parent")
    }
    
    def createTreeNode(KNode node, IVariable root, String label) {
    	val left = root.getVariable("left")
    	val right = root.getVariable("right")
      	
      	node.createKeyValueNode(root,label)
      	
       	if (right.valueIsNotNull) {
       		node.createTreeNode(right,"right")
       		/*root.createEdge(right) => [
       			it.data += renderingFactory.createKPolyline() => [
                    it.setLineWidth(2)
                    it.addArrowDecorator();
            	]
       		]*/
       	}
       	if (left.valueIsNotNull) {
       		node.createTreeNode(left,"left")
       		/*root.createEdge(left) => [
       			it.data += renderingFactory.createKPolyline() => [
                    it.setLineWidth(2)
                    it.addArrowDecorator();
            	]
       		]*/
       	}
       	
        if (root.parent.valueIsNotNull) {
        	root.parent.parent.createEdge(root.parent) => [
       			it.data += renderingFactory.createKPolyline() => [
                    it.setLineWidth(2)
                    it.addArrowDecorator()
            	]
            	it.addLabel(label)
       		]
        }
    }
    
    def createKeyValueNode(KNode node, IVariable root, String label) {
    	val key = root.getVariable("key")
    	val value = root.getVariable("value")
    	node.children += root.parent.createNode() => [
	    	it.createInnerNode(root,key,"Key:")
	       	it.createInnerNode(root,value,"Value:")
	       	key.createEdge(value) => [
	       		it.data += renderingFactory.createKPolyline() => [
	                    it.setLineWidth(2)
	                    it.addArrowDecorator();
	            ]
	       	]
       	]
    }
    
    def createInnerNode(KNode rootNode, IVariable parent, IVariable variable, String text) {
        rootNode.children += variable.createNode() => [
            it.addLabel(text)
            it.nextTransformation(variable,null)
       	]
    }
}