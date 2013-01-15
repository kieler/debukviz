package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
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
    @Inject
    extension KColorExtensions
   
   
    var index = 0
    /**
     * {@inheritDoc}
     */
    override transform(IVariable variable) {
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::UP);
      		it.createHeaderNode(variable)
       		val i = variable.getValueByName("size")
            val IVariable header = variable.getVariableByName("header")
            val IVariable last =  it.createChildNode(header, Integer::parseInt(i)*3+1)
            last.element.createEdge(header.element) => [
                it.data += renderingFactory.createKPolyline() => [
                    it.setLineWidth(2)
                    it.addArrowDecorator();
                ]
            ]
        ]
    }
 
  	def createHeaderNode(KNode rootNode, IVariable variable) {
    	var IVariable header = variable.getVariableByName("header")
    	rootNode.children += header.element.createNode() => [
    		it.setNodeSize(120,80)
    		it.data += renderingFactory.createKRectangle() => [
    			it.lineWidth = 4
    			it.backgroundColor = "lemon".color
    			it.ChildPlacement = renderingFactory.createKGridPlacement()
    			it.children += renderingFactory.createKText() => [
                	it.setText(variable.name)
            	]
    			it.children += renderingFactory.createKText() => [
                	it.setText("Type: " + variable.type)
            	]
    			it.children += renderingFactory.createKText() => [
                	it.setText("size: " + variable.getValueByName("size"))
            	]
    		]
    	]
    }
    
    def IVariable getElement(IVariable variable) {
        return variable.getVariableByName("element");
    }
    
    
    def IVariable createChildNode(KNode rootNode, IVariable parent, int size){
        if (size > 0) {
        	var next = parent.getVariableByName("next")
            rootNode.createInternalNode(next)
            parent.element.createEdge(next.element) => [
                it.data += renderingFactory.createKPolyline() => [
                    it.setLineWidth(2)
                    it.addArrowDecorator();
                ]
            ]
            return rootNode.createChildNode(next, size-1)
        }
        else
            return parent
    }
    
    def createInternalNode(KNode rootNode, IVariable next) {
        rootNode.children += next.element.createNode() => [    
            it.setNodeSize(120,80)
            it.addLabel(""+index)
            index = index + 1
            it.data += renderingFactory.createKRectangle() => [      
                it.lineWidth = 2
                it.backgroundColor = "lemon".color
    			it.ChildPlacement = renderingFactory.createKGridPlacement()
            ]
            it.nextTransformation(next.element,null)
        ]
    }
}