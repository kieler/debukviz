package de.cau.cs.kieler.klighd.debug.ecore

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.KRenderingFactory
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.TransformationContext
import de.cau.cs.kieler.klighd.transformations.AbstractTransformation
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

class EcoreDiagramSynthesis extends AbstractTransformation<IVariable, KNode> {
	
	@Inject
	extension KNodeExtensions
	
	@Inject
	extension KEdgeExtensions
	
    @Inject
    extension KRenderingExtensions
    
    @Inject
    extension KPolylineExtensions
    
	@Inject
	extension KColorExtensions
	
    private static val KRenderingFactory renderingFactory = KRenderingFactory::eINSTANCE

    /**
     * {@inheritDoc}
     */
	override KNode transform(IVariable choice, TransformationContext<IVariable, KNode> transformationContext) {
	    use(transformationContext);
		
		val in = KimlUtil::createInitializedNode
		
		val node = KimlUtil::createInitializedNode
		
        node.data += renderingFactory.createKRectangle()    		
		in.children.add(node)
		
		return in
	}
	
}