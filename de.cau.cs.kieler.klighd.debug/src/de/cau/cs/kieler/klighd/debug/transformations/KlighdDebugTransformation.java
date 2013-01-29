package de.cau.cs.kieler.klighd.debug.transformations;

import javax.inject.Inject;

import org.eclipse.debug.core.model.IVariable;

import de.cau.cs.kieler.core.kgraph.KNode;
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions;
import de.cau.cs.kieler.kiml.options.LayoutOptions;
import de.cau.cs.kieler.klighd.TransformationContext;
import de.cau.cs.kieler.klighd.debug.KlighdDebugExtension;
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation;
import de.cau.cs.kieler.klighd.transformations.AbstractTransformation;

public class KlighdDebugTransformation extends AbstractTransformation<IVariable, KNode> {
	
    
    @Inject 
    private KNodeExtensions kNodeExtensions;
    /**
     * {@inheritDoc}
     */
    public KNode transform(IVariable model, TransformationContext<IVariable,KNode> transformationContext) {
        // perform Transformation
        KNode node = transform(model,transformationContext,null);

        // reset stored information
        AbstractDebugTransformation.resetKNodeMap();
        AbstractDebugTransformation.resetDummyNodeMap();
        //AbstractDebugTransformation.resetNodeCount();
        AbstractDebugTransformation.resetMaxDepth();
        //kNodeExtensions.addLayoutParam(node, LayoutOptions.ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization");
        kNodeExtensions.addLayoutParam(node, LayoutOptions.ALGORITHM, "de.cau.cs.kieler.klay.layered");
        return node;
    }
    
    /**
     * Search for a registred transformation, if none found DefaultTransformation is used
     * transformationInfo is use to realize communication between two transformations.
     * Perform the transformation 
     * 
     * @param model model to be transformed
     * @param transformationContext transformation context in which the transformation is done
     * @param transformationInfo further information to the transformation
     * @return result of the transformation
     */
    @SuppressWarnings("unchecked")
    public KNode transform(IVariable model, TransformationContext<IVariable,KNode>transformationContext,Object transformationInfo) {
        // get transformation if registred for model, null instead
        AbstractDebugTransformation transformation = KlighdDebugExtension.INSTANCE.getTransformation(model);
        
        // use default transformation if no transformation was found
        if (transformation == null)
            transformation = new DefaultTransformation();
        
        //use proxy for injection
        transformation = new ReinitializingTransformationProxy(
                (Class<AbstractDebugTransformation>) transformation.getClass());
        
        return transformation.transform(model,transformationContext, transformationInfo);
    }
}
