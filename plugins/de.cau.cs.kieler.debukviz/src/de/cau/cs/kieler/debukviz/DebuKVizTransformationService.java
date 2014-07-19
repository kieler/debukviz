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
import java.util.Queue;

import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.Status;
import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.IVariable;
import org.eclipse.jdt.debug.core.IJavaArray;
import org.eclipse.jdt.debug.core.IJavaClassType;
import org.eclipse.jdt.debug.core.IJavaInterfaceType;
import org.eclipse.jdt.debug.core.IJavaObject;
import org.eclipse.jdt.debug.core.IJavaType;
import org.eclipse.jdt.debug.core.IJavaValue;
import org.eclipse.ui.statushandlers.StatusManager;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.inject.Guice;
import com.google.inject.Injector;

import de.cau.cs.kieler.debukviz.transformations.ArrayTransformation;

/**
 * Managers the debug transformations registered with the
 * {@code de.cau.cs.kieler.klighd.debugVisualization} extension point.
 */
final class DebuKVizTransformationService {
    
    /** Singleton. */
    public final static DebuKVizTransformationService INSTANCE = new DebuKVizTransformationService();
    
    /** Map of visualization class name to the runtime instances of their transformation. */
    private Map<String, Class<? extends VariableTransformation>> transformationMap = Maps.newHashMap();
    
    /** Injector used to instantiate transformations. */
    private Injector injector = Guice.createInjector();

    /**
     * Creates a new instance and initializes it with the extension point data.
     */
    private DebuKVizTransformationService() {
        IConfigurationElement[] elements = Platform.getExtensionRegistry().getConfigurationElementsFor(
                DebuKVizPlugin.EXTENSION_POINT_ID);
        
        for (IConfigurationElement element : elements) {
            if ("visualization".equals(element.getName())) {
                String typeClassName = element.getAttribute("type");
                String transformationClassName = element.getAttribute("transformation");
                
                if (typeClassName != null && transformationClassName != null) {
                    try {
                        VariableTransformation transformation =
                                (VariableTransformation) element.createExecutableExtension(
                                        "transformation");
                        transformationMap.put(typeClassName, transformation.getClass());
                    } catch (Exception exception) {
                        StatusManager.getManager().handle(new Status(
                                Status.ERROR,
                                DebuKVizPlugin.PLUGIN_ID,
                                "Error loading transformation: " + transformationClassName,
                                exception));
                    }
                }
            }
        }
    }

    /**
     * Returns a transformation that can handle the given {@link IVariable}. This method may not always
     * return a non-null transformation.
     * 
     * @param variable variable to be transformed.
     * @return transformation instance for the given variable.
     */
    public VariableTransformation transformationFor(IVariable variable) {
        VariableTransformation result = null;
        
        try {
            IJavaValue value = (IJavaValue) variable.getValue();
            
            // Check what kind of object the variable represents
            if (!(value instanceof IJavaObject) || value.isNull()) {
                // The value is either not a java object or null
                return null;
            } else if (value instanceof IJavaArray) {
                // It's an object, so use the array transformation
                result = injector.getInstance(ArrayTransformation.class);
            } else {
                // We'll check the Java object's type and see if we have a transformation registered
                // for it. If we don't find one, we go up the inheritance tree until we find a
                // transformation that will work
                Queue<IJavaType> inheritanceQueue = Lists.newLinkedList();
                inheritanceQueue.add(value.getJavaType());
                
                while (!inheritanceQueue.isEmpty() && result == null) {
                    // Find the current type's class name
                    IJavaType type = inheritanceQueue.poll();
                    String typeName = type.getName().replaceAll("\\$", ".");
                    
                    // Check if we have a transformation for this class
                    Class<?> transformationCandidate = transformationMap.get(typeName);
                    
                    if (transformationCandidate == null) {
                        // We don't have a transformation, so go up the hierarchy tree
                        if (type instanceof IJavaClassType) {
                            IJavaClassType classType = (IJavaClassType) type;
                            
                            // Visit the interfaces before the superclass, so Object is visited last
                            if (classType.getInterfaces() != null) {
                                inheritanceQueue.addAll(Lists.newArrayList(classType.getInterfaces()));
                            }

                            if (classType.getSuperclass() != null) {
                                inheritanceQueue.add(classType.getSuperclass());
                            }
                            
                        } else if (type instanceof IJavaInterfaceType) {
                            IJavaInterfaceType interfaceType = (IJavaInterfaceType) type;
                            
                            if (interfaceType.getSuperInterfaces() != null) {
                                inheritanceQueue.addAll(
                                        Lists.newArrayList(interfaceType.getSuperInterfaces()));
                            }
                        }
                    } else {
                        // We do have a transformation, so go ahead and use that
                        result = (VariableTransformation) injector.getInstance(transformationCandidate);
                    }
                }
            }
        } catch (DebugException exception) {
            StatusManager.getManager().handle(exception, DebuKVizPlugin.PLUGIN_ID);
        }

        return result;
    }
}
