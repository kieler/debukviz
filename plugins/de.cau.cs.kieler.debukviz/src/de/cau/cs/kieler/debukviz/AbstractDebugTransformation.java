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

import java.util.HashMap;

import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.IVariable;
import org.eclipse.jdt.debug.core.IJavaObject;
import org.eclipse.jdt.debug.core.IJavaValue;

import com.google.inject.Inject;

import de.cau.cs.kieler.core.kgraph.KEdge;
import de.cau.cs.kieler.core.kgraph.KNode;
import de.cau.cs.kieler.core.krendering.KEllipse;
import de.cau.cs.kieler.core.krendering.KPolyline;
import de.cau.cs.kieler.core.krendering.KRectangle;
import de.cau.cs.kieler.core.krendering.KRenderingFactory;
import de.cau.cs.kieler.core.krendering.KText;
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions;
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions;
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions;
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions;
import de.cau.cs.kieler.debukviz.dialog.DebuKVizDialog;
import de.cau.cs.kieler.debukviz.transformations.KlighdDebugTransformation;
import de.cau.cs.kieler.debukviz.transformations.ReinitializingTransformationProxy;

/**
 * An abstract base class for transformations between {@link IVariable} and {@link KNode}.
 * 
 * <p>At this point Xtend2 is used for all transformations extending this class. So every
 * transformation should make use of {@link ReinitializingTransformationProxy} to leverage
 * <i>create extensions</i> or <i>dependency injection</i> with Google Guice.</p>
 */
public abstract class AbstractDebugTransformation implements IDebugTransformation {

    @Inject
    private KEdgeExtensions kEdgeExtensions;
    @Inject
    private KRenderingExtensions kRenderingExtensions;
    @Inject
    private KPolylineExtensions kPolylineExtensions;
    @Inject
    private KNodeExtensions kNodeExtensions;

    /** Factory used to create several rendering objects */
    protected static final KRenderingFactory renderingFactory = KRenderingFactory.eINSTANCE;

    /** Map of object id to the created KNode */
    private static final HashMap<Long, KNode> kNodeMap = new HashMap<Long, KNode>();

    /** Map of variable representing a runtime variable to a dummy node */
    private static final HashMap<IVariable, KNode> dummyNodeMap = new HashMap<IVariable, KNode>();

    /** actual depth (recursive calls of nextTransformation) */
    private static Integer depth = 0;

    /** maximal allowed depth */
    private Integer maxDepth = DebuKVizPlugin.getDefault().getPreferenceStore()
            .getInt(DebuKVizPlugin.HIERARCHY_DEPTH);
    
    /** actual number of nodes */
    private static Integer nodeCount = 0;

    /** maximal number of nodes */
    private Integer maxNodeCount = DebuKVizPlugin.getDefault().getPreferenceStore()
            .getInt(DebuKVizPlugin.MAX_NODE_COUNT);
    
    private int primitiveId = -2;

    /**
     * Clears kNodeMap
     */
    public static void resetKNodeMap() {
        kNodeMap.clear();
    }

    /**
     * Clears dummyNodeMap
     */
    public static void resetDummyNodeMap() {
        dummyNodeMap.clear();
    }
    
    /**
     * Resets nodeCount
     */
    public static void resetNodeCount() {
        nodeCount = 0;
    }
    
    public void incNodeCount() {
        nodeCount++;
    }
    
    public int getActualNodeCount() {
        return nodeCount;
    }
    
    public int getMaxNodeCount() {
        return maxNodeCount;
    }

    /**
     * Performs a transformation for a given variable. If a node already exists for the given
     * variable a dummy node will be created. If the maximal depth isn't reached a normal
     * transformation will be done. Otherwise a special KNode with simple informations will be
     * created.
     * 
     * @param variable
     * @return result of the transformation, a dummyNode or a special node
     * @throws DebugException
     */
    public KNode nextTransformation(KNode rootNode, IVariable variable) throws DebugException {
        return nextTransformation(rootNode, variable, null);
    }

