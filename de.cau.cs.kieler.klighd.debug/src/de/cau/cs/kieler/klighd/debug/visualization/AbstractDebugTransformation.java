package de.cau.cs.kieler.klighd.debug.visualization;

import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.IValue;
import org.eclipse.debug.core.model.IVariable;

import de.cau.cs.kieler.core.kgraph.KNode;
import de.cau.cs.kieler.klighd.transformations.AbstractTransformation;

public abstract class AbstractDebugTransformation extends AbstractTransformation<IVariable, KNode> {

    /**
     * Getter for the value of a specific field stored in a variable
     * 
     * @param variable
     *            variable in which the field is stored
     * @param field
     *            name of the field which value is returned
     * @return value of field stored in variable or null if field doesn't exists
     * @throws DebugException
     */
    public IValue getValue(IVariable variable, String field) throws DebugException {
        return getVariableByName(variable, field).getValue();
    }

    /**
     * Getter for the variable of a specific field stored in a variable
     * 
     * @param variable
     *            variable in which the field is stored
     * @param field
     *            name of the field which variable is returned
     * @return variable represented by field name or null if field doesn't exists
     * @throws DebugException
     */
    public IVariable getVariableByName(IVariable variable, String field) throws DebugException {
        for (IVariable var : variable.getValue().getVariables()) {
            if (var.getName().equals(field))
                return var;
        }
        return null;
    }
}
