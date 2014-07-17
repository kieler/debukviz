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

import org.eclipse.ui.IStartup;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;

import de.cau.cs.kieler.debukviz.selection.KlighdSelectionListener;

/**
 * The activator class controls the plug-in life cycle and holds constants used throughout the plug-in.
 */
public final class DebuKVizPlugin extends AbstractUIPlugin implements IStartup {

    /** The plug-in ID. */
    public static final String PLUGIN_ID = "de.cau.cs.kieler.debukviz"; //$NON-NLS-1$

    public static final String LAYOUT = "layoutRadioButtonGroup";
    public static final String STANDARD_LAYOUT = "standardLayoutRadio";
    public static final String FLAT_LAYOUT = "flatLayoutRadio";
    public static final String HIERARCHY_LAYOUT = "hierarchyLayoutRadio";
    public static final String HIERARCHY_DEPTH = "hierarchyDepthScale";
    public static final String MAX_NODE_COUNT = "maxNodeCountScale";

    // The shared instance
    private static DebuKVizPlugin plugin;

    /**
     * Create a new instance.
     */
    public DebuKVizPlugin() {
    }

    /**
     * {@inheritDoc}
     */
    public void start(BundleContext context) throws Exception {
        super.start(context);
        plugin = this;
    }

    /**
     * {@inheritDoc}
     */
    public void stop(BundleContext context) throws Exception {
        // plugin = null;
        super.stop(context);
    }

    /**
     * Returns the shared instance
     * 
     * @return the shared instance
     */
    public static DebuKVizPlugin getDefault() {
        return plugin;
    }

    /**
     * {@inheritDoc}
     */
    public void earlyStartup() {
        KlighdSelectionListener.INSTANCE.register();
    }

}
