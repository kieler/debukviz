package de.cau.cs.kieler.klighd.debug;

import java.util.HashMap;
import java.util.Map;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.Platform;
import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.IVariable;
import org.eclipse.jdt.debug.core.IJavaClassType;
import org.eclipse.jdt.debug.core.IJavaType;
import org.eclipse.jdt.debug.core.IJavaValue;
import org.eclipse.ui.statushandlers.StatusManager;

import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation;

/**
 * Class that gathers extension data from the 'de.cau.cs.kieler.klighd.debugVisualization' extension
 * point and publishes this data using the singleton pattern.
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
        // If model type is an array return null
        if (model.getValue().getReferenceTypeName().endsWith("[]"))
            return null;

        // Get a transformation
        AbstractDebugTransformation result = null;

        // If no transformation is registred search for transformation registred to a superclass
        IJavaType type = ((IJavaValue) model.getValue()).getJavaType();
        if (type instanceof IJavaClassType) {
            IJavaClassType superClass = (IJavaClassType) type;
            while (result == null && superClass != null) {
                String test = superClass.getName().replaceAll("\\$", ".");
                result = transformationMap.get(superClass.getName().replaceAll("\\$", "."));
                superClass = superClass.getSuperclass();
            }
        }
        return result;
    }
}
