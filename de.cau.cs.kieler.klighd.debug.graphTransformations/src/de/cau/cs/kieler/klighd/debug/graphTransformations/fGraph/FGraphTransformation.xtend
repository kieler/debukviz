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
 package de.cau.cs.kieler.klighd.debug.graphTransformations.fGraph

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.HorizontalAlignment
import de.cau.cs.kieler.core.krendering.LineStyle
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.klighd.debug.graphTransformations.KTextIterableField
import de.cau.cs.kieler.klighd.debug.graphTransformations.KTextIterableField$TextAlignment
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

/*
 * Transformation for a IVariable representing a FEdge.
 * This class still uses the deprecated KTextIterableField class.
 * 
 * @ author tit
 */
class FGraphTransformation extends AbstractKielerGraphTransformation {
    
    @Inject
    extension KNodeExtensions
    @Inject 
    extension KPolylineExtensions 
    @Inject
    extension KRenderingExtensions
    
    /** The layout algorithm to use. */
    val layoutAlgorithm = "de.cau.cs.kieler.klay.layered"
    /** The spacing to use. */
    val spacing = 75f
    /** The horizontal alignment for the left column of all KTextIterableFields. */
    val leftColumnAlignment = KTextIterableField$TextAlignment::RIGHT
    /** The horizontal alignment for the right column of all KTextIterableFields. */
    val rightColumnAlignment = KTextIterableField$TextAlignment::LEFT
    /** The top outer gap of the KTextIterableField. */
    val topGap = 4
    /** The right outer gap of the KTextIterableField. */
    val rightGap = 7
    /** The bottom outer gap of the KTextIterableField. */
    val bottomGap = 5
    /** The left outer gap of the KTextIterableField. */
    val leftGap = 4
    /** The vertical inner gap of the KTextIterableField. */
    val vGap = 3
    /** The horizontal inner gap of the KTextIterableField. */
    val hGap = 5

    /** Specifies when to show the property map. */
    val showPropertyMap = ShowTextIf::DETAILED
    /** Specifies when to show the node containing the visualization. */
    val showVisualization = ShowTextIf::DETAILED
    /** Specifies when to show the node containing the adjacency matrix. */
    val showAdjacency = ShowTextIf::DETAILED
    
    val showLabelsCount = ShowTextIf::DETAILED
    val showBendPointsCount = ShowTextIf::DETAILED
    val showEdgesCount = ShowTextIf::ALWAYS
    val showAdjacencySize = ShowTextIf::DETAILED
    val showNodesCount = ShowTextIf::ALWAYS
    
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
            if(showVisualization.conditionalShow(detailedView))
                addVisualization(graph)

