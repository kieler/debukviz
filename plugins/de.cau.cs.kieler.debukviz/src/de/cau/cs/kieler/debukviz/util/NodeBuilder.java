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
package de.cau.cs.kieler.debukviz.util;

import java.util.List;

import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.IVariable;

import com.google.common.collect.Lists;
import com.google.inject.Guice;
import com.google.inject.Injector;

import de.cau.cs.kieler.core.kgraph.KNode;
import de.cau.cs.kieler.core.krendering.KGridPlacement;
import de.cau.cs.kieler.core.krendering.KRenderingFactory;
import de.cau.cs.kieler.core.krendering.KRoundedRectangle;
import de.cau.cs.kieler.core.krendering.KText;
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions;
import de.cau.cs.kieler.core.krendering.extensions.KContainerRenderingExtensions;
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions;
import de.cau.cs.kieler.core.util.Pair;
import de.cau.cs.kieler.debukviz.VariableTransformationContext;
import de.cau.cs.kieler.kiml.klayoutdata.KShapeLayout;
import de.cau.cs.kieler.kiml.options.LayoutOptions;
import de.cau.cs.kieler.kiml.options.SizeConstraint;
import de.cau.cs.kieler.kiml.util.KimlUtil;
import de.cau.cs.kieler.klighd.KlighdConstants;

/**
 * A builder for creating nodes for visualizing variables. Transformations should use these to end up
 * with consistent looking diagrams. Start by obtaining a node builder through one of the static creation
 * methods. Then, chain configuration method calls to configure the node to be built. Finally, call
 * {@link #build()} to obtain the configured node.
 * 
 * <p><em>Note:</em> The methods in this class will throw a {@link NullPointerException} if at least one
 * argument is {@code null}. Also, the node builder does not check if the configuration is valid while
 * the configuration methods are called. Instead, a validity check is done once the node is built.</p>
 */
public final class NodeBuilder {
    
    /** Space to be left between the border of a node and its content. */
    public static int NODE_INSETS = 5;
    
    /** The variable we're building a node for, if any. */
    private IVariable variable = null;
    /** The graph the node will be added to. */
    private KNode graph = null;
    /** The transformation context the node will be registered with. */
    private VariableTransformationContext context = null;
    /** The name of the node. */
    private String name = null;
    /** The type name of the node. */
    private String type = null;
    /** A value that should be displayed for the object. */
    private String value = null;
    /** A list of properties with values that might be displayed in the node. */
    private List<Pair<String, String>> properties = Lists.newLinkedList();
    /** Whether the node will be a proxy or not. */
    private boolean proxy = false;
    /** Whether the node will contain children or not. */
    private boolean hierarchical = false;
    
    // KRendering extensions used to build the node rendering
    private KRenderingFactory renderingFactory = null;
    private KColorExtensions colExt = null;
    private KContainerRenderingExtensions contExt = null;
    private KRenderingExtensions rendExt = null;
    
    
    ///////////////////////////////////////////////////////
    // Constructor / Create Methods
    
    /**
     * Private constructor. Obtain new instances through the static creation methods.
     */
    private NodeBuilder() {
        
    }
    
    /**
     * Creates a new node builder for a node that is not associated with a variable.
     * 
     * @param graph the graph the created node will be added to.
     * @param context the transformation context that will be updated as the node is created.
     * @return the node builder.
     * @throws NullPointerException if one of the parameters is {@code null}.
     */
    public static NodeBuilder forPlainNode(final KNode graph,
            final VariableTransformationContext context) {
        
        if (graph == null) {
            throw new NullPointerException("graph cannot be null");
        }
        
        if (context == null) {
            throw new NullPointerException("context cannot be null");
        }
        
        NodeBuilder builder = new NodeBuilder();
        builder.graph = graph;
        builder.context = context;
        
        return builder;
    }
    
