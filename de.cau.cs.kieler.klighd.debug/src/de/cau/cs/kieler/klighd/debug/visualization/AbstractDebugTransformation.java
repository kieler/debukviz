package de.cau.cs.kieler.klighd.debug.visualization;

import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedList;

import javax.inject.Inject;

import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.IValue;
import org.eclipse.debug.core.model.IVariable;
import org.eclipse.emf.common.util.EList;
import org.eclipse.jdt.debug.core.IJavaObject;
import org.eclipse.jdt.debug.core.IJavaPrimitiveValue;
import org.eclipse.jdt.debug.core.IJavaValue;

import de.cau.cs.kieler.core.kgraph.KEdge;
import de.cau.cs.kieler.core.kgraph.KLabel;
import de.cau.cs.kieler.core.kgraph.KLabeledGraphElement;
import de.cau.cs.kieler.core.kgraph.KNode;
import de.cau.cs.kieler.core.krendering.KPolyline;
import de.cau.cs.kieler.core.krendering.KRenderingFactory;
import de.cau.cs.kieler.core.krendering.KText;
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions;
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions;
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions;
import de.cau.cs.kieler.core.util.Pair;
import de.cau.cs.kieler.kiml.klayoutdata.KShapeLayout;
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement;
import de.cau.cs.kieler.kiml.options.LayoutOptions;
import de.cau.cs.kieler.kiml.util.KimlUtil;
import de.cau.cs.kieler.klighd.TransformationContext;
import de.cau.cs.kieler.klighd.debug.IKlighdDebug;
import de.cau.cs.kieler.klighd.debug.transformations.KlighdDebugTransformation;
import de.cau.cs.kieler.klighd.transformations.AbstractTransformation;

