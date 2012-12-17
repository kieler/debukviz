package de.cau.cs.kieler.klighd.debug;

import org.eclipse.ui.IStartup;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;

import de.cau.cs.kieler.klighd.debug.selection.KlighdSelectionListener;

/**
 * The activator class controls the plug-in life cycle
 */
public class KlighdDebugPlugin extends AbstractUIPlugin implements IStartup {

    // The plug-in ID
    public static final String PLUGIN_ID = "de.cau.cs.kieler.klighd.debug"; //$NON-NLS-1$

    // The shared instance
    private static KlighdDebugPlugin plugin;

    /**
     * The constructor
     */
    public KlighdDebugPlugin() {
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.eclipse.ui.plugin.AbstractUIPlugin#start(org.osgi.framework.BundleContext)
     */
    public void start(BundleContext context) throws Exception {
        super.start(context);
        plugin = this;
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.eclipse.ui.plugin.AbstractUIPlugin#stop(org.osgi.framework.BundleContext)
     */
    public void stop(BundleContext context) throws Exception {
        plugin = null;
        super.stop(context);
    }

    /**
     * Returns the shared instance
     * 
     * @return the shared instance
     */
    public static KlighdDebugPlugin getDefault() {
        return plugin;
    }

    @Override
    public void earlyStartup() {
        KlighdSelectionListener.getInstance().register();
    }

}
