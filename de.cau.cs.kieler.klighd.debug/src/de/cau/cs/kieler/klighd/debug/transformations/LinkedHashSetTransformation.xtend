package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement


/**
 * Transformation for a variable which is representing a variable of type "LinkedHashSet"
 */
class LinkedHashSetTransformation extends AbstractDebugTransformation {
   
   @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
    @Inject 
    extension KPolylineExtensions
    @Inject 
    extension KLabelExtensions 
    
    var index = 0;
    var size = 0;
    
    /**
	 * Transformation for a variable which is representing a variable of type "LinkedHashSet"
	 * 
	 * {@inheritDoc}
 	 */
    override transform(IVariable model, Object transformationInfo) {
        return KimlUtil::createInitializedNode() => [
            //it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 50f)
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::RIGHT)
            
            it.data += renderingFactory.createKRectangle()
            
            size = Integer::parseInt(model.getValue("map.size"))
            if (size > 0)
            	it.createKeyValueNode(model.getVariable("map.header.after"))
            else
			{
				it.children += createNode() => [
					it.setNodeSize(80,80)
					it.data += renderingFactory.createKRectangle() => [
						it.children += renderingFactory.createKText() => [
							it.text = "empty"
						]
					]
				]
			}
        ]
    }
    
    /**
     * Adds a node associated with the key stored in a given variable to the given node.
     * Additionally an edge to the next entry will be added.
     * @param node node to which the created node will be added
     * @param variable variable in which the variable representing a key element is stored
     */
    def createKeyValueNode(KNode node, IVariable variable) {
        val key = variable.getVariable("key")
        val after = variable.getVariable("after")
        
        index = index + 1
        
        node.nextTransformation(key)
    
        if (index < size) {
            node.createKeyValueNode(after)
            key.createEdgeById(after.getVariable("key")) => [
                key.createLabel(it) => [
                    it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT,EdgeLabelPlacement::CENTER)
                    it.setLabelSize(50,50)
                    it.text = "after"
                ]
                it.data += renderingFactory.createKPolyline() => [
                    it.setLineWidth(2)
                    it.addArrowDecorator()
                ]
            ]
        }
    }

    override getNodeCount(IVariable model) {
        if (size > 0)
            return size
        else
            return 1
    }
    
}