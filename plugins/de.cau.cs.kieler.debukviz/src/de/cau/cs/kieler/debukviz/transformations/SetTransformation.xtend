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
package de.cau.cs.kieler.debukviz.transformations

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.debukviz.VariableTransformation
import de.cau.cs.kieler.debukviz.VariableTransformationContext
import de.cau.cs.kieler.debukviz.util.EdgeBuilder
import de.cau.cs.kieler.debukviz.util.NodeBuilder
import java.util.Collections
import org.eclipse.debug.core.model.IValue
import org.eclipse.debug.core.model.IVariable
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.options.PortConstraints
import java.util.LinkedList
import org.eclipse.jdt.debug.core.IJavaValue
import org.eclipse.jdt.debug.core.IJavaClassType
import org.eclipse.jdt.debug.core.IJavaType

/**
 * Transformation for Sets. One node is created for the set itself, with references to all
 * contained variables.
 */
class SetTransformation extends VariableTransformation {
    
    override transform(IVariable variable, KNode graph, VariableTransformationContext context) {
        val setNode = NodeBuilder.forVariable(variable, graph, context)
                .type(variable.value.referenceTypeName)
                .addLayoutOption(LayoutOptions::PORT_CONSTRAINTS, PortConstraints::FREE)
                .build()
        variable.value.getContent().forEach[ element |
            invokeFor(element, graph, context)
            val elementNode = context.findAssociation(element)
            if (elementNode != null) {
                EdgeBuilder.forContext(context)
                        .from(setNode)
                        .to(elementNode)
                        .build()
            }
        ]
    }
    
    def getContent(IValue set) {
        getContent(set, (set as IJavaValue).javaType)
    }
    
    def Iterable<IVariable> getContent(IValue set, IJavaType type) {
        if (type != null) {
            switch (type.name) {
                case "java.util.HashSet": set.handleHashSet
                case "java.util.RegularEnumSet": set.handleRegularEnumSet
                case "java.util.JumboEnumSet": set.handleJumboEnumSet
                case "java.util.Collections$UnmodifiableSet":
                    set.getNamedVariable("c").value.getContent()
                case "java.util.Collections$SynchronizedSet":
                    set.getNamedVariable("c").value.getContent()
                case "java.util.Collections$CheckedSet":
                    set.getNamedVariable("c").value.getContent()
                // TODO support java.util.TreeSet
                default:
                    set.getContent(
                        if (type instanceof IJavaClassType)
                            (type as IJavaClassType).superclass
                        else null
                    )
            }
        } else {
            Collections.emptyList
        }
    }
    
    def handleHashSet(IValue set) {
        val result = new LinkedList
        set.getNamedVariable("map").value.getNamedVariable("table").value.variables.forEach[ node |
            var n = node
            while (n.isNonNull) {
                result += n.value.getNamedVariable("key")
                n = n.value.getNamedVariable("next")
            }
        ]
        return result
    }
    
    def handleRegularEnumSet(IValue set) {
        val result = new LinkedList
        val elements = set.getNamedVariable("elements").longValue
        for (enumValue : set.getNamedVariable("universe").value.variables) {
            val ordinal = enumValue.value.getNamedVariable("ordinal").intValue
            if ((elements.bitwiseAnd(1L << ordinal)) != 0) {
                result += enumValue
            }
        }
        return result
    }
    
    def handleJumboEnumSet(IValue set) {
        val result = new LinkedList
        val elements = set.getNamedVariable("elements").value.variables.map[it.longValue]
        for (enumValue : set.getNamedVariable("universe").value.variables) {
            val ordinal = enumValue.value.getNamedVariable("ordinal").intValue
            if (elements.get(ordinal >>> 6).bitwiseAnd(1L << ordinal) != 0) {
                result += enumValue
            }
        }
        return result
    }
    
}