public abstract class AbstractDebugTransformation extends AbstractTransformation<IVariable, KNode>
        implements IKlighdDebug {

    @Inject
    private KEdgeExtensions kEdgeExtensions = new KEdgeExtensions();
    @Inject
    private KPolylineExtensions kPolylineExtensions = new KPolylineExtensions();
    @Inject
    private KNodeExtensions kNodeExtensions = new KNodeExtensions();
    
    protected static final KRenderingFactory renderingFactory = KRenderingFactory.eINSTANCE;

    private Object transformationInfo;
    private static final HashMap<Long, KNode> kNodeMap = new HashMap<Long, KNode>();
    private static Integer depth = 0;
    private static Integer nodeCount = 0;
    private static Integer maxDepth = 20;

    public Object getTransformationInfo() {
        return transformationInfo;
    }

    public void setTransformationInfo(Object transformationInfo) {
        this.transformationInfo = transformationInfo;
    }

    public static void resetKNodeMap() {
        kNodeMap.clear();
    }

    public static void resetNodeCount() {
        nodeCount = 0;
    }
    
    public static void resetMaxDepth() {
        maxDepth = 20;
    }

    public KNode nextTransformation(KNode rootNode, IVariable variable) throws DebugException {
        return nextTransformation(rootNode, variable, null);
    }
    
    private int countNodes(KNode rootNode) {
        int count = 0;
        EList<KNode> nodes = rootNode.getChildren();
        count += nodes.size();
        for (KNode node : nodes)
            count += countNodes(node);
        return count;
    }

    public KNode nextTransformation(KNode rootNode, IVariable variable, Object transformationInfo) throws DebugException {
        int maxNodeCount = -1;
        KNode innerNode = null;
        // Perform transformation if recursion depth less-equal maxDepth
        if (depth <= maxDepth) {
            depth++;
            innerNode = new KlighdDebugTransformation().transform(variable, this.getUsedContext(),
                    transformationInfo);
            // Calculate nodeCount
            /*if (nodeCount > maxNodeCount)
                maxDepth = depth;
            else {
                //int test = countNodes(innerNode);
                //int test2 = nodeCount;
                nodeCount += countNodes(innerNode);
            }*/
            depth--;
            EList<KNode> rootChildren = rootNode.getChildren();
            EList<KNode> innerChildren = innerNode.getChildren();
            //rootNode.getChildren().addAll(innerNode.getChildren());
            if(innerNode.getChildren().size() == 1)
            	innerNode = innerNode.getChildren().get(0);
            if (kNodeMap.get(getId(variable)) == null)
            	kNodeMap.put(getId(variable), innerNode);

            rootNode.getChildren().add(innerNode);
        }
        else {
            innerNode = kNodeExtensions.createNode(variable);
            KNode node = kNodeExtensions.createNode();
            
            
            KText type = renderingFactory.createKText();
            type.setText(variable.getReferenceTypeName());
            KText name = renderingFactory.createKText();
            type.setText(variable.getName());
            
            node.getData().add(type);
            node.getData().add(name);
            
            innerNode.getChildren().add(node);
            rootNode.getChildren().add(innerNode);
        }
	    return innerNode;
    }

    public String getValue(IVariable variable, String fieldPath) throws DebugException {
        IVariable var = getVariable(variable, fieldPath);
        if (var != null)
            return var.getValue().getValueString();
        return "null";
    }

    public IVariable[] getVariables(IVariable variable, String fieldPath) throws DebugException {
        IVariable var = getVariable(variable, fieldPath);
        if (var != null)
            return var.getValue().getVariables();
        else
            return null;
    }

    public IVariable getVariable(IVariable variable, String fieldPath, boolean superField)
            throws DebugException {
        // Split fieldPath into a list of field names
        LinkedList<String> fieldNames = new LinkedList<String>(
                Arrays.asList(fieldPath.split("\\.")));
        String lastFieldName = fieldNames.getLast();
        // Iterate over list of field names
        for (String fieldName : fieldNames) {
            boolean superF = false;
            if (fieldName.equals(lastFieldName))
                superF = superField;
            IJavaObject javaObject = (IJavaObject) variable.getValue();
            variable = (IVariable) javaObject.getField(fieldName, superF);
        }
        return variable;
    }

    public IVariable getVariable(IVariable variable, String fieldPath) throws DebugException {
        return getVariable(variable, fieldPath, false);
    }

    public String getType(IVariable variable) throws DebugException {
    	String type = variable.getValue().getReferenceTypeName(); 
        return type.substring(type.lastIndexOf('.')+1);
    }

    public KEdge createEdgeById(IVariable source, IVariable target) throws DebugException {
        KEdge edge = kEdgeExtensions.createEdge(new Pair<Object, Object>(source, target));
        edge.setSource(createNodeById(source));
        edge.setTarget(createNodeById(target));
        return edge;
    }

    public KEdge createEdge(IVariable source, IVariable target) throws DebugException {
        KEdge edge = kEdgeExtensions.createEdge(new Pair<Object, Object>(source, target));
        edge.setSource(kNodeExtensions.getNode(source));
        edge.setTarget(kNodeExtensions.getNode(target));
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
        // perform transformation
        KNode node = this.transform(model);
        // clear local stored information
        this.setTransformationInfo(null);
        return node;
    }

    public KLabel addLabel(KLabeledGraphElement node, String label) {
        KLabel kLabel = KimlUtil.createInitializedLabel(node);
        kLabel.setText(label);
        
        KShapeLayout shapeLayout = kLabel.getData(KShapeLayout.class);
        shapeLayout.setProperty(LayoutOptions.EDGE_LABEL_PLACEMENT, EdgeLabelPlacement.CENTER);
        shapeLayout.setWidth(60.0f);
        shapeLayout.setHeight(50.0f);
        
        node.getLabels().add(kLabel);
        return kLabel;
    }

    public boolean nodeExists(IVariable variable) throws DebugException {
        return kNodeMap.get(getId(variable)) != null || kNodeExtensions.getNode(variable).getParent() != null;
    }

    public Long getId(IVariable variable) throws DebugException {
        IJavaValue value = (IJavaValue) variable.getValue();
        if (!(value instanceof IJavaObject) || ((IJavaObject) value).isNull())
            return new Long(-kNodeMap.size());
        else
            return ((IJavaObject) value).getUniqueId();
    }

    /**
     * Returns an existing or new node linked with the id of object re            innerNode = new KlighdDebugTransformation().transform(variable, this.getUsedContext(),
                    transformationInfo);presented by variable
     * 
     * @param variable
     *            variable representing the object, which id is linked with an node
     * @return existing or new node
     * @throws DebugException
     */
    public KNode createNodeById(IVariable variable) throws DebugException {
        KNode node = null;
    	Long id = getId(variable);
        if (id != -1) {
        	node = kNodeMap.get(id);
	        if (node == null) {
	        	node = kNodeExtensions.createNode(variable);
	            kNodeMap.put(id, node);
	        }
        }
        else
        	node = kNodeExtensions.createNode(variable);
        return node;
    }
    
    public KNode addNewNodeById(KNode node, IVariable variable) throws DebugException {
    	KNode resultNode = null;
    	/*if (nodeExists(variable)) {
    		//resultNode = createNodeById(variable);
    		//node.getChildren().add(resultNode);
    		KNode parent = node;
    		while (parent != null)
    			parent = parent.getParent();

    		//node.setParent(parent);
    		resultNode = kNodeExtensions.createNode(null);
    		
    		/*KEdge edge = kEdgeExtensions.createEdge(new Pair<Object, Object>(resultNode, node));
            edge.setSource(resultNode);
            edge.setTarget(node);
            
            KPolyline polyline = renderingFactory.createKPolyline();
            kPolylineExtensions.
            it.data += renderingFactory.createKPolyline() => [
                                                              it.setLineWidth(2)
                                                              it.addArrowDecorator();
                                                          ]*/
    		//node.getChildren().add(resultNode);
    		//create dummyNode
    		//resultNode = dummyNode
    	/*}
    	else {*/
    		resultNode = createNodeById(variable);
    		resultNode.setParent(node);
    		//node.getChildren().add(resultNode);
    	//}
    	return resultNode;
    }
}
