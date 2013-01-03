package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.KRenderingFactory
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.TransformationContext
import de.cau.cs.kieler.klighd.transformations.AbstractTransformation
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.transformations.LGraphDiagramSynthesis.*
import de.cau.cs.kieler.klay.layered.graph.LGraph
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation

class LGraphDiagramSynthesis extends AbstractDebugTransformation {
	
    extension KNodeExtensions = new KNodeExtensions()
    extension KEdgeExtensions = new KEdgeExtensions()
    extension KRenderingExtensions = new KRenderingExtensions()
    extension KPolylineExtensions = new KPolylineExtensions()
    extension KColorExtensions = new KColorExtensions()
    
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
      		it.createLayerlessNodes(variable.getVariableByName("layerlessNodes"))
      		it.createLayeredNodes(variable.getVariableByName("layers"))
        ]

	}
	
	def createHeaderNode(KNode rootNode, IVariable variable) {
		rootNode.children += variable.createNode().putToLookUpWith(variable) => [
//    		it.setNodeSize(120,80)
    		it.data += renderingFactory.createKRectangle() => [
    			it.setLineWidth(4)
    			it.setBackgroundColor("lemon".color)
    			it.ChildPlacement = renderingFactory.createKGridPlacement()
    			
    			it.children += renderingFactory.createKText() => [
//    				it.setText("Size: " + variable.getVariableByName("size").getVariableByName("x").getVal)
    				it.setText("size: " + variable.getVariableByName("size").getVal)
            	]
    			
    			it.children += renderingFactory.createKText() => [
                	it.setText("insets: " + variable.getVariableByName("insets").getVal)
            	]
    			
    			it.children += renderingFactory.createKText() => [
                	it.setText("offset: " + variable.getVariableByName("offset").getVal)
            	]
            ]
		]
	}
	
	def createLayerlessNodes(KNode rootNode, IVariable variable) {
		rootNode.children += variable.createNode().putToLookUpWith(variable)
	}
	
	def createLayeredNodes(KNode rootNode, IVariable variable) {
		rootNode.children += variable.createNode().putToLookUpWith(variable)
	}
	
	def getVal(IVariable variable) {
		variable.getValue.getValueString
	}
}