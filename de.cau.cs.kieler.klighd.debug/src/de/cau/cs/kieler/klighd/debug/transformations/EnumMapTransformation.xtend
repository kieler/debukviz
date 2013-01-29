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
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement

class EnumMapTransformation extends AbstractDebugTransformation {
   
    @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
    @Inject 
    extension KPolylineExtensions 
    @Inject 
    extension KLabelExtensions 
    
    override transform(IVariable model, Object transformationInfo) {
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::RIGHT)
            val keyUniverse = model.getVariables("keyUniverse")
            var index = 0;
            for (value : model.getVariables("vals")) {
            	if (value.valueIsNotNull)
                	it.createKeyValueNode(keyUniverse.get(index),value)
                index = index + 1;
            }
        ]
    }
    
    def createKeyValueNode(KNode node, IVariable key, IVariable value) {
		// Add key node
		node.addNewNodeById(key)?.children += createNode() => [
			it.data += renderingFactory.createKText() => [
				it.text = key.getValue("name")
			]
		]
		
		// Add value node
		node.nextTransformation(value)
		
		// Add edge between key node and value node
		key.createEdgeById(value) => [
            value.createLabel(it) => [
                it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT,EdgeLabelPlacement::CENTER)
                it.text = "value";
                it.setLabelSize(50,50)
            ]
        	it.data += renderingFactory.createKPolyline() => [
            	it.setLineWidth(2);
            	it.addArrowDecorator();
        	];
    	]; 
    }
}