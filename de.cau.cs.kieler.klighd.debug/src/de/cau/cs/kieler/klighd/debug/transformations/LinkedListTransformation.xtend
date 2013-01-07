package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.KRenderingFactory
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.core.util.Pair
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.TransformationContext
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.transformations.LinkedListTransformation.*
import javax.inject.Inject

class LinkedListTransformation extends AbstractDebugTransformation {
    
    @Inject
    extension KNodeExtensions    
    @Inject
    extension KEdgeExtensions
    @Inject
    extension KRenderingExtensions
    @Inject
    extension KColorExtensions
    
 
    private static val KRenderingFactory renderingFactory = KRenderingFactory::eINSTANCE
   
    /**
     * {@inheritDoc}
     */
    override transform(IVariable variable,TransformationContext<IVariable,KNode> transformationContext) {
        use(transformationContext);
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::UP);
      		it.createHeaderNode(variable)
       		val i = variable.getValueByName("size")
            val IVariable header = variable.getVariableByName("header")
            val IVariable last =  it.createChildNode(header, Integer::parseInt(i))
            header.createEdge(last)
        ]
    }
 
  	def createHeaderNode(KNode rootNode, IVariable variable) {
    	var IVariable header = variable.getVariableByName("header")
    	rootNode.children += header.createNode().putToLookUpWith(header) => [
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
    
    def IVariable createChildNode(KNode rootNode, IVariable parent, int size){
        if (size > 0) {
        	var next = parent.getVariableByName("next")
            rootNode.createInternalNode(next)
            parent.createEdge(next)
            return rootNode.createChildNode(next, size-1)
        }
        else
            return parent
    }
    
    def createInternalNode(KNode rootNode, IVariable next) {
        rootNode.children += next.createNode().putToLookUpWith(next) => [    
            it.setNodeSize(120,80)
            it.data += renderingFactory.createKRectangle() => [      
                it.lineWidth = 2
                it.backgroundColor = "lemon".color
    			it.ChildPlacement = renderingFactory.createKGridPlacement()
            ]
            it.nextTransformation(next.getVariableByName("element"),null)
            /*it.children += element.createNode().putToLookUpWith(element) => [   
            	it.data += renderingFactory.createKRectangle() => [
            		it.foregroundVisibility = false
            		it.backgroundVisibility = false
    				it.ChildPlacement = renderingFactory.createKGridPlacement()
    				it.children += renderingFactory.createKText() => [
                      it.setText(element.getValueByName("value"))
                    ]
            	]
            ]
            */
        ]
    }
    
    def createEdge(IVariable child, IVariable parent) {
        new Pair(child, parent).createEdge() => [
            it.source = parent.node
            it.target = child.node
            it.data += renderingFactory.createKPolyline() => [
                it.setLineWidth(2)
            ]
        ]
    }  
}