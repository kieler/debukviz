package de.cau.cs.kieler.klighd.debug.visualization;

import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.IValue;
import org.eclipse.debug.core.model.IVariable;

import de.cau.cs.kieler.core.kgraph.KNode;
import de.cau.cs.kieler.klighd.debug.transformations.KlighdDebugTransformation;
import de.cau.cs.kieler.klighd.transformations.AbstractTransformation;

public abstract class AbstractDebugTransformation extends AbstractTransformation<IVariable, KNode> {
    
    public KNode nextTransformation(KNode rootNode, IVariable variable) {
        //rootNode.getChildren().clear();
        KlighdDebugTransformation transformation = new KlighdDebugTransformation();
        KNode innerNode = transformation.transform(variable, this.getUsedContext());
        //new KNodeExtensions().addLayoutParam(innerNode, LayoutOptions.BORDER_SPACING, 0f);
        rootNode.getChildren().add(innerNode);
        return innerNode;
    }

    public String getValueByName(IVariable variable, String field) throws DebugException {
        IVariable var = getVariableByName(variable, field);
        if (var != null)
            return var.getValue().getValueString();
        return "null";
    }

    public IVariable[] getVariablesByName(IVariable variable, String field) throws DebugException {
        IVariable var = getVariableByName(variable, field);
        if (var != null) {
            IValue val = var.getValue();
            if (val.hasVariables())
                return val.getVariables();
        }
        return null;
    }

    /**
     * Getter for the variable of a specific field stored in a variable
     * 
     * @param variable
     *            variable in which the field is stored
     * @param fieldPath
     *            Dot separated path of names to the field which variable is returned
     * @return variable represented by target field name or null if target field doesn't exists
     * @throws DebugException
     */
    public IVariable getVariableByName(IVariable variable, String fieldPath) throws DebugException {
        String[] fields = fieldPath.split("\\.");
        for (String f : fields) {
            boolean found = false;
            IValue val = variable.getValue();
            // Only search for field if variable has fields
            if (val.hasVariables()) {
                IVariable[] vars = val.getVariables();
                for (int i = 0; i < vars.length && !found; i++)
                    if (vars[i].getName().equals(f)) {
                        found = true;
                        variable = vars[i];
                    }
                if (!found)
                    return null;
            }
        }
        return variable;
    }

    public String getType(IVariable variable) throws DebugException {
        return variable.getValue().getReferenceTypeName();
    }
}
