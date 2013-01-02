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

class LGraphDiagramSynthesis extends AbstractDebugTransformation<LGraph, KNode> {
    
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
    override KNode transform(LGraph choice, TransformationContext<LGraph, KNode> transformationContext) {
        use(transformationContext);
		
        return KimlUtil::createInitializedNode => [
            choice.forEach[]
		    val containedNodes = choice.layerlessNodes;
		    choice.layers.forEach[containedNodes.addAll(nodes)];
		]
	}

	override transform(IVariable model, TransformationContext<IVariable,KNode> transformationContext) {
		throw new UnsupportedOperationException("Auto-generated function stub")
	}
	
}