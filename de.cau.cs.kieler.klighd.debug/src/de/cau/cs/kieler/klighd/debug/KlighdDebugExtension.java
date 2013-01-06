package de.cau.cs.kieler.klighd.debug;

import java.util.HashMap;
import java.util.Map;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.Platform;
import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.IVariable;
import org.eclipse.ui.statushandlers.StatusManager;
import org.osgi.framework.Bundle;
import org.eclipse.jdt.debug.core.IJavaClassType;
import org.eclipse.jdt.debug.core.IJavaType;
import org.eclipse.jdt.debug.core.IJavaValue;
import org.eclipse.jdt.debug.core.IJavaVariable;

import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation;

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
     * @throws DebugException
     * @throws ClassNotFoundException
     */
    @SuppressWarnings("all")
    public AbstractDebugTransformation getTransformation(IVariable model) throws DebugException {
        String clazz = model.getValue().getReferenceTypeName();

        // If clazz ends with [] return null
        if (clazz.endsWith("[]"))
            return null;

        // remove generic subtype
        clazz = clazz.split("<")[0];
        // Get a transformation
        AbstractDebugTransformation result = null;
        // If no transformation is registred search for transformation registred to a superclass
        if (result == null) {
            IJavaClassType superClass = (IJavaClassType) ((IJavaValue) model.getValue()).getJavaType();
            while (result == null && superClass != null) {
                result = transformationMap.get(superClass.getName());
                superClass = superClass.getSuperclass();
            }
        }
        return result;
    }
}
