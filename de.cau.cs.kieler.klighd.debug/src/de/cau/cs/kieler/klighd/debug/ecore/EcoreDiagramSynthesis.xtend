package de.cau.cs.kieler.klighd.debug.ecore

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.KRenderingFactory
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.TransformationContext
import de.cau.cs.kieler.klighd.transformations.AbstractTransformation
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.ecore.EcoreDiagramSynthesis.*

class EcoreDiagramSynthesis extends AbstractTransformation<IVariable, KNode> {
	
    private static val KRenderingFactory renderingFactory = KRenderingFactory::eINSTANCE

    /**
     * {@inheritDoc}
     */
	override KNode transform(IVariable choice, TransformationContext<IVariable, KNode> transformationContext) {
	    use(transformationContext);
		
		val in = KimlUtil::createInitializedNode
		
		val node = KimlUtil::createInitializedNode
		
        node.data += renderingFactory.createKRectangle()
        node.data += renderingFactory.createKText() => [
            it.setText(choice.name)
        ]
		in.children.add(node)
		
		return in
	}
	
}