    /**
     * Creates a new node builder for a node that is associated with a variable. Once the node is
     * created, the node builder will establish the association in the transformation context.
     * 
     * @param variable the variable the node will be created for.
     * @param graph the graph the created node will be added to.
     * @param context the transformation context that will be updated as the node is created.
     * @return the node builder.
     * @throws NullPointerException if one of the parameters is {@code null}.
     */
    public static NodeBuilder forVariable(final IVariable variable, final KNode graph,
            final VariableTransformationContext context) {
        
        if (variable == null) {
            throw new NullPointerException("variable cannot be null");
        }
        
        NodeBuilder builder = forPlainNode(graph, context);
        builder.variable = variable;
        
        return builder;
    }

    
    ///////////////////////////////////////////////////////
    // Configuration
    
    /**
     * Sets the name of the node. Proxy nodes cannot have a name.
     * 
     * @param v the value to be displayed.
     * @return this node builder.
     */
    public NodeBuilder name(final String n) {
        if (n == null) {
            throw new NullPointerException("n cannot be null");
        }
        
        name = n;
        
        return this;
    }
    
    /**
     * Sets the type name of the node. Proxy nodes cannot have a type name.
     * 
     * @param t the type name to be displayed.
     * @return this node builder.
     */
    public NodeBuilder type(final String t) {
        if (t == null) {
            throw new NullPointerException("t cannot be null");
        }
        
        type = t;
        
        return this;
    }
    
    /**
     * Adds a value to be displayed in the node. This is mainly interesting for nodes that represent
     * objects with a single value instead of multiple interesting values. Proxy nodes cannot have a
     * value.
     * 
     * @param v the value to be displayed.
     * @return this node builder.
     */
    public NodeBuilder value(final String v) {
        if (v == null) {
            throw new NullPointerException("v cannot be null");
        }
        
        value = v;
        
        return this;
    }
    
    /**
     * Adds a key-value property to be displayed in the node. Proxy nodes cannot have properties.
     * 
     * @param key the property's key.
     * @param value the property's value.
     * @return this node builder.
     */
    public NodeBuilder addProperty(final String key, final String value) {
        if (key == null || value == null) {
            throw new NullPointerException("key and value cannot be null");
        }
        
        properties.add(Pair.of(key, value));
        
        return this;
    }
    
    /**
     * Makes the node a proxy node. Proxy nodes are nodes that have a special rendering and that don't
     * have any text. They mainly just serve as placeholders for other, proper nodes. A proxy cannot
     * have any kind of text associated with it, and it cannot be hierarchical. An attempt to circumvent
     * these restrictions will result in arbitrarily catastrophic exceptions when building the node.
     * 
     * @return this node builder.
     */
    public NodeBuilder proxy() {
        proxy = true;
        return this;
    }
    
    /**
     * Makes sure the node will be hierarchical. This will mainly add a compartment in the node that
     * children can be added to to be displayed properly. A proxy cannot be made hierarchical. An
     * attempt to do that anyway will result in an exception when building the node.
     * 
     * @return this node builder.
     */
    public NodeBuilder hierarchical() {
        hierarchical = true;
        return this;
    }

    
    ///////////////////////////////////////////////////////
    // Building
    
    /**
     * Checks the builder's configuration, builds a corresponding node, and updates the transformation
     * context accordingly.
     * 
     * @return the node.
     * @throws IllegalStateException if the configuration is invalid.
     * @throws DebugException if anything goes wrong when associating the variable with its node.
     */
    public KNode build() throws DebugException {
        checkConfiguration();
        
        // Node building differs depending on whether we're building a proxy node or a regular node
        KNode node = proxy ? buildProxyNode() : buildRegularNode();
        graph.getChildren().add(node);
        
        // Update the transformation context
        context.increaseNodeCount();
        if (variable != null) {
            context.associateWith(variable, node);
        }
        
        return node;
    }
    
