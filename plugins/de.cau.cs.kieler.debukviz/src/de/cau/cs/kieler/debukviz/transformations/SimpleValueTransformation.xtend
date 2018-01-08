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
import de.cau.cs.kieler.debukviz.util.NodeBuilder
import de.cau.cs.kieler.klighd.kgraph.KNode
import org.eclipse.debug.core.model.IVariable

/**
 * Transformation for variables displaying a simple value, such as a Boolean or number.
 */
class SimpleValueTransformation extends VariableTransformation {
    
    override transform(IVariable variable, KNode graph, VariableTransformationContext context) {
        val typeName = variable.value.referenceTypeName
        NodeBuilder.forVariable(variable, graph, context)
            .type(typeName.substring(typeName.lastIndexOf('.') + 1))
            .value(variable.value.getNamedVariable("value").value.valueString)
            .build();
    }
    
}