    /**
     * Performs a transformation for a given variable with further informations. If a node already
     * exists for the given variable a dummy node will be created. If the maximal depth isn't
     * reached a normal transformation will be done. Otherwise a special KNode with simple
     * informations will be created.
     * 
     * @param variable
     *            variable to be transformed
     * @param transformationInfo
     *            further informations needed by the transformation
     * @return result of the transformation, a dummyNode or a special node
     * @throws DebugException
     */
    public KNode nextTransformation(KNode rootNode, IVariable variable, Object transformationInfo)
            throws DebugException {
        KNode innerNode;  
        if (nodeCount > maxNodeCount) {
            DebuKVizDialog.open();
            return null;
        } else {
            // If node already exists create a dummy node
            if (getId(variable) != primitiveId && nodeExists(variable)) {
                nodeCount++;
                innerNode = createDummyNode(variable);
            } else {
                if (depth+1 <= maxDepth) {
                    // Perform transformation if maximal recursion depth wasn't
                    // exceeded
                    depth++;
                    KlighdDebugTransformation transformation = new KlighdDebugTransformation();
                    innerNode = transformation.transformation(variable, transformationInfo);
                    depth--;
                    
                    nodeCount += transformation.getNodeCount(variable);
                    
                    while (innerNode.getChildren().size() == 1) {
                        innerNode = innerNode.getChildren().get(0);
                    }
                    
                    if (!kNodeMap.containsKey(getId(variable))) {
                        kNodeMap.put(getId(variable), innerNode);
                    }
    
                    KText type = renderingFactory.createKText();
                    type.setText(variable.getReferenceTypeName());
                } else {
                    // Create a special node
                    innerNode = createNodeById(variable);
                    kNodeExtensions.setNodeSize(innerNode, 80, 80);
                    KRectangle rec = renderingFactory.createKRectangle();
                    innerNode.getData().add(rec);
                    rec.setChildPlacement(renderingFactory.createKGridPlacement());
    
                    KText type = renderingFactory.createKText();
                    type.setText("<<"+getType(variable)+">>");
                    kRenderingExtensions.setForegroundColor(type,120,0,0);
                    rec.getChildren().add(type);
                    
                    KText name = renderingFactory.createKText();
                    name.setText(variable.getName());
                    rec.getChildren().add(name);
                    
                    nodeCount++;
                }   
            }
        }
        innerNode.setParent(rootNode);
        return innerNode;
    }

    /**
     * Iterate over field names given by fieldPath and returns the value of the last field of
     * fieldPath stored in variable
     * 
     * @param variable
     *            variable, in which the field with the first file name as name is stored
     * @param fieldPath
     *            dot-separated string of field names
     * @return value of last field of fieldPath or "null" if field does'nt exists
     * @throws DebugException
     */
    public String getValue(IVariable variable, String... fields) throws DebugException {
        IVariable var = getVariable(variable, fields);
        if (var != null)
            return var.getValue().getValueString();
        return "null";
    }

    /**
     * Iterate over field names given by fieldPath and returns an array of variable stored in the
     * last field of fieldPath
     * 
     * @param variable
     *            variable, in which the field with the first file name as name is stored
     * @param fieldPath
     *            dot-separated string of field names
     * @return array of variable stored in last field of fieldPath or "null" if field does'nt exists
     * @throws DebugException
     */
    public IVariable[] getVariables(IVariable variable, String... fields) throws DebugException {
        IVariable var = getVariable(variable, fields);
        if (var != null)
            return var.getValue().getVariables();
        else
            return null;
    }

    /**
     * Iterate over a list of field names given by fields and returns a variable representing the field in
     * the variable with the last field name as name, or <code>null</code> if there is no field with
     * the given name, or the name is ambiguous.
     * 
     * 
     * @param variable
     *            variable, in which the field with the first file name as name is stored
     * @param fieldPath
     *            dot-separated string of field names
     * @param superField
     *            whether or not to get the field in the superclass of this objects.
     * @return the variable representing the field with the last field name as name, or
     *         <code>null</code>
     * @throws DebugException
     */
    public IVariable getVariable(IVariable variable, boolean superField, String... fields)
            throws DebugException {
        boolean superF = false;
        // Iterate over list of field names
        for (int i = 0; i < fields.length; i++) {   
            if (i == fields.length - 1)
                superF = superField;
            IJavaObject javaObject = (IJavaObject) variable.getValue();
            variable = (IVariable) javaObject.getField(fields[i], superF);
        }
        return variable;
    }

    /**
     * Iterate over field names given by fieldPath and returns a variable representing the field in
     * the variable with the last field name as name, or <code>null</code> if there is no field with
     * the given name, or the name is ambiguous.
     * 
     * @param variable
     *            variable, in which the field with the first file name as name is stored
     * @param fieldPath
     *            dot-separated string of field names
     * @return the variable representing the field with the last field name as name, or
     *         <code>null</code>
     * @throws DebugException
     */
    public IVariable getVariable(IVariable variable, String... fields) throws DebugException {
        return getVariable(variable, false, fields);
    }

    /**
     * Returns the type of the value of the given variable in a simple form
     * 
     * @param variable
     *            type of the value of this variable will be returned
     * @return type of the value of variable
     * @throws DebugException
     */
    public String getType(IVariable variable) throws DebugException {
        String type = variable.getValue().getReferenceTypeName();
        return type.substring(type.lastIndexOf('.') + 1);
    }

    /**
     * Returns an edge between the node associated with source and the node associated with target
     * If a dummy node for source/target exists this node is the associated one else the associated
     * node is contained in kNodeMap or a node got from KNodeExtensions
     * 
     * @param source
     * @param target
     * @return Edge between node associated with source and node associated with target
     * @throws DebugException
     */
    public KEdge createEdgeById(IVariable source, IVariable target) throws DebugException {
        // create an edge
        KEdge edge = kEdgeExtensions.createEdge();

        // Get eventually existing dummy nodes
        KNode sourceNode = dummyNodeMap.get(source);
        KNode targetNode = dummyNodeMap.get(target);

        if (sourceNode == null)
            sourceNode = getNode(source);
        if (targetNode == null)
            targetNode = getNode(target);

        // set source and target
        if (sourceNode != null && targetNode != null) {
            edge.setSource(sourceNode);
            edge.setTarget(targetNode);
        }
        return edge;
    }

