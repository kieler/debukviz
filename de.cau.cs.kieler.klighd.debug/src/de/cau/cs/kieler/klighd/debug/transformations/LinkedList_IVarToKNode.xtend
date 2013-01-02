package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.KRenderingFactory
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.core.util.Pair
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.TransformationContext
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.transformations.LinkedList_IVarToKNode.*

class LinkedList_IVarToKNode extends AbstractDebugTransformation {
    
    extension KNodeExtensions kNodeExtensions = new KNodeExtensions();
    extension KEdgeExtensions kEdgeExtensions = new KEdgeExtensions();
    extension KRenderingExtensions kRenderingExtensions = new KRenderingExtensions();
    extension KColorExtensions kColorExtensions = new KColorExtensions();
    
 
    private static val KRenderingFactory renderingFactory = KRenderingFactory::eINSTANCE
    
    /**
     * {@inheritDoc}
     */
    override transform(IVariable variable,TransformationContext<IVariable,KNode> transformationContext) {
        use(transformationContext);
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
      		it.createHeaderNode(variable)
       		var i = getValue(variable, "size").valueString
            it.createChildNode(getVariableByName(variable, "header"), Integer::parseInt(i))
        ]
    }
 
  	def createHeaderNode(KNode rootNode, IVariable variable) {
    	var IVariable header = getVariableByName(variable, "header")
    	rootNode.children += header.createNode().putToLookUpWith(header) => [
    		it.setNodeSize(120,80)
    		it.data += renderingFactory.createKRectangle() => [
    			it.setLineWidth(4)
    			it.setBackgroundColor("lemon".color)
    			it.ChildPlacement = renderingFactory.createKGridPlacement()
    			it.children += renderingFactory.createKText() => [
                	it.setText(variable.name)
            	]
    			it.children += renderingFactory.createKText() => [
                	it.setText("Type: " + variable.getReferenceTypeName)
            	]
    			it.children += renderingFactory.createKText() => [
                	it.setText("size: " + getVariableByName(variable, "size").getValue.valueString)
            	]
    		]
    	]
    }
            
    /**
     * Creates a 
     */
    def createChildNode(KNode rootNode, IVariable parent, int recursions){
        if (recursions > 0) {
        	var node0 = getVariableByName(parent, "next")
//        	var node =  getVariableByName(node0, "element")
            rootNode.createInternalNode(node0)
            createEdge(parent, node0)
            createChildNode(rootNode, node0, recursions -1)
        }
    }
    
    def createInternalNode(KNode rootNode, IVariable element) {
        rootNode.children += element.createNode().putToLookUpWith(element) => [
            it.setNodeSize(120,80)
            it.data += renderingFactory.createKRectangle() => [
                it.setLineWidth(2)
                it.setBackgroundColor("lemon".color)
    			it.ChildPlacement = renderingFactory.createKGridPlacement()
    			it.children += renderingFactory.createKText() => [
                	it.setText(element.getVariableByName("element").getVariableByName("value").getValue.valueString)
            	]
            ]
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