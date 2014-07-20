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
import java.util.ArrayList
import java.util.Arrays
import java.util.Collections
import java.util.LinkedList
import org.eclipse.debug.core.model.IIndexedValue
import org.eclipse.debug.core.model.IValue
import org.eclipse.debug.core.model.IVariable
import org.eclipse.jdt.debug.core.IJavaClassType
import org.eclipse.jdt.debug.core.IJavaType
import org.eclipse.jdt.debug.core.IJavaValue

/**
 * Transformation for Queues. One node is created for the list itself, with references to all
 * contained variables.
 */
class QueueTransformation extends VariableTransformation {
    
    override transform(IVariable variable, KNode graph, VariableTransformationContext context) {
        val queueNode = NodeBuilder.forVariable(variable, graph, context)
                .type(variable.value.referenceTypeName)
                .addDefaultInputPort(PortSide::NORTH)
                .addLayoutOption(LayoutOptions::PORT_CONSTRAINTS, PortConstraints::FIXED_ORDER)
                .build()
        variable.value.getContent().forEach[ element, index |
            invokeFor(element, graph, context)
            val elementNode = context.findAssociation(element)
            if (elementNode != null) {
                EdgeBuilder.forContext(context)
                        .from(queueNode)
                        .addSourcePort(PortSide::SOUTH, -index)
                        .to(elementNode)
                        .tailLabel(index.toString)
                        .build()
            } else {
                EdgeBuilder.makePort(PortSide::SOUTH, -index).setNode(queueNode)
            }
        ]
    }
    
    def getContent(IValue queue) {
        getContent(queue, (queue as IJavaValue).javaType)
    }
    
    def Iterable<IVariable> getContent(IValue queue, IJavaType type) {
        if (type != null) {
            switch (type.name) {
                case "java.util.ArrayDeque": queue.handleArrayDeque
                case "java.util.concurrent.ArrayBlockingQueue": queue.handleArrayBlockingQueue
                case "java.util.concurrent.LinkedBlockingQueue": queue.handleLinkedBlockingQueue
                case "java.util.concurrent.LinkedBlockingDeque": queue.handleLinkedBlockingDeque
                case "java.util.concurrent.ConcurrentLinkedQueue": queue.handleLinkedBlockingQueue
                // TODO support java.util.PriorityQueue
                default:
                    queue.getContent(
                        if (type instanceof IJavaClassType)
                            (type as IJavaClassType).superclass
                        else null
                    )
            }
        } else {
            Collections.emptyList
        }
    }
    
    def handleArrayDeque(IValue queue) {
        val head = queue.getNamedVariable("head").intValue
        val tail = queue.getNamedVariable("tail").intValue
        val elements = queue.getNamedVariable("elements").value as IIndexedValue
        if (tail < head) {
            val result = new ArrayList(elements.size - head + tail)
            result.addAll(elements.getVariables(head, elements.size - head))
            result.addAll(elements.getVariables(0, tail))
            return result
        } else {
            return Arrays.asList(elements.getVariables(head, tail - head))
        }
    }
    
    def handleArrayBlockingQueue(IValue queue) {
        val takeIndex = queue.getNamedVariable("takeIndex").intValue
        val putIndex = queue.getNamedVariable("putIndex").intValue
        val items = queue.getNamedVariable("items").value as IIndexedValue
        if (putIndex < takeIndex) {
            val result = new ArrayList(items.size - takeIndex + putIndex)
            result.addAll(items.getVariables(takeIndex, items.size - takeIndex))
            result.addAll(items.getVariables(0, putIndex))
            return result
        } else {
            return Arrays.asList(items.getVariables(takeIndex, putIndex - takeIndex))
        }
    }
    
    def handleLinkedBlockingQueue(IValue queue) {
        val result = new LinkedList
        var node = queue.getNamedVariable("head")
        while (node.isNonNull) {
            val item = node.value.getNamedVariable("item")
            if (item.isNonNull) {
                result += item
            }
            node = node.value.getNamedVariable("next")
        }
        return result
    }
    
    def handleLinkedBlockingDeque(IValue queue) {
        val result = new LinkedList
        var node = queue.getNamedVariable("first")
        while (node.isNonNull) {
            val item = node.value.getNamedVariable("item")
            if (item.isNonNull) {
                result += item
            }
            node = node.value.getNamedVariable("next")
        }
        return result
    }
    
}