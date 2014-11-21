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
import java.util.Arrays
import java.util.Collections
import java.util.LinkedList
import org.eclipse.debug.core.model.IIndexedValue
import org.eclipse.debug.core.model.IValue
import org.eclipse.debug.core.model.IVariable
import org.eclipse.jdt.debug.core.IJavaClassType
import org.eclipse.jdt.debug.core.IJavaObject
import org.eclipse.jdt.debug.core.IJavaType
import org.eclipse.jdt.debug.core.IJavaValue

/**
 * Transformation for Lists. One node is created for the list itself, with references to all
 * contained variables.
 */
class ListTransformation extends VariableTransformation {
    
    override transform(IVariable variable, KNode graph, VariableTransformationContext context) {
        val listNode = NodeBuilder.forVariable(variable, graph, context)
                .type(variable.value.referenceTypeName)
                .addDefaultInputPort(PortSide::NORTH)
                .addLayoutOption(LayoutOptions::PORT_CONSTRAINTS, PortConstraints::FIXED_ORDER)
                .build()
        variable.value.getContent().forEach[ element, index |
            invokeFor(element, graph, context)
            val elementNode = context.findAssociation(element)
            if (elementNode != null) {
                EdgeBuilder.forContext(context)
                        .from(listNode)
                        .addSourcePort(PortSide::SOUTH, -index)
                        .to(elementNode)
                        .tailLabel(index.toString)
                        .build()
            } else {
                EdgeBuilder.makePort(PortSide::SOUTH, -index).setNode(listNode)
            }
        ]
    }
    
    def getContent(IValue list) {
        getContent(list, (list as IJavaValue).javaType)
    }
    
    def Iterable<IVariable> getContent(IValue list, IJavaType type) {
        if (type != null) {
            switch (type.name) {
                case "java.util.ArrayList": list.handleArrayList
                case "java.util.Arrays$ArrayList": list.handleArraysList
                case "java.util.LinkedList": list.handleLinkedList
                case "java.util.Vector": list.handleVector
                case "java.util.Collections$UnmodifiableList":
                    list.getNamedVariable("list").value.getContent()
                case "java.util.Collections$SynchronizedList":
                    list.getNamedVariable("list").value.getContent()
                case "java.util.Collections$CheckedList":
                    list.getNamedVariable("list").value.getContent()
                case "org.eclipse.emf.common.util.BasicEList": list.handleEList
                default:
                    list.getContent(
                        if (type instanceof IJavaClassType)
                            (type as IJavaClassType).superclass
                        else null
                    )
            }
        } else {
            Collections.emptyList
        }
    }
    
    def handleArrayList(IValue list) {
        val size = list.getNamedVariable("size").intValue
        val content = list.getNamedVariable("elementData").value as IIndexedValue
        return Arrays.asList(content.getVariables(0, size))
    }
    
    def handleArraysList(IValue list) {
        return Arrays.asList(list.getNamedVariable("a").value.variables)
    }
    
    def handleLinkedList(IValue list) {
        val result = new LinkedList
        if (list.hasNamedVariable("header")) {
            // this is the old implementation of LinkedList
            var entry = list.getNamedVariable("header").value
            val startId = (entry as IJavaObject).uniqueId
            var long currentId
            do {
                entry = entry.getNamedVariable("next").value
                currentId = (entry as IJavaObject).uniqueId
                if (currentId != startId) {
                    result += entry.getNamedVariable("element")
                }
            } while (currentId != startId)
        } else {
            // this is the new implementation of LinkedList
            var node = list.getNamedVariable("first")
            while (node.isNonNull) {
                result += node.value.getNamedVariable("item")
                node = node.value.getNamedVariable("next")
            }
        }
        return result
    }
    
    def handleVector(IValue list) {
        val size = list.getNamedVariable("elementCount").intValue
        val content = list.getNamedVariable("elementData").value as IIndexedValue
        return Arrays.asList(content.getVariables(0, size))
    }
    
    def handleEList(IValue list) {
        val size = list.getNamedVariable("size").intValue
        val content = list.getNamedVariable("data").value as IIndexedValue
        return Arrays.asList(content.getVariables(0, size))
    }
    
}