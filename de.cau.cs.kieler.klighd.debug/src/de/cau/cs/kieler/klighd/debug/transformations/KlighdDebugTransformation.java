package de.cau.cs.kieler.klighd.debug.transformations;

import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.IVariable;

import de.cau.cs.kieler.core.kgraph.KNode;
import de.cau.cs.kieler.klighd.TransformationContext;
import de.cau.cs.kieler.klighd.debug.KlighdDebugExtension;
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation;

public class KlighdDebugTransformation extends AbstractDebugTransformation {

    @SuppressWarnings("unchecked")
    public KNode transform(IVariable model, TransformationContext<IVariable,KNode> transformationContext) {
        AbstractDebugTransformation transformation = null;
        try {
            transformation = KlighdDebugExtension.INSTANCE.getTransformation(model);
        } catch (DebugException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        if (transformation == null)
            transformation = new DefaultTransformation();
        transformation = new ReinitializingTransformationProxy(
                (Class<AbstractDebugTransformation>) transformation.getClass());
        return transformation.transform(model,transformationContext);
    }

    public KNode transform(IVariable model) {
        return null;
    }
}
