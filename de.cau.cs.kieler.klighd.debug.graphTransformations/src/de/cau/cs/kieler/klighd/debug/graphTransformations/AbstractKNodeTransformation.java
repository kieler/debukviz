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
package de.cau.cs.kieler.klighd.debug.graphTransformations;

import java.util.LinkedList;

import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.IValue;
import org.eclipse.debug.core.model.IVariable;
import de.cau.cs.kieler.core.krendering.*;
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions;

import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation;

/**
 * @author tit
 * 
 */
public abstract class AbstractKNodeTransformation extends AbstractDebugTransformation {

    /**
     * Constructs a LinkedList<IVariable> from an IVariable that is containing a LinkedList
     * 
     * @param variable
     *            The IVariable that is containing the LinkedList
     * @return A LinkedList with all elements of the input variable
     * @throws NumberFormatException
     * @throws DebugException
     */
    public LinkedList<IVariable> linkedList(IVariable variable) throws NumberFormatException,
            DebugException {
        int size = Integer.parseInt(getValueByName(variable, "size"));

        LinkedList<IVariable> retVal = new LinkedList<IVariable>();

        variable = getVariableByName(variable, "header");

        int i = 0;
        while (i < size) {
            variable = getVariableByName(variable, "next");
            retVal.add(getVariableByName(variable, "element"));
            i++;
        }
        return retVal;
    }

    /**
     * Returns the value mapped to a key, out of a IVariable that is representing a HashMap
     * 
     * @param variable
     *            The IVariable representing the HashMap
     * @param key
     *            The key to look up
     * @return The value to which the specified key is mapped, null if the specified key is not
     *         found
     * @throws NumberFormatException
     * @throws DebugException
     */
    public IVariable getValFromHashMap(IVariable variable, String key)
            throws NumberFormatException, DebugException {
        int size = Integer.parseInt(getValueByName(variable, "threshold"));

        for (int i = 0; i <= size; i++) {
            IVariable current = getVariableByName(variable, "table.[" + i + "]");
            String currentString = getValueByName(current, "key.id");
            if (currentString.equals(key)) {
                return getVariableByName(current, "value");
            }
        }

        return null;
    }

    public String round(String string, int decimalPositions) {
        Double d = Double.valueOf(string);
        long l = Math.round((d * Math.pow(10, decimalPositions)));
        d = (((double) l) / Math.pow(10, decimalPositions));
        return d.toString();
    }

    public IVariable getVariableByName(IVariable variable, String fieldPath, String type)
            throws DebugException {
        String[] fields = fieldPath.split("\\.");
        int j;
        for (j = 0; j < (fields.length - 1); j++) {
            boolean found = false;
            IValue val = variable.getValue();
            // Only search for field if variable has fields
            // TODO: warum die Abfrage? falls es keine Variablen gibt, so ist das vars Array halt
            // leer. Ausserdem wird auf die hier implementiere Version evtl die falsche Variable
            // zurück gegeben: falls die Variable keine Variablen hat, aber der Suchpfad noch nicht
            // komplett durchlaufen wurde!
            if (val.hasVariables()) {
                IVariable[] vars = val.getVariables();
                for (int i = 0; i < vars.length && !found; i++)
                    if (vars[i].getName().equals(fields[j])) {
                        found = true;
                        variable = vars[i];
                    }
                if (!found)
                    return null;
            }
        }
        IValue val = variable.getValue();
        IVariable[] vars = val.getVariables();
        for (int i = 0; i < vars.length; i++) {
            String name = vars[i].getName();
            String refType = vars[i].getReferenceTypeName();
            if (name.equals(fields[j]) && refType.equals(type)) {
                return vars[i];
            }
        }
        return null;
    }
    
    public KText createKText(IVariable variable, String valueText, String prefix, String delimiter) {
        KText retVal = renderingFactory.createKText();
        try {
            retVal.setText(prefix + valueText + delimiter + getValueByName(variable, valueText));
        } catch (DebugException e) {
            return null;
        };
        return retVal;
    }
    
    public String ShortType(IVariable variable) {
        String[] segs;
        try {
            segs = variable.getValue().getReferenceTypeName().split( "\\." );
        } catch (DebugException e) {
            return "!ERROR getting type!";
        }
        return "<<" + segs[segs.length -1] + ">>";
    }
}
