package de.cau.cs.kieler.klighd.debug.ecore

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.KRenderingFactory
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.TransformationContext
import de.cau.cs.kieler.klighd.transformations.AbstractTransformation
import org.eclipse.debug.core.model.IVariable
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.options.Direction
import static de.cau.cs.kieler.klighd.debug.ecore.EcoreDiagramSynthesis.*
import javax.inject.Inject
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions

class EcoreDiagramSynthesis extends AbstractTransformation<IVariable, KNode> {
	
	@Inject
    extension KNodeExtensions
	
    private static val KRenderingFactory renderingFactory = KRenderingFactory::eINSTANCE

    /**
     * {@inheritDoc}
     */
	override KNode transform(IVariable choice, TransformationContext<IVariable, KNode> transformationContext) {
	    use(transformationContext);	
		return KimlUtil::createInitializedNode() => [
		    it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization");
            it.addLayoutParam(LayoutOptions::SPACING, 75f);
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::UP);
            
            it.children += KimlUtil::createInitializedNode() => [
                it.setNodeSize(80,80);
                it.data += renderingFactory.createKRectangle() => [
                    it.children += renderingFactory.createKText() => [
                        it.setText(choice.name)
                    ]
                ]
            ]
		]
	}
	
}