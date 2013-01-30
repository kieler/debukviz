package de.cau.cs.kieler.klighd.debug.visualization;

import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedList;

import javax.inject.Inject;

import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.IVariable;
import org.eclipse.jdt.debug.core.IJavaObject;
import org.eclipse.jdt.debug.core.IJavaValue;

import de.cau.cs.kieler.core.kgraph.KEdge;
import de.cau.cs.kieler.core.kgraph.KNode;
import de.cau.cs.kieler.core.krendering.KEllipse;
import de.cau.cs.kieler.core.krendering.KPolyline;
import de.cau.cs.kieler.core.krendering.KRectangle;
import de.cau.cs.kieler.core.krendering.KRenderingFactory;
import de.cau.cs.kieler.core.krendering.KText;
import de.cau.cs.kieler.core.krendering.extensions.KContainerRenderingExtensions;
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions;
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions;
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions;
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions;
import de.cau.cs.kieler.klighd.TransformationContext;
import de.cau.cs.kieler.klighd.debug.IKlighdDebug;
import de.cau.cs.kieler.klighd.debug.transformations.KlighdDebugTransformation;
import de.cau.cs.kieler.klighd.transformations.AbstractTransformation;

public abstract class AbstractDebugTransformation extends AbstractTransformation<IVariable, KNode>
        implements IKlighdDebug {

    @Inject
    private KEdgeExtensions kEdgeExtensions = new KEdgeExtensions();
    @Inject
    private KRenderingExtensions kRenderingExtensions = new KRenderingExtensions();
    @Inject
    private KContainerRenderingExtensions kContainerRenderingExtensions = new KContainerRenderingExtensions();
    @Inject
    private KPolylineExtensions kPolylineExtensions = new KPolylineExtensions();
    @Inject
    private KNodeExtensions kNodeExtensions = new KNodeExtensions();

    protected static final KRenderingFactory renderingFactory = KRenderingFactory.eINSTANCE;

    private Object transformationInfo;
    private static final HashMap<Long, KNode> kNodeMap = new HashMap<Long, KNode>();
    private static final HashMap<IVariable, KNode> dummyNodeMap = new HashMap<IVariable, KNode>();
    private static Integer depth = 0;
    //private static Integer nodeCount = 0;
    private static Integer maxDepth = 10;

    public Object getTransformationInfo() {
        return transformationInfo;
    }

    public void setTransformationInfo(Object transformationInfo) {
        this.transformationInfo = transformationInfo;
    }

    public static void resetKNodeMap() {
        kNodeMap.clear();
    }
    
    public static void resetDummyNodeMap() {
        dummyNodeMap.clear();
    }

    //public static void resetNodeCount() {
    //    nodeCount = 0;
    //}

    public static void resetMaxDepth() {
        maxDepth = 5;
    }

    public KNode nextTransformation(IVariable variable) throws DebugException {
        return nextTransformation(variable, null);
    }

//    private int countNodes(KNode rootNode) {
//        int count = 0;
//        EList<KNode> nodes = rootNode.getChildren();
//        count += nodes.size();
//        for (KNode node : nodes)
//            count += countNodes(node);
//        return count;
//    }

    public KNode nextTransformation(IVariable variable, Object transformationInfo)
            throws DebugException {
        //int maxNodeCount = -1;
        if (nodeExists(variable)) {
            return createDummyNode(variable);
        }
        else {
         // Perform transformation if recursion depth less-equal maxDepth
            if (depth <= maxDepth) {
                depth++;
                KNode innerNode = new KlighdDebugTransformation().transform(variable, this.getUsedContext(),
                        transformationInfo);
                // Calculate nodeCount
                //if (nodeCount > maxNodeCount) 
                //  maxDepth = depth; 
                //else { 
                //  int test = countNodes(innerNode); 
                //  int test2 = nodeCount; nodeCount += countNodes(innerNode); 
                //}
                depth--;
                while (innerNode.getChildren().size() == 1)
                    innerNode = innerNode.getChildren().get(0);
                if (kNodeMap.get(getId(variable)) == null)
                    kNodeMap.put(getId(variable), innerNode);                
                
                KText type = renderingFactory.createKText();
                type.setText(variable.getReferenceTypeName());
                
                return innerNode;
            } else {
                KNode innerNode = kNodeExtensions.createNode(variable);
                kNodeExtensions.setNodeSize(innerNode, 80, 80);
                
                KRectangle rec = renderingFactory.createKRectangle();
                rec.setChildPlacement(renderingFactory.createKGridPlacement());
                
                KText type = renderingFactory.createKText();
                type.setText(variable.getReferenceTypeName());
                KText name = renderingFactory.createKText();
                type.setText(variable.getName());
    
                rec.getChildren().add(type);
                rec.getChildren().add(name);
                innerNode.getData().add(rec);
                
                return innerNode;
            }
        }   
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
        return type.substring(type.lastIndexOf('.') + 1);
    }

    public KEdge createEdgeById(IVariable source, IVariable target) throws DebugException {
        KEdge edge = kEdgeExtensions.createEdge();
        KNode sourceNode = dummyNodeMap.get(source);
        KNode targetNode = dummyNodeMap.get(target);
        if (sourceNode == null)
            sourceNode = getNode(source);
        if (targetNode == null)
            targetNode = getNode(target);
        edge.setSource(sourceNode);
        edge.setTarget(targetNode);        
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
            TransformationContext<IVariable, KNode> transformationContext, Object transformationInfo) {
        use(transformationContext);
        // perform transformation
        KNode node = this.transform(model, transformationInfo);
        // clear local stored information
        return node;
    }
    
    public KNode transform(IVariable model, TransformationContext<IVariable,KNode> transformationContext) {
        throw null;
    }
    
    public KNode getNode(IVariable variable) throws DebugException {
        KNode node = kNodeMap.get(getId(variable));
        if (node == null) {
            node = kNodeExtensions.getNode(variable);
            if (node.getParent() == null)
                node = null;
        }
        return node;
    }

    public boolean nodeExists(IVariable variable) throws DebugException {
        return kNodeMap.containsKey(getId(variable)) || kNodeExtensions.getNode(variable).getParent() != null;
    }
    /**
     * Returns unique id of the object respresenting by variable
     * @param variable
     * @return unique id or -1 if object is null or -2 if variable represents a primitiv value
     * @throws DebugException
     */
    private Long getId(IVariable variable) throws DebugException {
        IJavaValue value = (IJavaValue) variable.getValue();
        if (!(value instanceof IJavaObject))
            return new Long(-2);
        else {
            return ((IJavaObject)value).getUniqueId();
        }
    }

    /**
     * Returns an existing or new node linked with the id of object re innerNode = new
     * KlighdDebugTransformation().transform(variable, this.getUsedContext(),
     * transformationInfo);presented by variable
     * 
     * @param variable
     *            variable representing the object, which id is linked with an node
     * @return existing or new node
     * @throws DebugException
     */
    public KNode createNodeById(IVariable variable) throws DebugException {
        Long id = getId(variable);
        KNode node = kNodeExtensions.getNode(variable);
        if (id != -2)
            kNodeMap.put(id, node);
        return node;
    }
    
    private KNode createDummyNode(IVariable variable) throws DebugException {
        KNode variableNode = getNode(variable);
        // create dummyNode
        KNode dummyNode = kNodeExtensions.createNode();   
        kNodeExtensions.setNodeSize(dummyNode, 20, 20);
        KEllipse ellipse = renderingFactory.createKEllipse();
        kRenderingExtensions.setForegroundColor(ellipse,255,0,0);
        dummyNode.getData().add(ellipse);
        
        // create edge dummyNode -> variableNode
        KEdge edge = kEdgeExtensions.createEdge();
        edge.setSource(dummyNode); 
        edge.setTarget(variableNode);
        
        KPolyline polyline = renderingFactory.createKPolyline(); 
        kRenderingExtensions.setLineWidth(polyline, 2);
        kRenderingExtensions.setForegroundColor(polyline,255,0,0);
        kPolylineExtensions.addArrowDecorator(polyline);
        
        edge.getData().add(polyline);

        dummyNodeMap.put(variable, dummyNode);
        return dummyNode;
    }

    public KNode addNodeById(KNode node, IVariable variable) throws DebugException {       
        if (nodeExists(variable)) {
            createDummyNode(variable).setParent(node);
            return null;
        } else {
            KNode resultNode = createNodeById(variable);
            resultNode.setParent(node);
            return resultNode;
        }
    }
}
