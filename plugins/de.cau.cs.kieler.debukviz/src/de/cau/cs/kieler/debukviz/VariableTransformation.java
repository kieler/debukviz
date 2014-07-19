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

import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.IValue;
import org.eclipse.debug.core.model.IVariable;

import de.cau.cs.kieler.core.kgraph.KNode;

/**
 * Instances of this class can transform an {@link IVariable} into a visual representation. For
 * DebuKViz to be able to use the transformation, it must be registered with the
 * {@code de.cau.cs.kieler.debukviz.transformations} extension point.
 * 
 * <p>Implementations of this class need to implement its main method,
 * {@link #transform(IVariable, KNode, VariableTransformationContext)}. It is the responsibility of
 * implementations to update the transformation context as they create new nodes and to pass the
 * context along to other transformation that may be called.</p>
 * 
 * <p>Transformations are encouraged to use {@link NodeBuilder} and {@link EdgeBuilder} to create nodes
 * and edges. This will ensure a consistent look and the builders automatically take care of updating
 * the transformation context.</p>
 */
public abstract class VariableTransformation {
    
    /**
     * Transforms the given variable into its visual representation. The created nodes are added to the
     * given parent graph and one of them is mapped to the variable through the given transformation
     * context (that node is used to connect to when other variables reference the variable). If other
     * variables are reference by the current variable, they can be visualized by calling
     * {@link #invokeFor(IVariable, KNode, VariableTransformationContext)} with the same transformation
     * context and, usually, with the same parent graph.
     * 
     * @param variable the variable to visualize.
     * @param graph the graph transformed nodes should be added to.
     * @param context the transformation context that holds the state over multiple transformation
     *                invocations of the same DebuKViz synthesis run.
     * @throws DebugException if anything goes wrong when accessing the Eclipse debug system.
     */
    public abstract void transform(final IVariable variable, final KNode graph,
            final VariableTransformationContext context)
            throws DebugException;

    /**
     * Invokes a transformation that transforms the given variable into its visual representation. Does
     * nothing if the variable already has a visual representation associated with it in the context or
     * if the recursion or node count limits have already been reached. Thus, after calling this method,
     * the variable to be transformed might not actually have been associated with a visual
     * representation in the transformation context.
     * 
     * <p>To find the node associated with the given variable (if any) after calling this method, use
     * {@link VariableTransformationContext#findAssociation(IVariable)}.</p>
     * 
     * @param variable the variable to transform.
     * @param graph the parent graph to add the transformed representation to.
     * @param context the transformation context to pass to the transformation.
     * @throws DebugException if anything goes wrong when accessing the Eclipse debug system.
     */
    public static final void invokeFor(final IVariable variable, final KNode graph,
            final VariableTransformationContext context) throws DebugException {
        
        // Check if the maximum node count or maximum transformation depth are already reached
        int maxDepth = DebuKVizPlugin.getDefault().getPreferenceStore().getInt(
                DebuKVizPlugin.HIERARCHY_DEPTH);
        if (context.getTransformationDepth() >= maxDepth) {
            // TODO Perhaps create a certain kind of dummy node here?
            //      That would make it clear that the transformation stopped there
            return;
        }
        
        int maxNodeCount = DebuKVizPlugin.getDefault().getPreferenceStore().getInt(
                DebuKVizPlugin.MAX_NODE_COUNT);
        if (context.getNodeCount() >= maxNodeCount) {
            // TODO Originally, the synthesis opened an error message when this condition was triggered
            return;
        }
        
        // Check if the variable was already transformed
        if (context.findAssociation(variable) != null) {
            return;
        }
        
        // Fetch a transformation that can handle this variable's type
        VariableTransformation transformation =
                DebuKVizTransformationService.INSTANCE.transformationFor(variable);
        
        if (transformation != null) {
            // Invoke transformation
            context.increaseTransformationDepth();
            transformation.transform(variable, graph, context);
            context.decreaseTransformationDepth();
        }
    }
    
    
    //--------------------- UTILITY METHODS FOR USE IN SUBCLASSES ---------------------
    
