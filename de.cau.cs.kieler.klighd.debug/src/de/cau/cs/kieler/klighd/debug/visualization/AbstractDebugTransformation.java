package de.cau.cs.kieler.klighd.debug.visualization;

import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.IValue;
import org.eclipse.debug.core.model.IVariable;

import de.cau.cs.kieler.core.kgraph.KNode;
import de.cau.cs.kieler.klighd.transformations.AbstractTransformation;

public abstract class AbstractDebugTransformation extends
		AbstractTransformation<IVariable, KNode> {

	public String getValueByName(IVariable variable, String field)
			throws DebugException {
		IVariable var = getVariableByName(variable, field);
		if (var == null)
			return "null";
		else
			return var.getValue().getValueString();
	}

	/**
	 * Getter for the variable of a specific field stored in a variable
	 * 
	 * @param variable
	 *            variable in which the field is stored
	 * @param field
	 *            name of the field which variable is returned
	 * @return variable represented by field name or null if field doesn't
	 *         exists
	 * @throws DebugException
	 */
	public IVariable getVariableByName(IVariable variable, String field) throws DebugException {
    	String[] fields = field.split("\\.");
        for (String f : fields) {
        	IVariable tmp = getVariable(variable, f);
        	if (tmp == null)
        		return variable;
        	else
        		variable = tmp;
        				
        }
    	return variable;
    }

	private IVariable getVariable(IVariable variable, String field)
			throws DebugException {
		for (IVariable var : variable.getValue().getVariables()) {
			if (var.getName().equals(field))
				return var;
		}
		return null;
	}
}
