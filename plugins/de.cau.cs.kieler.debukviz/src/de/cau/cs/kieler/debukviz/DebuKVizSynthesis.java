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

import org.eclipse.core.runtime.Status;
import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.IVariable;
import org.eclipse.ui.statushandlers.StatusManager;

import de.cau.cs.kieler.core.kgraph.KNode;
import de.cau.cs.kieler.debukviz.ui.DebuKVizDialog;
import de.cau.cs.kieler.kiml.klayoutdata.KShapeLayout;
import de.cau.cs.kieler.kiml.options.Direction;
import de.cau.cs.kieler.kiml.options.LayoutOptions;
import de.cau.cs.kieler.kiml.util.KimlUtil;
import de.cau.cs.kieler.klay.layered.p4nodes.NodePlacementStrategy;
import de.cau.cs.kieler.klay.layered.properties.Properties;
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
        
        // Generate a top-level KNode and set some layout options
        KNode graph = KimlUtil.createInitializedNode();
        KShapeLayout graphLayout = graph.getData(KShapeLayout.class);
        graphLayout.setProperty(LayoutOptions.DIRECTION, Direction.DOWN);
        graphLayout.setProperty(Properties.NODE_PLACER, NodePlacementStrategy.LINEAR_SEGMENTS);
        
        // Generate a transformation context
        VariableTransformationContext context = new VariableTransformationContext();
        
        // Start the mighty transformation!
        try {
            VariableTransformation.invokeFor(variable, graph, context);
        } catch (DebugException e) {
            StatusManager.getManager().handle(new Status(
                    Status.ERROR,
                    DebuKVizPlugin.PLUGIN_ID,
                    "Error accessing the Eclipse debug framework.",
                    e));
        }
        
        return graph;
    }
    
}
