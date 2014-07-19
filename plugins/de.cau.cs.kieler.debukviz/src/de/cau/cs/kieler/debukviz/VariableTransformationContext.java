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

import java.util.Map;

import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.IVariable;
import org.eclipse.jdt.debug.core.IJavaObject;
import org.eclipse.jdt.debug.core.IJavaValue;

import com.google.common.collect.Maps;

import de.cau.cs.kieler.core.kgraph.KNode;
import de.cau.cs.kieler.core.kgraph.KPort;
import de.cau.cs.kieler.debukviz.util.EdgeBuilder;

/**
 * Stores information relevant to a given DebuKViz synthesis run. Since each run can be composed of
 * an arbitrary number of transformations, the context is required to store information such as which
 * variable maps to which node in the resulting graph.
 */
public final class VariableTransformationContext {
    
    /** Maps variables to the nodes used to visualize them. */
    private Map<Long, KNode> transformationMap = Maps.newHashMap();
    
    /** Maps nodes to the default input port used to reference them. */
    private Map<KNode, KPort> defaultInputMap = Maps.newHashMap();
    
    /**
     * The depth of recursive transformation calls. Only accessed by the {@link VariableTransformation}.
     */
    private int transformationDepth = 0;
    
    /** The number of nodes created so far. Updated by every transformation. */
    private int nodeCount = 0;
    
    
    ///////////////////////////////////////////////////////
    // Transformation Mapping
    
    /**
     * Associates a variable with its visual representation.
     * 
     * @param variable the variable.
     * @param node the node that is the main representative of the variable.
     * @throws DebugException if anything goes wrong in the debugging framework.
     */
    public void associateWith(final IVariable variable, final KNode node) throws DebugException {
        // TODO Map to ID instead?
        transformationMap.put(toId(variable), node);
    }
    
    /**
     * Returns the node that is the visual representation of the given variable, if any.
     * 
     * @param variable the variable whose visual representation to find.
     * @return the node that represents the variable, or {@code null} if there is none.
     * @throws DebugException if anything goes wrong in the debugging framework.
     */
    public KNode findAssociation(final IVariable variable) throws DebugException {
        return transformationMap.get(toId(variable));
    }
    
    /**
     * Set the given port as the default input port of the node. Whenever the {@link EdgeBuilder}
     * is used to create a reference to the given node and no particular target port is specified
     * for that reference, the default input port is used.
     * 
     * @param node a node
     * @param port the port to set as default input port
     */
    public void setDefaultInputPort(final KNode node, final KPort port) {
        defaultInputMap.put(node, port);
    }
    
    /**
     * Find the default input port associated with the given node. If no default input port
     * has been set, {@code null} is returned.
     * 
     * @param node a node
     * @return the associated default input port, or {@code null}
     */
    public KPort findDefaultInputPort(final KNode node) {
        return defaultInputMap.get(node);
    }

    /**
     * Returns the unique id of the runtime variable representing by variable A runtime variable can
     * by an object, a primitive value or null
     * 
     * @param variable the variable whose id to fetch.
     * @return unique id or {@code -1} if the variable is {@code null} or if it is a primitive value.
     * @throws DebugException if anything goes wrong in the debugging framework.
     */
    private long toId(final IVariable variable) throws DebugException {
        IJavaValue value = (IJavaValue) variable.getValue();
        if (!(value instanceof IJavaObject))
            return -1;
        else {
            return ((IJavaObject) value).getUniqueId();
        }
    }
    
    
    ///////////////////////////////////////////////////////
    // Bookkeeping
    
    /**
     * Increases the transformation depth by one. This method is package-private since it is only
     * accessed by {@link VariableTransformation}.
     */
    void increaseTransformationDepth() {
        transformationDepth++;
    }
    
    /**
     * Decreases the transformation depth by one. This method is package-private since it is only
     * accessed by {@link VariableTransformation}.
     */
    void decreaseTransformationDepth() {
        transformationDepth--;
    }
    
    /**
     * Returns the transformation depth. This method is package-private since it is only accessed by
     * {@link VariableTransformation}.
     * 
     * @return the current transformation depth.
     */
    int getTransformationDepth() {
        return transformationDepth;
    }
    
    /**
     * Increases the node count by one.
     */
    public void increaseNodeCount() {
        nodeCount++;
    }
    
    /**
     * Increases the node count by the given amount.
     * 
     * @param amount the amount to increase the node count by.
     * @throws IllegalArgumentException if {@code amount <= 0}.
     */
    public void increaseNodeCount(final int amount) {
        if (amount <= 0) {
            throw new IllegalArgumentException(
                    "node count must be increased by positive amount; was: " + amount);
        }
        
        nodeCount += amount;
    }
    
    /**
     * Returns the number of nodes generated in the current synthesis run so far as reported by the
     * different transformations.
     * 
     * @return number of generated nodes.
     */
    public int getNodeCount() {
        return nodeCount;
    }
    
}
