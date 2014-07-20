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
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.options.PortConstraints
import de.cau.cs.kieler.kiml.options.PortSide
import java.util.Collections
import java.util.LinkedList
import org.eclipse.debug.core.model.IValue
import org.eclipse.debug.core.model.IVariable
import org.eclipse.jdt.debug.core.IJavaClassType
import org.eclipse.jdt.debug.core.IJavaType
import org.eclipse.jdt.debug.core.IJavaValue
import org.eclipse.xtext.xbase.lib.Pair

/**
 * Transformation for Maps. One node is created for the map itself; the keys have edges going
 * to the map node, while the values have edges coming from the map node.
 */
class MapTransformation extends VariableTransformation {
    
    override transform(IVariable variable, KNode graph, VariableTransformationContext context) {
        val mapNode = NodeBuilder.forVariable(variable, graph, context)
                .type(variable.value.referenceTypeName)
                .addDefaultInputPort(PortSide::WEST)
                .addLayoutOption(LayoutOptions::PORT_CONSTRAINTS, PortConstraints::FIXED_ORDER)
                .build()
        variable.value.getContent().forEach[ entry, index |
            invokeFor(entry.key, graph, context)
            val keyNode = context.findAssociation(entry.key)
            invokeFor(entry.value, graph, context)
            val valueNode = context.findAssociation(entry.value)
            if (keyNode != null) {
                EdgeBuilder.forContext(context)
                        .from(keyNode)
                        .to(mapNode)
                        .addTargetPort(PortSide.NORTH, index)
                        .build()
            } else {
                EdgeBuilder.makePort(PortSide::NORTH, index).setNode(mapNode)
            }
            if (valueNode != null) {
                EdgeBuilder.forContext(context)
                        .from(mapNode)
                        .addSourcePort(PortSide::SOUTH, -index)
                        .to(valueNode)
                        .build()                
            } else {
                EdgeBuilder.makePort(PortSide::SOUTH, -index).setNode(mapNode)
            }
        ]
    }
    
    def getContent(IValue map) {
        getContent(map, (map as IJavaValue).javaType)
    }
    
    def Iterable<Pair<IVariable, IVariable>> getContent(IValue map, IJavaType type) {
        if (type != null) {
            switch (type.name) {
                case "java.util.HashMap": map.handleHashMap
                case "java.util.IdentityHashMap": map.handleIdentityHashMap
                case "java.util.WeakHashMap": map.handleWeakHashMap
                case "java.util.EnumMap": map.handleEnumMap
                case "java.util.Collections$UnmodifiableMap":
                    map.getNamedVariable("m").value.getContent()
                case "java.util.Collections$SynchronizedMap":
                    map.getNamedVariable("m").value.getContent()
                case "java.util.Collections$CheckedMap":
                    map.getNamedVariable("m").value.getContent()
                // TODO support java.util.TreeMap
                default:
                    map.getContent(
                        if (type instanceof IJavaClassType)
                            (type as IJavaClassType).superclass
                        else null
                    )
            }
        } else {
            Collections.emptyList
        }
    }
    
    def handleHashMap(IValue map) {
        val result = new LinkedList
        map.getNamedVariable("table").value.variables.forEach[ entry |
            var n = entry
            while (n.isNonNull) {
                result += Pair.of(n.value.getNamedVariable("key"), n.value.getNamedVariable("value"))
                n = n.value.getNamedVariable("next")
            }
        ]
        return result
    }
    
    def handleIdentityHashMap(IValue map) {
        val result = new LinkedList
        val table = map.getNamedVariable("table").value.variables
        var i = 0;
        while (i < table.length - 1) {
            if (table.get(i).isNonNull) {
                result += Pair.of(table.get(i), table.get(i + 1))
            }
            i = i + 2
        }
        return result
    }
    
    def handleWeakHashMap(IValue map) {
        val result = new LinkedList
        map.getNamedVariable("table").value.variables.forEach[ entry |
            var n = entry
            while (n.isNonNull) {
                val key = n.value.getNamedVariable("referent")
                if (key != null) {
                    result += Pair.of(key, n.value.getNamedVariable("value"))
                }
                n = n.value.getNamedVariable("next")
            }
        ]
        return result
    }
    
    def handleEnumMap(IValue map) {
        val result = new LinkedList
        val vals = map.getNamedVariable("vals").value.variables
        for (enumValue : map.getNamedVariable("keyUniverse").value.variables) {
            val ordinal = enumValue.value.getNamedVariable("ordinal").intValue
            if (vals.get(ordinal).isNonNull) {
                result += Pair.of(enumValue, vals.get(ordinal))
            }
        }
        return result
    }
    
}