    /**
     * Determine whether the given value contains a variable with the given name.
     * 
     * @param value a value
     * @param name a variable name
     * @return true if the value contains a variable with the given name
     * @throws DebugException if accessing the debug model fails
     */
    protected final boolean hasNamedVariable(IValue value, String name) throws DebugException {
        for (IVariable v : value.getVariables()) {
            if (v.getName().equals(name)) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Retrieve a variable with given name referenced from the given value.
     * 
     * @param value a value
     * @param name the name of a variable referenced by {@code value}
     * @return the first variable matching the given name
     * @throws DebugException if accessing the debug model fails
     */
    protected final IVariable getNamedVariable(IValue value, String name) throws DebugException {
        for (IVariable v : value.getVariables()) {
            if (v.getName().equals(name)) {
                return v;
            }
        }
        throw new IllegalArgumentException("The given variable name was not found: " + name);
    }
    
    /**
     * Return the value of a variable as a string.
     * 
     * @param variable a variable
     * @return the value of the given variable interpreted as string
     * @throws DebugException if accessing the debug model fails
     */
    protected final String getStringValue(IVariable variable) throws DebugException {
        return variable.getValue().getValueString();
    }
    
    /**
     * Return the value of a variable as a Boolean.
     * 
     * @param variable a variable
     * @return the value of the given variable interpreted as Boolean
     * @throws DebugException if accessing the debug model fails
     */
    protected final boolean getBooleanValue(IVariable variable) throws DebugException {
        return Boolean.parseBoolean(variable.getValue().getValueString());
    }
    
    /**
     * Return the value of a variable as an int number.
     * 
     * @param variable a variable
     * @return the value of the given variable interpreted as int
     * @throws DebugException if accessing the debug model fails
     */
    protected final int getIntValue(IVariable variable) throws DebugException {
        try {
            return Integer.parseInt(variable.getValue().getValueString());
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException(exception);
        }
    }
    
    /**
     * Return the value of a variable as a byte number.
     * 
     * @param variable a variable
     * @return the value of the given variable interpreted as byte
     * @throws DebugException if accessing the debug model fails
     */
    protected final byte getByteValue(IVariable variable) throws DebugException {
        try {
            return Byte.parseByte(variable.getValue().getValueString());
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException(exception);
        }
    }
    
    /**
     * Return the value of a variable as a long number.
     * 
     * @param variable a variable
     * @return the value of the given variable interpreted as long
     * @throws DebugException if accessing the debug model fails
     */
    protected final long getLongValue(IVariable variable) throws DebugException {
        try {
            return Long.parseLong(variable.getValue().getValueString());
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException(exception);
        }
    }
    
    /**
     * Return the value of a variable as a float number.
     * 
     * @param variable a variable
     * @return the value of the given variable interpreted as float
     * @throws DebugException if accessing the debug model fails
     */
    protected final float getFloatValue(IVariable variable) throws DebugException {
        try {
            return Float.parseFloat(variable.getValue().getValueString());
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException(exception);
        }
    }
    
    /**
     * Return the value of a variable as a double number.
     * 
     * @param variable a variable
     * @return the value of the given variable interpreted as double
     * @throws DebugException if accessing the debug model fails
     */
    protected final double getDoubleValue(IVariable variable) throws DebugException {
        try {
            return Double.parseDouble(variable.getValue().getValueString());
        } catch (NumberFormatException exception) {
            throw new IllegalArgumentException(exception);
        }
    }

    /**
     * Determine whether the value of the given variable is null.
     * 
     * @param variable a variable
     * @return true if the value of the variable is null
     * @throws DebugException if accessing the debug model fails
     */
    protected final boolean isNull(IVariable variable) throws DebugException {
        return "null".equals(variable.getValue().getValueString());
    }

    /**
     * Determine whether the value of the given variable is non-null.
     * 
     * @param variable a variable
     * @return true if the value of the variable is not null
     * @throws DebugException if accessing the debug model fails
     */
    protected final boolean isNonNull(IVariable variable) throws DebugException {
        return !isNull(variable);
    }
    
}
