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

class LinkedHashSetTransformation extends AbstractDebugTransformation {
   
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
            model.getVariablesByName("map.table").filter[variable | variable.valueIsNotNull].forEach[
                IVariable variable | 
               	val vari = variable.getVariableByName("key")
               	val before = variable.getVariableByName("before")
               	it.children += variable.createNode().putToKNodeMap(variable,true) => [
               		it.nextTransformation(vari)
       			]
       			if (before.getVariableByName("key").valueIsNotNull)
	       			before.createEdge(variable,true,true) => [
	            		it.data += renderingFactory.createKPolyline() => [
	                		it.setLineWidth(2);
	                		it.addArrowDecorator();
	            		];
	       		];
       		]
		]
    }
}