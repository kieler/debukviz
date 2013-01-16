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

class EnumMapTransformation extends AbstractDebugTransformation {
   
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
            val keyUniverse = model.getVariablesByName("keyUniverse")
            var index = 0;
            for (value : model.getVariablesByName("vals")) {
            	if (value.valueIsNotNull)
                	it.createKeyValueNode(keyUniverse.get(index),value)
                index = index + 1;
            }
        ]
    }
    
    def createKeyValueNode(KNode node, IVariable key, IVariable value) {
		// Add key node
		node.children += key.createNode() => [
			it.addLabel("Key:")
			it.children += createNode() => [
				it.data += renderingFactory.createKText() => [
					it.text = key.getValueByName("name")
				]  
			]
		]
		
		// Add value node
		node.children += value.createNode() => [
		    it.addLabel("Value:")
		    it.nextTransformation(value)
		]
		
		// Add edge between key node and value node
		key.createEdge(value) => [
        	it.data += renderingFactory.createKPolyline() => [
            	it.setLineWidth(2);
            	it.addArrowDecorator();
        	];
    	]; 
    }
}