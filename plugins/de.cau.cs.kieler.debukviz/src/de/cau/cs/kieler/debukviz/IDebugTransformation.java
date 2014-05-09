/*
 * KIELER - Kiel Integrated Environment for Layout Eclipse RichClient
 *
 * http://www.informatik.uni-kiel.de/rtsys/kieler/
 * 
 * Copyright 2013 by
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

/**
 * An interface for a model-to-model transformation between IVariable and KNode. Further
 * informations which are needed by the transformation is stored as an object
 * 
 * For implementing custom view synthesis transformation we suggest to take
 * {@link de.cau.cs.kieler.debukviz.visualization AbstractDebugTransformation} as super class.
 * 
 * @author hwi
 */
public interface IDebugTransformation {

    /**
     * Performs a transformation from an IVariable to a KNode.
     * 
     * @param model
     *            the source model
     * @return the target model
     */
    public KNode transform(IVariable variable, Object transformationInfo);

    public int getNodeCount(IVariable variable);

}
