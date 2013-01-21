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
            val header = variable.getVariable("header")
            val last = it.createChildNode(header)
            last.createEdgeById(header) => [
                it.data += renderingFactory.createKPolyline() => [
                    it.setLineWidth(2)
                    it.addArrowDecorator();
                ]
            ]
        ]
    }

  	def createHeaderNode(KNode rootNode, IVariable variable) {
    	var IVariable header = variable.getVariable("header")
    	rootNode.children += header.createNodeById() => [
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
                	it.setText("size: " + variable.getValue("size"))
            	]
    		]
    	]
    }    
    
    def IVariable createChildNode(KNode rootNode, IVariable parent){
       var next = parent.getVariable("next")
       if (!next.nodeExists) {
            rootNode.createInternalNode(next)
            parent.createEdgeById(next) => [
                it.data += renderingFactory.createKPolyline() => [
                    it.setLineWidth(2)
                    it.addArrowDecorator();
                ]
            ]
            return rootNode.createChildNode(next)
        }
        else
            return parent
    }
    
    def createInternalNode(KNode rootNode, IVariable next) {
        rootNode.nextTransformation(next)
    }
}