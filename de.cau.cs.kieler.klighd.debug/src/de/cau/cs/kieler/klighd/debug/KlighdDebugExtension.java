package de.cau.cs.kieler.klighd.debug;

import java.util.HashMap;
import java.util.Map;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.ui.statushandlers.StatusManager;

import com.google.inject.Binder;
import com.google.inject.Guice;
import com.google.inject.Module;
import com.google.inject.TypeLiteral;

import de.cau.cs.kieler.core.krendering.extensions.ViewSynthesisShared;
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation;
import de.cau.cs.kieler.klighd.debug.visualization.IKlighdDebug;
import de.cau.cs.kieler.klighd.transformations.AbstractTransformation;
import de.cau.cs.kieler.klighd.transformations.ReinitializingTransformationProxy.ViewSynthesisScope;

/**
 * Class that gathers extension data from the '...' extension point and publishes this data using
 * the singleton pattern.
 * 
 * @author hwi
 */
public class KlighdDebugExtension {
    /** Identifier of the extension point */
    public final static String EXTENSION_POINT_ID = "de.cau.cs.kieler.klighd.debugVisualization";
    /** The singleton instance of the {@code KlighdDebugExtension} class */
    public final static KlighdDebugExtension INSTANCE = new KlighdDebugExtension();
    /** map of visualization class to the runtime instances of their transformation. */
    private Map<String, AbstractDebugTransformation> transformationMap = new HashMap<String, AbstractDebugTransformation>();

    /**
     * Creates an instance of this class and gathers extension data.
     */
    KlighdDebugExtension() {
        IConfigurationElement[] elements = Platform.getExtensionRegistry()
                .getConfigurationElementsFor(EXTENSION_POINT_ID);
        for (IConfigurationElement element : elements) {
            if ("visualization".equals(element.getName())) {
                String transformation = element.getAttribute("transformation");
                String clazz = element.getAttribute("class");
                if (transformation != null && clazz != null) {
                    try {
                        AbstractDebugTransformation klighdDebug = (AbstractDebugTransformation) element
                                .createExecutableExtension("transformation");
                        transformationMap.put(clazz, klighdDebug);
                    } catch (CoreException exception) {
                        StatusManager.getManager().handle(exception, KlighdDebugPlugin.PLUGIN_ID);
                    }
                }
            }
        }
    }

    /**
     * Returns the transformation instance for the given class.
     * 
     * @param clazz
     *            identifier of class
     * @return the associated transformation
     */
    public AbstractDebugTransformation getTransformation(final String clazz) {
        return transformationMap.get(clazz.split("<")[0]);
    }
}