    /**
     * Checks whether the value of the given variable represents a null value
     * 
     * @param variable
     *            variable which value is checked
     * @return whether the value of the given variable represents a null value
     */
    public boolean valueIsNotNull(IVariable variable) {
        try {
            return !variable.getValue().getValueString().equals("null");
        } catch (DebugException e) {
            return false;
        }
    }

    /**
     * Returns a node associated with the object id of the object representing by the given variable
     * or associated with the given variable
     * 
     * @param variable
     *            variable which associated node is returned
     * @return node associated with the object id of the object representing by the given variable
     *         or associated with the given variable
     * @throws DebugException
     */
    private KNode getNode(IVariable variable) throws DebugException {
        KNode node = kNodeMap.get(getId(variable));
        if (node == null) {
            node = kNodeExtensions.getNode(variable);
            if (node.getParent() == null)
                node = null;
        }
        return node;
    }

    /**
     * Checks whether a node associated with the object id of the object represented by the given
     * variable exists
     * 
     * @param variable
     *            variable checked for an associated node
     * @return whether a node associated with the object id of the object representing by the given
     *         variable or a node associated with the given variable exists
     * @throws DebugException
     */
    public boolean nodeExists(IVariable variable) throws DebugException {
        return kNodeMap.containsKey(getId(variable)) || dummyNodeMap.containsKey(variable);
    }

    /**
     * Returns the unique id of the runtime variable representing by variable A runtime variable can
     * by an object, a primitive value or null
     * 
     * @param variable
     *            variable which represents an runtime variable
     * @return unique id or -1 if object is null or if variable represents a primitive value
     * @throws DebugException
     */
    private Long getId(IVariable variable) throws DebugException {
        IJavaValue value = (IJavaValue) variable.getValue();
        if (!(value instanceof IJavaObject))
            return new Long(primitiveId);
        else {
            return ((IJavaObject) value).getUniqueId();
        }
    }

    /**
     * Creates a node associated with the given variable and, if the given variable represents an
     * object, with the id of the object
     * 
     * @param variable
     *            variable representing a runtime variable
     * @return created node
     * @throws DebugException
     */
    private KNode createNodeById(IVariable variable) throws DebugException {
        Long id = getId(variable);
        KNode node = kNodeExtensions.getNode(variable);
        if (id != primitiveId)
            kNodeMap.put(id, node);
        return node;
    }

    /**
     * This Method is called if the id of the object represented by the given variable is already
     * associated with an node. It creates a dummy node associated with the given variable and add
     * an edge between the created node and the already associated node.
     * 
     * @param variable
     *            variable representing a runtime variable
     * @return created dummy node
     * @throws DebugException
     */
    private KNode createDummyNode(IVariable variable) throws DebugException {
        KNode variableNode = getNode(variable);
        // create dummyNode
        KNode dummyNode = kNodeExtensions.createNode();
        kNodeExtensions.setNodeSize(dummyNode, 20, 20);
        KEllipse ellipse = renderingFactory.createKEllipse();
        kRenderingExtensions.setForegroundColor(ellipse, 255, 0, 0);
        dummyNode.getData().add(ellipse);

        // create edge dummyNode -> variableNode
        KEdge edge = kEdgeExtensions.createEdge();
        edge.setSource(dummyNode);
        edge.setTarget(variableNode);

        KPolyline polyline = renderingFactory.createKPolyline();
        kRenderingExtensions.setLineWidth(polyline, 2);
        kRenderingExtensions.setForegroundColor(polyline, 255, 0, 0);
        kPolylineExtensions.addHeadArrowDecorator(polyline);

        edge.getData().add(polyline);

        dummyNodeMap.put(variable, dummyNode);
        return dummyNode;
    }

    /**
     * Creates a node associated with the id of the runtime variable represented by the given
     * variable or the given variable. If such a node already exists, a dummy node will be created
     * 
     * @param node
     *            node to which the created node will be added
     * @param variable
     *            representing a runtime variable
     * @return created node or null if the created node is a dummy node
     * @throws DebugException
     */
    public KNode addNodeById(KNode node, IVariable variable) throws DebugException {
        if (getId(variable) != primitiveId && nodeExists(variable)) {
            createDummyNode(variable).setParent(node);
            return null;
        } else {
            KNode resultNode = createNodeById(variable);
            resultNode.setParent(node);
            return resultNode;
        }
    }

    /**
     * Checks whether a transformation for the given variable exists
     * 
     * @param variable
     * @return whether the transformation exists
     */
    public boolean transformationExists(IVariable variable) {
        return DebuKVizTransformationService.INSTANCE.getTransformation(variable) != null;
    }
}
