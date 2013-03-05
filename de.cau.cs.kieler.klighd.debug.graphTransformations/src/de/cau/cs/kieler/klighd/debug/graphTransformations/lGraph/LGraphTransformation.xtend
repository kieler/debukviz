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
 * Transformation for an IVariable representing a LGraph.
 * 
 * @ author tit
 */
class LGraphTransformation extends AbstractKielerGraphTransformation {
    
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
    /** Specifies when to show the visualization node. */
    val showVisulalization = ShowTextIf::DETAILED

    /** Specifies when to show the id. */
    val showID = ShowTextIf::ALWAYS
    /** Specifies when to show the hashCode. */
    val showHashCode = ShowTextIf::ALWAYS
    /** Specifies when to show the hashCodeCounter. */
    val showHashCodeCounter = ShowTextIf::DETAILED
    /** Specifies when to show the size. */
    val showSize = ShowTextIf::DETAILED
    /** Specifies when to show the insets. */
    val showInsets = ShowTextIf::DETAILED
    /** Specifies when to show the offset. */
    val showOffset = ShowTextIf::DETAILED
    /** Specifies when to show the number of nodes. */
    val showNodesCount = ShowTextIf::COMPACT
    /** Specifies when to show the number of layers. */
    val showLayersCount = ShowTextIf::COMPACT
    
