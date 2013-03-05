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
 package de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.HorizontalAlignment
import de.cau.cs.kieler.core.krendering.LineStyle
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

/*
 * Transformation for a IVariable representing a FBendpoint
 * 
 * @ author tit
 */
class LLayerTransformation extends AbstractKielerGraphTransformation {

	@Inject 
    extension KNodeExtensions
    @Inject 
    extension KPolylineExtensions 
    @Inject
    extension KRenderingExtensions
    
    /** The layout algorithm to use. */
    val layoutAlgorithm = "de.cau.cs.kieler.kiml.ogdf.planarization"
    /** The spacing to use. */
    val spacing = 75f
    /** The horizontal alignment for the left column of all grid layouts. */
    val leftColumnAlignment = HorizontalAlignment::RIGHT
    /** The horizontal alignment for the right column of all grid layouts. */
    val rightColumnAlignment = HorizontalAlignment::LEFT
    
    /** Specifies when to show the property map. */
	val showPropertyMap = ShowTextIf::DETAILED
    /** Specifies when to show the visualization. */
	val showVisualization = ShowTextIf::DETAILED
        
    /** Specifies when to show the hashCode text. */
    val showHashCode = ShowTextIf::ALWAYS
    /** Specifies when to show the id text. */
    val showID = ShowTextIf::DETAILED
    /** Specifies when to show the owner text. */
	val showOwner = ShowTextIf::DETAILED
    /** Specifies when to show the size text. */
    val showSize = ShowTextIf::DETAILED

    /**
     * {@inheritDoc}
     */
	override transform(IVariable layer, Object transformationInfo) {
        detailedView = transformationInfo.isDetailed
        
        return KimlUtil::createInitializedNode => [
            addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            addLayoutParam(LayoutOptions::SPACING, spacing)

			addInvisibleRendering
            addHeaderNode(layer)
            
            // add propertyMap
            if(showPropertyMap.conditionalShow(detailedView))
            	addPropertyMapNode(layer.getVariable("propertyMap"), layer)

            //add visualization containing nodes of layer and edges between the nodes of this layer
            if (showVisualization.conditionalShow(detailedView))
                addVisualization(layer)
        ]
	}
	
	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
	    var retVal = if(showPropertyMap.conditionalShow(detailedView)) 2 else 1
        if (showVisualization.conditionalShow(detailedView)) retVal = retVal + 1
		return retVal
	}
	
    /**
     * Creates the header node containing basic informations for this element.
     * 
     * @param rootNode
     *              The KNode the new created KNode will be placed in.
     * @param layer
     *              The IVariable representing the layer transformed in this transformation.
     * 
     * @return The new created header KNode
     */
    def addHeaderNode(KNode rootNode, IVariable layer) {
        return rootNode.addNodeById(layer) => [
            data += renderingFactory.createKRectangle => [

                val table = headerNodeBasics(detailedView, layer)
    
                // id of layer
                if (showID.conditionalShow(detailedView)) {
                    table.addGridElement("id:", leftColumnAlignment)
                    table.addGridElement(nullOrValue(layer, "id"), rightColumnAlignment)
                } 
       
                // hashCode of layer
                if (showHashCode.conditionalShow(detailedView)) {
                    table.addGridElement("hashCode:", leftColumnAlignment)
                    table.addGridElement(layer.getValue("hashCode"), rightColumnAlignment)
                }

                // owner of layer
                if (showOwner.conditionalShow(detailedView)) {
                    table.addGridElement("owner:", leftColumnAlignment)
                    table.addGridElement(layer.nullOrTypeAndID("owner"), rightColumnAlignment)
                }

                // size of layer
                if (showSize.conditionalShow(detailedView)) {
                    table.addGridElement("size (x, y):", leftColumnAlignment)
                    table.addGridElement("(" + layer.getValue("size.x") + ", " 
                                             + layer.getValue("size.y") + ")", rightColumnAlignment
                    )
                }
            ]
        ]
    }

	/**
     * Creates a node containing a visualization of the layer. It includes all nodes on the layer 
     * and all edges spanning between them. Also creates an edge from the node registered for 
     * {@code layer} to the new node.
     *  
     * @param rootNode
     *            the node the visualization node will be included in
     * @param layer
     *            the layer to be visualized
     * @return the new created node
     */
	def addVisualization(KNode rootNode, IVariable layer) {
		val nodes = layer.getVariable("nodes")
		
        return rootNode.addNodeById(nodes) => [
            data += renderingFactory.createKRectangle => [
                lineWidth = 4
            ]
            // add all nodes
		    nodes.linkedList.forEach[IVariable node |
          		nextTransformation(node, false)
	        ]
	        
	        // add the edges, if they are span between two nodes of this layer
	        nodes.linkedList.forEach[IVariable node |
	        	node.getVariable("ports").linkedList.forEach[IVariable port |
	        		port.getVariable("outgoingEdges").linkedList.forEach[IVariable edge |
	        			
	        			// verify that the current edge has to be created
	        			val target = edge.getVariable("target.owner")
	        			if(nodes.containsValWithID(target.valueString)) {
		                    node.createEdgeById(target) => [
		        				data += renderingFactory.createKPolyline => [
			            		    setLineWidth(2)
		                            addArrowDecorator
		                            
		                            switch edge.edgeType {
		                                case "COMPOUND_DUMMY" : setLineStyle(LineStyle::DASH)
		                                case "COMPOUND_SIDE" : setLineStyle(LineStyle::DOT)
		                                default : setLineStyle(LineStyle::SOLID)
		                            }
		    	    			]
		        			]
	        			}
	        		]
	        	]
	        ]
	        // create the edge from header node to this node
            layer.createTopElementEdge(nodes, "visualization")
        ]
    }
    
	/** 
	 * returns the type of the given edge.
	 * 
	 * @param edge
	 *             The IVariable representing a LEdge to check.
	 * 
	 * @return the type of the edge or "NORMAL", it type is not specified in the property map.
	 */
    def getEdgeType(IVariable edge) {
    	val type = edge.getVariable("propertyMap").getValFromHashMap("EDGE_TYPE")
    	if (type == null) {
	        return "NORMAL"
    	} else {
	        return type.getValue("name")   
    	}
    }
}