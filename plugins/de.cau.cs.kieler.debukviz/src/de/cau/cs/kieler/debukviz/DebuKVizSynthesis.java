/*
 * DebuKViz - Kieler Debug Visualization
 * 
 * A part of OpenKieler
 * https://github.com/OpenKieler
 * 
 * Copyright 2014 by
 * + Christian-Albrechts-University of Kiel
 *   + Department of Computer Science
 *     + Real-Time and Embedded Systems Group
 * 
 * This code is provided under the terms of the Eclipse Public License (EPL).
 * See the file epl-v10.html for the license text.
 */
package de.cau.cs.kieler.debukviz;

import org.eclipse.debug.core.model.IVariable;

import de.cau.cs.kieler.core.kgraph.KNode;
import de.cau.cs.kieler.debukviz.dialog.DebuKVizDialog;
import de.cau.cs.kieler.debukviz.transformations.DefaultTransformation;
import de.cau.cs.kieler.klighd.syntheses.AbstractDiagramSynthesis;

/**
 * KLighD synthesis that provides the entry point into DebuKViz. Invokes the transformations registered
 * with DebuKViz to produce the visual representation of variables.
 */
public final class DebuKVizSynthesis extends AbstractDiagramSynthesis<IVariable> {
    
    private AbstractVariableTransformation transformation = null;

    /**
     * {@inheritDoc}
     */
    public KNode transform(IVariable model) {
        // perform Transformation
        KNode node = transformation(model, null);

        // reset stored information
        AbstractVariableTransformation.resetKNodeMap();
        AbstractVariableTransformation.resetDummyNodeMap();
        AbstractVariableTransformation.resetNodeCount();
        DebuKVizDialog.resetShown();
        return node;
    }

    /**
     * Search for a registered transformation, if none found DefaultTransformation is used
     * transformationInfo is use to realize communication between two transformations. Perform the
     * transformation
     * 
     * @param model
     *            model to be transformed
     * @param transformationContext
     *            transformation context in which the transformation is done
     * @param transformationInfo
     *            further information used by transformation
     * @return result of the transformation
     */
    @SuppressWarnings("unchecked")
    public KNode transformation(IVariable model, Object transformationInfo) {
        // get transformation if registered for model, null instead
        transformation = DebuKVizTransformationService.INSTANCE.getTransformation(model);

        // use default transformation if no transformation was found
        if (transformation == null) {
            transformation = new DefaultTransformation();
        }

        // use proxy for injection
        transformation = new ReinitializingTransformationProxy(
                (Class<AbstractVariableTransformation>) transformation.getClass());
        
        if (transformation.getActualNodeCount() <= transformation.getMaxNodeCount()) {
            return transformation.transform(model, transformationInfo);
        } else {
            return null;
        }
    }

    public int getNodeCount(IVariable model) {
        return transformation.getNodeCount(model);
    }
}
