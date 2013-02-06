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
package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

/**
 * Transformation for a variable which is representing a variable of type "TreeMap"
 */
class TreeMapTransformation extends AbstractDebugTransformation {
   
    @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
    @Inject 
    extension KPolylineExtensions 
    @Inject 
    extension KLabelExtensions 
    
    /**
	 * Transformation for a variable which is representing a variable of type "TreeMap"
	 * 
	 * {@inheritDoc}
	 */
    override transform(IVariable model, Object transformationInfo) {
        return KimlUtil::createInitializedNode() => [
            //it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 50f)
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::DOWN)
            
            it.data += renderingFactory.createKRectangle()
            
            if (Integer::parseInt(model.getValue("size")) > 0)
           		it.addTreeNode(model.getVariable("root"),"")
            else
			{
				it.children += createNode() => [
					it.setNodeSize(80,80)
					it.data += renderingFactory.createKRectangle() => [
						it.children += renderingFactory.createKText() => [
							it.text = "empty"
						]
					]
				]
			}
        ]
    }
    
    /**
     * Gets the variable with name "parent" which is stored in a given variable.
     * Just syntactic sugar
     * @param variable variable in which the variable with name "parent" is stored
     * @return variable with name "parent"
     */
    def getParent(IVariable variable) {
    	variable.getVariable("parent")
    }
    
    
    /**
     * Adds a node associated with variable represented by the given root to the given node.
     * Performs recursive call for the variable representing the fields "right" and "left"
     * The added node is connected with the node representing the parent of the variable represented by root
     * and labeled the edge with a given label
     * @param node node to which the created node will be added
     * @param root variable representing a root element
     * @param label label which labels the edge
     */
    def addTreeNode(KNode node, IVariable root, String label) {
    	val left = root.getVariable("left")
    	val right = root.getVariable("right")
      	
      	node.createKeyValueNode(root)
      	
       	if (right.valueIsNotNull) {
       		node.addTreeNode(right,"right")
       	}
       	if (left.valueIsNotNull) {
       		node.addTreeNode(left,"left")
       	}
       	
        if (root.parent.valueIsNotNull) {
        	root.parent.createEdgeById(root) => [
                root.createLabel(it) => [
                    it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT,EdgeLabelPlacement::CENTER)
                    it.setLabelSize(50,50)
                    it.text = label
                ]
       			it.data += renderingFactory.createKPolyline() => [
                    it.setLineWidth(2)
                    it.addArrowDecorator()
            	]
       		]
        }
    }
    
    
    /**
     * Adds a pair of nodes associated with the key and the value stored in a given root to the given rootNode.
     * The pair is connected by an edge
     * @param rootNode node to which the created node will be added
     * @param root variable in which the variable representing a key element and the variable representing a value element are stored
     */
    def createKeyValueNode(KNode rootNode, IVariable root) {
    	val key = root.getVariable("key")
    	val value = root.getVariable("value")
    	val node = rootNode.addNodeById(root)
	    if (node != null) {
    	    node => [
    	    	it.data += renderingFactory.createKRectangle()
    	    	it.children += key.nextTransformation
            	it.children += value.nextTransformation
           	]
	    }
	    key.createEdgeById(value) => [
            value.createLabel(it) => [
                it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT,EdgeLabelPlacement::CENTER)
                it.setLabelSize(50,50)
                it.text = "value"
            ]
       		it.data += renderingFactory.createKPolyline() => [
                    it.setLineWidth(2)
                    it.addArrowDecorator();
            ]
       	]
    }
}