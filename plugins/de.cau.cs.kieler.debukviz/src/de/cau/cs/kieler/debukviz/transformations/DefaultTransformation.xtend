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

import de.cau.cs.kieler.debukviz.VariableTransformation
import de.cau.cs.kieler.debukviz.VariableTransformationContext
import de.cau.cs.kieler.debukviz.util.EdgeBuilder
import de.cau.cs.kieler.debukviz.util.NodeBuilder
import de.cau.cs.kieler.klighd.kgraph.KNode
import org.eclipse.debug.core.model.IVariable

class DefaultTransformation extends VariableTransformation {
    
    /** Names of the primitive types. */
    static val primitiveTypes = #[ "int", "short", "long", "byte", "float", "double" ]
    
    override transform(IVariable variable, KNode graph, VariableTransformationContext context) {
        val builder = NodeBuilder.forVariable(variable, graph, context)
            .type(variable.value.referenceTypeName)
        
        for (v : variable.value.variables) {
            // Stuff can go wrong while accessing reference type names of values whose class has not
            // been loaded
            try {
                if (primitiveTypes.contains(v.referenceTypeName)) {
                    builder.addProperty(v.name, v.value.valueString)
                }
            } catch (Exception e) {
                // Just skip the variable
            }
        }
        val sourceNode = builder.build()
        
        for (v : variable.value.variables) {
            // Stuff can go wrong while accessing reference type names of values whose class has not
            // been loaded
            try {
                if (!primitiveTypes.contains(v.referenceTypeName)) {
                    invokeFor(v, graph, context)
                    val targetNode = context.findAssociation(v)
                    if (targetNode !== null) {
                        EdgeBuilder.forContext(context)
                                .from(sourceNode)
                                .to(targetNode)
                                .centerLabel(v.name)
                                .build()
                    }
                }
            } catch (Exception e) {
                // Just skip the variable
            }
        }
    }
    
}