    /**
     * Builds and returns a proxy node. Assumes that the builder's configuration is valid.
     * 
     * @return the proxy node.
     */
    private KNode buildProxyNode() {
        // TODO Change gradient colors
        // TODO Change size such that proxy nodes are big enough next to regular nodes
        
        KNode node = KimlUtil.createInitializedNode();
        
        // Prepare rendering extensions
        injectExtensions();
        
        // Build the rendering
        KRoundedRectangle rndRect = rendExt.addRoundedRectangle(node, 10, 10);
        rendExt.setForeground(rndRect, colExt.getColor("gray"));
        rendExt.setBackgroundGradient(
                rndRect, colExt.getColor("#FFFFFF"), colExt.getColor("#F0F0F0"), 90);
        rendExt.setShadow(
                rndRect, colExt.getColor("black"), 4, 4);
        
        // Set layout properties
        KShapeLayout shapeLayout = node.getData(KShapeLayout.class);
        shapeLayout.setWidth(20);
        shapeLayout.setHeight(20);
        shapeLayout.setProperty(LayoutOptions.SIZE_CONSTRAINT, SizeConstraint.fixed());
        
        return node;
    }
    
    /**
     * Builds and returns a regular, non-proxy node. Assumes that the builder's configuration is valid.
     * 
     * @return the regular node.
     */
    private KNode buildRegularNode() {
        KNode node = KimlUtil.createInitializedNode();

        // Prepare rendering extensions
        injectExtensions();

        // Build the rendering
        KRoundedRectangle rndRect = rendExt.addRoundedRectangle(node, 5, 5);
        rendExt.setForeground(rndRect, colExt.getColor("gray"));
        rendExt.setBackgroundGradient(
                rndRect, colExt.getColor("#FFFFFF"), colExt.getColor("#F0F0F0"), 90);
        rendExt.setShadow(
                rndRect, colExt.getColor("black"), 4, 4);
        
        // Setup grid placement
        KGridPlacement rndRectPlacement = contExt.setGridPlacement(rndRect, 1);
        rendExt.from(rndRectPlacement, rendExt.LEFT, NODE_INSETS, 0, rendExt.TOP, NODE_INSETS, 0);
        rendExt.to(rndRectPlacement, rendExt.RIGHT, NODE_INSETS, 0, rendExt.BOTTOM, NODE_INSETS, 0);
        
        // Name and type
        String nameAndType = null;
        if (name != null && type != null) {
            nameAndType = name + " : " + type;
        } else if (name != null) {
            nameAndType = name;
        } else if (type != null) {
            nameAndType = type;
        }
        
        if (nameAndType != null) {
            KText nameAndTypeText = renderingFactory.createKText();
            rndRect.getChildren().add(nameAndTypeText);
            
            nameAndTypeText.setText(nameAndType);
            rendExt.setFontSize(nameAndTypeText, KlighdConstants.DEFAULT_FONT_SIZE - 2);
            rendExt.setForeground(nameAndTypeText, colExt.getColor("#627090"));
        }
        
        // Value
        if (value != null) {
            KText valueText = renderingFactory.createKText();
            rndRect.getChildren().add(valueText);
            
            valueText.setText(value);
            rendExt.setForeground(valueText, colExt.getColor("#323232"));
        }
        
        // Properties
        if (!properties.isEmpty()) {
            
        }
        
        // Hierachy
        if (hierarchical) {
            
        }
        
        return node;
    }

    
    ///////////////////////////////////////////////////////
    // Utility Methods
    
    /**
     * Checks if the configuration is valid.
     * 
     * @throws IllegalStateException if the configuration is invalid.
     */
    private void checkConfiguration() {
        // The configuration can only be invalid if the node is a proxy node
        if (proxy) {
            if (name != null
                    || type != null
                    || value != null
                    || properties.isEmpty() == false
                    || hierarchical) {
                
                throw new IllegalStateException("proxy nodes cannot have names, type names, values, "
                        + "properties, or be hierarhical");
            }
        }
    }
    
    /**
     * Instantiates all KRendering extensions we need when adding a rendering to nodes.
     */
    private void injectExtensions() {
        renderingFactory = KRenderingFactory.eINSTANCE;
        
        Injector injector = Guice.createInjector();
        colExt = injector.getInstance(KColorExtensions.class);
        contExt = injector.getInstance(KContainerRenderingExtensions.class);
        rendExt = injector.getInstance(KRenderingExtensions.class);
    }
    
}
