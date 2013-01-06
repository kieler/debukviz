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
import de.cau.cs.kieler.kiml.options.LayoutOptions

class LGraphDiagramSynthesis extends AbstractKNodeTransformation {
	
    extension KNodeExtensions kNodeExtensions = new KNodeExtensions()
    extension KEdgeExtensions kEdgeExtensions = new KEdgeExtensions()
    extension KRenderingExtensions kRenderingExtensions = new KRenderingExtensions()
    extension KColorExtensions kColorExtensions = new KColorExtensions()
    
    
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
    			it.lineWidth = 4
    			it.backgroundColor = "lemon".color
    			it.ChildPlacement = renderingFactory.createKGridPlacement()
    			
                it.children += renderingFactory.createKText() => [
                    it.setText("name: " + variable.name)
                ]
                
                it.children += renderingFactory.createKText() => [
                    it.setText("hashCode: " + variable.getValueByName("hashCode"))
                ]
    			
    			it.children += renderingFactory.createKText() => [
    				it.setText("size (x,y): (" + variable.getValueByName("size.x") + ", " 
    				                           + variable.getValueByName("size.y") + ")" 
                    )
            	]
    			
    			it.children += renderingFactory.createKText() => [
                	it.setText("insets (t,r,b,l): (" + variable.getValueByName("insets.top") + ", "
                	                                 + variable.getValueByName("insets.right") + ", "
                	                                 + variable.getValueByName("insets.bottom") + ", "
                	                                 + variable.getValueByName("insets.left") + ")"
                	)
            	]
    			
    			it.children += renderingFactory.createKText() => [
                	it.setText("offset (x,y): (" + variable.getValueByName("offset.x") + ", "
                	                             + variable.getValueByName("offset.y") + ")"
                	)
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
	
	/**
	 * Create a representation of a LNode
	 * @param rootNode The KNode this node is placed into
     * @param variable The IVariable containing the data for this LNode
	 */
	def createNode(KNode rootNode, IVariable variable) {
        // Get the nodeType
        val nodeType = variable.getVariableByName("propertyMap").getKeyFromHashMap("NODE_TYPE")
        // Get the ports
        val ports = variable.getVariableByName("ports").linkedList
        // Get the labels
        val labels = variable.getVariableByName("labels").linkedList
        
	    rootNode.children += variable.createNode().putToLookUpWith(variable) => [
//            it.setNodeSize(120,80)

            /*
             * Normal nodes. (If nodeType is null, the default type is taken, which is "NORMAL")
             *  - show their name (if set) or their node ID
             *  - are represented by an rectangle  
             */ 
            if (nodeType == null || nodeType.getValueByName("name") == "NORMAL" ) {
                it.data += renderingFactory.createKRectangle() => [
                    it.setLineWidth(2)
    //                it.setBackgroundColor("lemon".color)
                    it.ChildPlacement = renderingFactory.createKGridPlacement()
                    
                    // Name of the node is the first label
                    it.children += renderingFactory.createKText() => [
                        it.setText("hashCode: " + variable.getValueByName("hashCode"))
                    ]
                ]
            }
            
            /*
             * Dummy nodes.
             *  - show their name (if set) or their node ID
             *  - are represented by an ellipses  
             */ 
            else {
                
            }
	    ]
	}
}