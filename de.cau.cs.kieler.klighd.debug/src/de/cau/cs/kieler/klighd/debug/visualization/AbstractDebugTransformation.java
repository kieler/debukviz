package de.cau.cs.kieler.klighd.debug.visualization;

import java.util.HashMap;

import javax.inject.Inject;

import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.IValue;
import org.eclipse.debug.core.model.IVariable;

import de.cau.cs.kieler.core.kgraph.KEdge;
import de.cau.cs.kieler.core.kgraph.KNode;
import de.cau.cs.kieler.core.krendering.KRenderingFactory;
import de.cau.cs.kieler.core.krendering.KText;
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions;
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions;
import de.cau.cs.kieler.core.util.Pair;
import de.cau.cs.kieler.klighd.TransformationContext;
import de.cau.cs.kieler.klighd.debug.IKlighdDebug;
import de.cau.cs.kieler.klighd.debug.transformations.KlighdDebugTransformation;
import de.cau.cs.kieler.klighd.transformations.AbstractTransformation;

public abstract class AbstractDebugTransformation extends AbstractTransformation<IVariable, KNode>
        implements IKlighdDebug {

    @Inject
    private KEdgeExtensions kEdgeExtensions = new KEdgeExtensions();
    @Inject
    private KNodeExtensions kNodeExtensions = new KNodeExtensions();

    protected static final KRenderingFactory renderingFactory = KRenderingFactory.eINSTANCE;

    private HashMap<Pair<IVariable, String>, KNode> kNodeMap = new HashMap<Pair<IVariable, String>, KNode>();

    private Object transformationInfo;

    public Object getTransformationInfo() {
        return transformationInfo;
    }

    public void setTransformationInfo(Object transformationInfo) {
        this.transformationInfo = transformationInfo;
    }

    public KNode nextTransformation(KNode rootNode, IVariable variable, Object transformationInfo) {
        KlighdDebugTransformation transformation = new KlighdDebugTransformation();
        transformation.setTransformationInfo(transformationInfo);
        KNode innerNode = transformation.transform(variable, this.getUsedContext());
        rootNode.getChildren().addAll(innerNode.getChildren());
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
    
    public KEdge createEdge(IVariable source, IVariable target) {
        return createEdge(source, target,false,false);
    }

    public KEdge createEdge(IVariable source, IVariable target, boolean sourceUnique, boolean targetUnique) {
        KEdge edge = kEdgeExtensions.createEdge(new Pair<Object, Object>(source, target));
        edge.setSource(getNode(source,sourceUnique));
        edge.setTarget(getNode(target,targetUnique));
        return edge;
    }

    public boolean valueIsNotNull(IVariable variable) {
        try {
            return !variable.getValue().getValueString().equals("null");
        } catch (DebugException e) {
            return false;
        }
    }

    public KNode transform(IVariable model,
            TransformationContext<IVariable, KNode> transformationContext) {
        use(transformationContext);
        return this.transform(model);
    }

    public KNode getLabel(String label) {
        KNode node = kNodeExtensions.createNode();
        KText text = renderingFactory.createKText();
        text.setText(label);
        node.getData().add(text);
        return node;
    }
    
    public KNode putToKNodeMap(KNode derived, IVariable source) {
        return putToKNodeMap(derived, source, false);
    }

    public KNode putToKNodeMap(KNode derived, IVariable source, boolean unique) {
        IVariable variable = source;
        if (unique)
            variable = null;
        kNodeMap.put(new Pair<IVariable,String>(variable, getID(source)), derived);
        return super.putToLookUpWith(derived, source);
    }

    public KNode getNode(IVariable key, boolean unique) {
        IVariable variable = key;
        if (unique)
            variable = null;
        KNode result = kNodeMap.get(new Pair<IVariable,String>(variable,getID(key)));
        if (result == null)
            result = kNodeExtensions.createNode();
        return result;
    }

    public String getID(IVariable variable) {
        try {
            return variable.getValue().getValueString().replaceAll("\\D", "");
        } catch (DebugException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return "";
    }
}