            // add adjacency matrix
            if(showAdjacency.conditionalShow(detailedView))
                addAdjacency(graph)
        ]
    }

	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
	    var retVal = if(showPropertyMap.conditionalShow(detailedView)) 2 else 1
	    if(showVisualization.conditionalShow(detailedView)) retVal = retVal + 1
	    if(showAdjacency.conditionalShow(detailedView)) retVal = retVal + 1
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
                            
                val field = new KTextIterableField(topGap, rightGap, bottomGap, leftGap, vGap, hGap)
                headerNodeBasics(field, detailedView, graph, leftColumnAlignment, rightColumnAlignment)
                var row = field.rowCount
                
                // noOf labels
                if(showLabelsCount.conditionalShow(detailedView)) {
                    field.set("labels (#):", row, 0, leftColumnAlignment)
                    field.set(graph.nullOrSize("labels"), row, 1, rightColumnAlignment)
                    row = row + 1
                }

                // noOf bendPpoints
                if(showBendPointsCount.conditionalShow(detailedView)) {
                    field.set("bendPoints (#):", row, 0, leftColumnAlignment)
                    field.set(graph.nullOrSize("bendPoints"), row, 1, rightColumnAlignment)
                    row = row + 1
                }

                // noOf edges
                if(showEdgesCount.conditionalShow(detailedView)) {
                    field.set("edges (#):", row, 0, leftColumnAlignment)
                    field.set(graph.nullOrSize("edges"), row, 1, rightColumnAlignment)
                    row = row + 1
                }

                // size of adjacency matrix
                if(showAdjacencySize.conditionalShow(detailedView)) {
                    val x = graph.getVariables("adjacency")
                    val y = if(x.size > 0) x.get(0).getValue.getVariables.size else 0

                    field.set("adjacency matrix:", row, 0, leftColumnAlignment)
                    field.set("(" + x.size + " x " + y + ")", row, 1, rightColumnAlignment)
                    row = row + 1
                }
                
                // noOf nodes
                if(showNodesCount.conditionalShow(detailedView)) {
                    field.set("nodes (#):", row, 0, leftColumnAlignment)
                    field.set(graph.nullOrSize("nodes"), row, 1, rightColumnAlignment)
                    row = row + 1
                }

                // fill the KText into the ContainerRendering
                for (text : field) {
                    children += text
                }
            ]
        ]
    }

    /**
     * Creates a node containing a visualization of the adjacency matrix and creates an edge from header node to 
     * 
     * @param rootNode
     *              The KNode the new created KNode will be placed in.
     * @param edge
     *              The IVariable representing the graph transformed in this transformation.
     * 
     * @return The new created KNode.
     */
 	def void addAdjacency(KNode rootNode, IVariable graph) {
		val adjacencyVariable = graph.getVariable("adjacency")
		val adjacencyData = adjacencyVariable.getValue.getVariables
		val rowsCount = adjacencyData.size
		val maxCols = adjacencyData.map[s|s.getValue.getVariables.size].reduce[a, b | Math::max(a,b)]
		
		
		rootNode.addNodeById(adjacencyVariable) => [
			data += renderingFactory.createKRectangle => [
                if(detailedView) lineWidth = 4 else lineWidth = 2

				if (rowsCount == 0) {
					addKText("(none)")
				} else {
	            	ChildPlacement = renderingFactory.createKGridPlacement => [
	                    numColumns = maxCols + 2
	                ]
	                // empty upper left element
					it.addInvisibleRendering
					
	            	addGridElement("|", HorizontalAlignment::CENTER)
		            
		            // add top numbers
		            for(Integer i: 1..maxCols)
			            addGridElement(i.toString, HorizontalAlignment::CENTER)

	    			// add vertical line
		            for(Integer i: 1..maxCols + 2)
		            	addGridElement("-", HorizontalAlignment::CENTER)
	    			
	    			// add all other rows
		            for (Integer i : 0..rowsCount - 1) {
		            	addGridElement(i.toString, HorizontalAlignment::CENTER)
		            	addGridElement("|", HorizontalAlignment::CENTER)

		            	val row = adjacencyData.get(i).getValue.getVariables
		            	var elementsInRow = 0 
		            	for (elem : row) {
		            		addGridElement(elem.getValueString, HorizontalAlignment::CENTER)
		            		elementsInRow = elementsInRow + 1
	            		}
	            		// fill the current row, if some of the rows of the adjacency matrix are not
	            		// completely filled (this should never happen, but who knows...
	            		for (Integer j : elementsInRow..maxCols)
                            addBlankGridElement
		            }
				}
			]
		]
        // create edge from header node to adjacency node
        graph.createTopElementEdge(adjacencyVariable, "adjacency")
	}
    

    /**
     * Creates a node containing the visualization of the current FGraph and creates an edge from header node to 
     * 
     * @param rootNode
     *              The KNode the new created KNode will be placed in.
     * @param edge
     *              The IVariable representing the graph transformed in this transformation.
     * 
     * @return The new created KNode.
     */
    def addVisualization(KNode rootNode, IVariable graph) {
        val nodes = graph.getVariable("nodes")

        // create container node
        val newNode = rootNode.addNodeById(nodes) => [
            data += renderingFactory.createKRectangle => [
                if(detailedView) lineWidth = 4 else lineWidth = 2
            ]

            // create all nodes
            nodes.linkedList.forEach[IVariable node |
                nextTransformation(node, false)
            ]

            // create all edges (in the given visualization node) 
            createEdges(graph)
        ]

        // create edge from header node to visualization
        graph.createTopElementEdge(nodes, "visualization")
        
        return newNode
    }
    
    /**
     * Creates all edges in a given visualization node. By adding the corresponding value to the edge, 
     * the adjacency matrix is also displayed.
     * 
     * @param rootNode
     *              the visualization node the edges will be inserted into
     * @param graph
     *              the FGraph containing the edges to insert
     */
    def void createEdges(KNode rootNode, IVariable graph) {
        val adjacency = graph.getVariables("adjacency")
        
        graph.getVariable("edges").linkedList.forEach[IVariable edge |
            
            // IVariables the edge has to connect
            val source = edge.getVariable("source")
            var target = edge.getVariable("target")
            
            // IDs of the Nodes to be connected. Needed for Adjacency
            val sourceID = Integer::parseInt(source.getValue("id"))
            val targetID = Integer::parseInt(target.getValue("id"))
            
            // get the bendPoints assigned to the edge
            val bendPoints = edge.getVariable("bendpoints")
            val bendCount = Integer::parseInt(bendPoints.getValue("size"))

            // create bendPoint nodes
            if(bendCount > 0) {
                if(bendCount > 1) {
                    // more than one bendPoint: create a node containing bendPoints
                    rootNode.addNodeById(bendPoints)  => [
                        // create container rectangle 
                        data += renderingFactory.createKRectangle => [
                            lineWidth = 2
                        ]
                        // create all bendPoint nodes in the new bendPoint node
                        bendPoints.linkedList.forEach[IVariable bendPoint |
                            nextTransformation(bendPoint, false)
                        ]
                    ]
                    // create the edge from the new created node to the target node
                    bendPoints.createEdgeById(target) => [
                        data += renderingFactory.createKPolyline => [
                            setLineWidth(2)
                            addInheritanceTriangleArrowDecorator
                            setLineStyle(LineStyle::SOLID)
                        ]
                    ]
                    // set target for the "default" edge to the new created container node
                    target = bendPoints  
                    
                } else {
                    // EXACTLY one bendPoint, create a single bendPoint node
                    val IVariable bendPoint = bendPoints.linkedList.get(0)
                    rootNode.nextTransformation(bendPoint, false)
                    
                    // create the edge from the new created node to the target node
                    bendPoint.createEdgeById(target) => [
                        data += renderingFactory.createKPolyline => [
                            setLineWidth(2)
                            addArrowDecorator
                            setLineStyle(LineStyle::SOLID)
                        ]
                    ]
                    // set target for the "default" edge to the new created node
                    target = bendPoint                        
                }
            }
            // create first edge, from source to target node
            source.createEdgeById(target) => [
                data += renderingFactory.createKPolyline => [
                    setLineWidth(2)
                    addArrowDecorator
                    setLineStyle(LineStyle::SOLID)
                ]
                
                // add adjacency label to head of first edge  
                if (!adjacency.nullOrEmpty) {
                    val value = adjacency.get(sourceID).getValue.getVariables
                    addLabel(
                        "Adjacency: " + value.get(targetID).getValue.getValueString,
                        EdgeLabelPlacement::CENTER
                    )
                }
            ]
        ]
    }
}