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
package de.cau.cs.kieler.klighd.debug.transformations;

import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.IVariable;

import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation;

/**
 * @author tit
 * 
 */
public abstract class AbstractKNodeTransformation extends AbstractDebugTransformation {

    public IVariable[] linkedListToArray(IVariable variable) throws NumberFormatException,
            DebugException {
        int size = Integer.parseInt(getValueByName(variable, "size"));
        IVariable[] retVal = new IVariable[size];

        variable = getVariableByName(variable, "header");

        int i = 0;
        while (i < size) {
            variable = getVariableByName(variable, "next");
            retVal[i] = getVariableByName(variable, "element");
            i++;
        }
        return retVal;
    }
    
    /**
     * Returns the value for a key out of a IVariable, that is representing a HashMap
     * @param variable The IVariable representing the HashMap
     * @param key The key to look up
     * @return The value to which the specified key is mapped
     * @throws NumberFormatException
     * @throws DebugException
     */
    public String getPropertyFromHashMap(IVariable variable, String key) throws NumberFormatException, DebugException {
        int size = Integer.parseInt(getValueByName(variable, "size"));
        
        for(int i = 0; i < size; i++) {
            IVariable current = getVariableByName(variable, "table.[" + i + "]");
            if (getValueByName(current, "key.id") == key) {
                return getValueByName(current, "value.value");
            }
        }
        
        return null;
    }
}
