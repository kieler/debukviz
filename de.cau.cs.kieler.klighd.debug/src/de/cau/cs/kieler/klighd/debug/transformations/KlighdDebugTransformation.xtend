package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.KRenderingFactory
import de.cau.cs.kieler.core.krendering.KText
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.core.util.Pair
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.TransformationContext
import de.cau.cs.kieler.klighd.debug.KlighdDebugExtension
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation
import de.cau.cs.kieler.klighd.transformations.AbstractTransformation
import java.util.LinkedList
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.transformations.KlighdDebugTransformation.*

class KlighdDebugTransformation extends AbstractTransformation<IVariable, KNode> {
        	
    @Inject
    extension KNodeExtensions
    
   	@Inject
	extension KEdgeExtensions
	
    @Inject
    extension KRenderingExtensions
    
    @Inject
    extension KPolylineExtensions
	
    private static val KRenderingFactory renderingFactory = KRenderingFactory::eINSTANCE
    
    /**
     * {@inheritDoc}
     */
	override KNode transform(IVariable choice, TransformationContext<IVariable, KNode> transformationContext) {
	    use(transformationContext)
	    val AbstractDebugTransformation transformation = KlighdDebugExtension::INSTANCE.getTransformation(choice.referenceTypeName);
	    if (transformation != null) 
            return transformation.transform(choice,transformationContext) 
	    else    	    	    
    		return KimlUtil::createInitializedNode() => [
    		    it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered");
                it.addLayoutParam(LayoutOptions::SPACING, 75f);
                it.addLayoutParam(LayoutOptions::DIRECTION, Direction::UP);
                it.children += it.transformation(choice)
    	    ]
	}
	
	def KNode transformation(KNode node, IVariable choice) {
		if (choice.referenceTypeName.matches(".+\\[\\]")) {
	        // Array
	        	val result = node.createValueNode(choice,getTypeText(choice.referenceTypeName))
	        	choice.value.variables.forEach[IVariable variable |
	        		node.children += node.transformation(variable)
	        		createEdge(choice, variable)
	        	]
	        	return result
	        }  else {
            	// Primitive types
            	return node.createValueNode(choice,getValueText(choice.referenceTypeName,choice.value.toString))
		    }		    
	}
	
	def KNode createValueNode(KNode node, IVariable variable, LinkedList<KText> text) {
		return variable.createNode().putToLookUpWith(variable) => [
			it.setNodeSize(80,80);
		    it.data += renderingFactory.createKRectangle() => [
				it.childPlacement = renderingFactory.createKGridPlacement()
    			text.forEach[
    				KText t |
    				it.children += t
    			]
			]
		]
	}
	
	def createEdge(IVariable first, IVariable second) {
		return new Pair(first,second).createEdge() => [
			it.source = first.node 
			it.target = second.node
			it.data += renderingFactory.createKPolyline() => [
	            it.setLineWidth(2);
	            it.addArrowDecorator();
	        ];
		];
	}
		
	def LinkedList<KText> getValueText(String type, String value) {
		return new LinkedList<KText>() => [
			it += renderingFactory.createKText() => [
				it.text = "<<"+type+">>"
				it.setForegroundColor(120,120,120)
			]
			it += renderingFactory.createKText() => [
				it.text = value
			]
		]
	}
	
	def LinkedList<KText> getTypeText(String type) {
		return new LinkedList<KText>() => [
			it += renderingFactory.createKText() => [
				it.text = type
			]
		]
	}	
}