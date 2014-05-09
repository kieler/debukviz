/*
 * KIELER - Kiel Integrated Environment for Layout Eclipse RichClient
 *
 * http://www.informatik.uni-kiel.de/rtsys/kieler/
 * 
 * Copyright 2013 by
 * + Christian-Albrechts-University of Kiel
 *   + Department of Computer Science
 *     + Real-Time and Embedded Systems Group
 * 
 * This code is provided under the terms of the Eclipse Public License (EPL).
 * See the file epl-v10.html for the license text.
 */
package de.cau.cs.kieler.debukviz;

import java.util.HashMap;
import java.util.Map;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.Platform;
import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.IVariable;
import org.eclipse.jdt.debug.core.IJavaArray;
import org.eclipse.jdt.debug.core.IJavaClassType;
import org.eclipse.jdt.debug.core.IJavaObject;
import org.eclipse.jdt.debug.core.IJavaType;
import org.eclipse.jdt.debug.core.IJavaValue;
import org.eclipse.ui.statushandlers.StatusManager;

import de.cau.cs.kieler.klighd.debug.transformations.ArrayTransformation;

/**
 * Class that gathers extension data from the {@code de.cau.cs.kieler.klighd.debugVisualization}
 * extension point and publishes this data using the singleton pattern.
 * 
 * @author hwi
 */
public class KlighdDebugExtension {
    
    /** Identifier of the extension point */
    public final static String EXTENSION_POINT_ID = "de.cau.cs.kieler.klighd.debugVisualization";
    
    /** The singleton instance of the {@code KlighdDebugExtension} class */
    public final static KlighdDebugExtension INSTANCE = new KlighdDebugExtension();
    
    /** map of visualization class name to the runtime instances of their transformation. */
    private Map<String, AbstractDebugTransformation> transformationMap =
            new HashMap<String, AbstractDebugTransformation>();

    /**
     * Creates an instance of this class and gathers extension data.
     */
    KlighdDebugExtension() {
        IConfigurationElement[] elements =
                Platform.getExtensionRegistry().getConfigurationElementsFor(EXTENSION_POINT_ID);
        
        for (IConfigurationElement element : elements) {
            if ("visualization".equals(element.getName())) {
                String transformation = element.getAttribute("transformation");
                String clazz = element.getAttribute("class");
                if (transformation != null && clazz != null) {
                    try {
                        AbstractDebugTransformation klighdDebug =
                                (AbstractDebugTransformation) element.createExecutableExtension(
                                        "transformation");
                        transformationMap.put(clazz, klighdDebug);
                    } catch (CoreException exception) {
                        StatusManager.getManager().handle(exception, KlighdDebugPlugin.PLUGIN_ID);
                    }
                }
            }
        }
    }

    /**
     * Returns the transformation instance for the given {@link IVariable}.
     * 
     * @param model
     *            IVariable to be transformed
     * @return transformation instance for the given model
     */
    public AbstractDebugTransformation getTransformation(IVariable model) {
        AbstractDebugTransformation result = null;
        try {
            IJavaValue value = (IJavaValue) model.getValue();
            if (value instanceof IJavaArray)
                return new ArrayTransformation();
            // If value doesn't represent an object or value represents the null object return null
            if (!(value instanceof IJavaObject) || value.isNull())
                return null;

            // If no transformation is stored for current class
            // search for transformation stored for the superclass if exists
            IJavaType type = value.getJavaType();
            if (type instanceof IJavaClassType) {
                IJavaClassType superClass = (IJavaClassType) type;
                while (result == null && superClass != null) {
                    // replace '$' by '.' to find inner classes
                    result = transformationMap.get(superClass.getName().replaceAll("\\$", "."));
                    superClass = superClass.getSuperclass();
                }
            }
        } catch (DebugException exception) {
            StatusManager.getManager().handle(exception, KlighdDebugPlugin.PLUGIN_ID);
        }
        return result;
    }
}
