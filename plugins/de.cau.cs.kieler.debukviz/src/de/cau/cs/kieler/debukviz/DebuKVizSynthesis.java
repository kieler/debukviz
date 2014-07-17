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
import de.cau.cs.kieler.kiml.util.KimlUtil;
import de.cau.cs.kieler.klighd.syntheses.AbstractDiagramSynthesis;

/**
 * KLighD synthesis that provides the entry point into DebuKViz. Invokes the transformations registered
 * with DebuKViz to produce the visual representation of variables.
 */
public final class DebuKVizSynthesis extends AbstractDiagramSynthesis<IVariable> {
    
    /**
     * {@inheritDoc}
     */
    public KNode transform(final IVariable variable) {
        DebuKVizDialog.resetShown();
        
        // Generate a top-level KNode and a transformation context
        KNode graph = KimlUtil.createInitializedNode();
        VariableTransformationContext context = new VariableTransformationContext();
        
        // Start the mighty transformation!
        VariableTransformation.invokeFor(variable, graph, context);
        
        return graph;
    }
    
}