    /**
     * {@inheritDoc}
     */
	override transform(IVariable graph, Object transformationInfo) {
        detailedView = transformationInfo.isDetailed
        
        return KimlUtil::createInitializedNode => [
            addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            addLayoutParam(LayoutOptions::SPACING, spacing)

			addInvisibleRendering
     		addHeaderNode(graph)
     		
            // add propertyMap
            if(showPropertyMap.conditionalShow(detailedView))
                addPropertyMapNode(graph.getVariable("propertyMap"), graph)
                
            // create the graph visualization
            if(showVisulalization.conditionalShow(detailedView))
                createVisualization(graph)
        ]
	}
    
	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
	    var retVal = if(showPropertyMap.conditionalShow(detailedView)) 2 else 1
        if(showVisulalization.conditionalShow(detailedView)) retVal = retVal + 1
		return retVal
	}
	
    /**
     * Creates the header node containing basic informations for this element and adds it to the rootNode.
     * 
     * @param rootNode
     *              The KNode the new created KNode will be placed in.
     * @param edge
     *              The IVariable representing the graph transformed in this transformation.
     * 
     * @return The new created header KNode.
     */
 	def addHeaderNode(KNode rootNode, IVariable graph) {
		rootNode.addNodeById(graph) => [
    		data += renderingFactory.createKRectangle => [

                val table = headerNodeBasics(detailedView, graph)
                
                // id of graph
                if(showID.conditionalShow(detailedView)) {
                    table.addGridElement("id:", leftColumnAlignment) 
                    table.addGridElement(graph.nullOrValue("id"), rightColumnAlignment) 
                }
                
                // hashCode of graph
                if(showHashCode.conditionalShow(detailedView)) {
                    table.addGridElement("hashCode:", leftColumnAlignment) 
                    table.addGridElement(graph.nullOrValue("hashCode"), rightColumnAlignment) 
                }
    			
                // hashCodeCounter of graph
                if(showHashCodeCounter.conditionalShow(detailedView)) {
                    table.addGridElement("hashCodeCounter:", leftColumnAlignment) 
                    table.addGridElement(graph.nullOrValue("hashCodeCounter.count"), rightColumnAlignment) 
                }

                // size of graph
                if(showSize.conditionalShow(detailedView)) {
                    table.addGridElement("size (x,y):", leftColumnAlignment) 
                    table.addGridElement(graph.nullOrSize(""), rightColumnAlignment) 
                }
                    
                // insets of graph
                if(showInsets.conditionalShow(detailedView)) {
                    table.addGridElement("insets (t,r,b,l):", leftColumnAlignment) 
                    table.addGridElement(graph.nullOrLInsets("insets"), rightColumnAlignment) 
                }

                // offset of graph
                if(showOffset.conditionalShow(detailedView)) {
                    table.addGridElement("offset (x,y):", leftColumnAlignment) 
                    table.addGridElement(graph.nullOrKVektor("offset"), rightColumnAlignment) 
                }

			    // # of nodes
                if(showNodesCount.conditionalShow(detailedView)) {
                    var count = Integer::parseInt(graph.getValue("layerlessNodes.size"))
                    // sum all nodes in the layers
                    for(layer : graph.getVariable("layers").linkedList) {
                        count = count + Integer::parseInt(layer.getValue("nodes.size"))
                    }
                    table.addGridElement("nodes (#):", leftColumnAlignment) 
                    table.addGridElement("" + count, rightColumnAlignment) 
                }

			    // # of layers
                if(showLayersCount.conditionalShow(detailedView)) {
                    table.addGridElement("layers (#):", leftColumnAlignment) 
                    table.addGridElement(graph.nullOrSize("layers"), rightColumnAlignment) 
                }
            ]
		]
	}

    /**
     * Creates a node containing the visualization of this graph and creates an edge from header node to it.
     * 
     * @param rootNode
     *              The KNode the new created KNode will be placed in.
     * @param edge
     *              The IVariable representing the graph transformed in this transformation.
     * 
     * @return The new created KNode.
     */
	def createVisualization(KNode rootNode, IVariable graph) {
		val visualization = graph.getVariable("layerlessNodes")
		
		// number of nodes in graph
        val tmp = (graph.getVariable("layers.nodes").linkedList
                .map[l|Integer::parseInt(l.getValue("size"))]
                .reduce[a, b | a + b])
        val count = tmp + Integer::parseInt(graph.getValue("layerlessNodes.size"))
        
        // create container node
        val newNode = rootNode.addNodeById(visualization) => [
            val rendering = renderingFactory.createKRectangle => [ rendering |
                data += rendering
                if(detailedView) rendering.lineWidth = 4 else rendering.lineWidth = 2
            ]
            
            if (count == 0) {
                // graph is empty
                rendering.addKText("(none)")
            } else {
                // create all nodes (layerless and layered)
    	  		createNodes(graph.getVariable("layerlessNodes"))
    	  		for (layer : graph.getVariable("layers").linkedList)
    	  		    createNodes(layer.getVariable("nodes"))

                // create all edges
                // first for all layerlessNodes ...
                createEdges(graph.getVariable("layerlessNodes"))
                // ... then iterate through all layers
                graph.getVariable("layers").linkedList.forEach[IVariable layer |
                    createEdges(layer.getVariable("nodes"))   
                ]
            }
  		]
  		
	    // create edge from header node to visualization
        graph.createTopElementEdge(visualization, "visualization")
        
        return newNode
	}

    /**
     * Creates all nodes of this graph and adds them to the rootNode.
     * 
     * @param rootNode
     *              The KNode the new created KNodes will be placed in.
     * @param edge
     *              The IVariable representing the list of nodes to create.
     */
    def void createNodes(KNode rootNode, IVariable nodes) {
	    nodes.linkedList.forEach[IVariable node |
          rootNode.nextTransformation(node, false)
        ]
	}

    /**
     * Creates all edges of this graph.
     * 
     * @param layer
     *              The layer or element layerlessNodes those edges shall be created.
     */
    def void createEdges(IVariable layer) {
        layer.linkedList.forEach[IVariable node |
        	node.getVariable("ports").linkedList.forEach[IVariable port |
        		port.getVariable("outgoingEdges").linkedList.forEach[IVariable edge |
                    edge.getVariable("source.owner")
                        .createEdgeById(edge.getVariable("target.owner")) => [
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
        		]
        	]
        ]
    }
    
    /**
     * Returns the type of edge, or <code>NORMAL</code>, if no type is given in the propertyMap.
     * 
     * @param edge
     *              The edge those type shall be returned.
     * @return The type of the edge.
     * 
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





