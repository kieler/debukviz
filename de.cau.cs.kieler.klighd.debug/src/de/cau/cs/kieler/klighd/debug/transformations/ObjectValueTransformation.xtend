package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.core.krendering.KRenderingFactory
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.transformations.ObjectValueTransformation.*

class ObjectValueTransformation extends AbstractDebugTransformation {
   
    @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
    
    private static val KRenderingFactory renderingFactory = KRenderingFactory::eINSTANCE   
    
    override transform(IVariable model, Object transformationInfo) {
        return 
        KimlUtil::createInitializedNode() => [
        	val node = it.addNewNodeById(model) 
        	if (node != null)
            	node => [
    	            it.setNodeSize(80,80);
    	            it.data += renderingFactory.createKRectangle() => [
    	                it.childPlacement = renderingFactory.createKGridPlacement()
    	                it.children += renderingFactory.createKText() => [
                            it.text = "<<"+model.type+">>"
                            it.setForegroundColor(120,120,120)
                        ]
                        it.children += renderingFactory.createKText() => [
                            it.text = model.getValue("value")
                        ]
    	            ]
                ]
        ]
    }
   
}