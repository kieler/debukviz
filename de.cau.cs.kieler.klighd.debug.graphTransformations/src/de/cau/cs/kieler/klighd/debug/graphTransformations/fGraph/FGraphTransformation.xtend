package de.cau.cs.kieler.klighd.debug.graphTransformations.fGraph

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.KRenderingFactory
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import org.eclipse.debug.core.model.IVariable
import javax.inject.Inject
import de.cau.cs.kieler.core.krendering.LineStyle
import de.cau.cs.kieler.core.properties.IProperty
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.kiml.klayoutdata.impl.KShapeLayoutImpl
import javax.swing.text.Position
import de.cau.cs.kieler.core.kgraph.KLabeledGraphElement
import de.cau.cs.kieler.core.util.Pair
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.klighd.debug.graphTransformations.KTextIterableField

import static de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph.LGraphTransformation.*
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import java.util.LinkedList
import de.cau.cs.kieler.core.krendering.HorizontalAlignment
import de.cau.cs.kieler.core.krendering.VerticalAlignment
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf

class FGraphTransformation extends AbstractKielerGraphTransformation {
    
    @Inject
    extension KNodeExtensions
    @Inject
    extension KEdgeExtensions
    @Inject 
    extension KPolylineExtensions 
    @Inject
    extension KRenderingExtensions
    @Inject
    extension KColorExtensions
    @Inject
    extension KLabelExtensions
    
    val layoutAlgorithm = "de.cau.cs.kieler.klay.layered"
    val spacing = 75f
    val leftColumnAlignment = KTextIterableField$TextAlignment::RIGHT
    val rightColumnAlignment = KTextIterableField$TextAlignment::LEFT
    val topGap = 4
    val rightGap = 7
    val bottomGap = 5
    val leftGap = 4
    val vGap = 3
    val hGap = 5
    val showPropertyMap = ShowTextIf::DETAILED
    val showVisualization = ShowTextIf::DETAILED
    val showAdjacency = ShowTextIf::DETAILED

    
    /**
     * {@inheritDoc}
     */
    override transform(IVariable graph, Object transformationInfo) {
        detailedView = transformationInfo.isDetailed

        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            it.addLayoutParam(LayoutOptions::SPACING, spacing)

			it.addInvisibleRendering
            it.addHeaderNode(graph)
            
            // add propertyMap
            if(showPropertyMap.conditionalShow(detailedView))
                it.addPropertyMapNode(graph.getVariable("propertyMap"), graph)
                
            // create the graph visualization
            if(showVisualization.conditionalShow(detailedView)) {
	            // create all nodes (in a new visualization node)
                val visualizationNode = it.createNodes(graph)
                // create all edges (in the given visualization node) 
                visualizationNode.createEdges(graph)
            }

            // add adjacency matrix
            if(showAdjacency.conditionalShow(detailedView))
                it.addAdjacency(graph)
        ];
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
    
	def void addAdjacency(KNode rootNode, IVariable graph) {
		val adjacencyVariable = graph.getVariable("adjacency")
		val adjacencyData = adjacencyVariable.getValue.getVariables
		val size = adjacencyData.size
		
		rootNode.addNodeById(adjacencyVariable) => [
			it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4

				if (size > 0) {
	            	it.ChildPlacement = renderingFactory.createKGridPlacement => [
	                    it.numColumns = size + 2
	                ]
	                // empty upper left element
					it.children += renderingFactory.createKRectangle => [
		                it.setInvisible(true)
		            ]
	            	it.addGridElement("|", HorizontalAlignment::CENTER)
		            
		            // add top numbers
		            for(Integer i: 0..size - 1){
			            it.addGridElement(i.toString, HorizontalAlignment::CENTER)
	    			}
	    			// add vertical line
		            for(Integer i: 0..size + 1){
		            	it.addGridElement("-", HorizontalAlignment::CENTER)
	    			}
	    			
	    			// add all other rows
		            for (Integer i : 0..size - 1) {
		            	it.addGridElement(i.toString, HorizontalAlignment::CENTER)
		            	it.addGridElement("|", HorizontalAlignment::CENTER)

		            	val row = adjacencyData.get(i).getValue.getVariables
		            	for (elem : row) {
		            		it.addGridElement(elem.getValueString, HorizontalAlignment::CENTER)
		            	}
		            }
				} else {
					it.addGridElement("null", HorizontalAlignment::CENTER)
				}
			]
		]
        graph.createTopElementEdge(adjacencyVariable, "adjacency")
	}
    
    def addHeaderNode(KNode rootNode, IVariable graph) {
        rootNode.addNodeById(graph) => [
            it.data += renderingFactory.createKRectangle => [
    	                	
            	val field = new KTextIterableField(topGap, rightGap, bottomGap, leftGap, vGap, hGap)
                it.headerNodeBasics(field, detailedView, graph, leftColumnAlignment, rightColumnAlignment)
                var row = field.rowCount
                
                if (detailedView) {
                    // noOf labels
                    field.set("labels (#):", row, 0, leftColumnAlignment)
                    field.set(graph.getValue("labels.size"), row, 1, rightColumnAlignment)
                    row = row + 1

                    // noOf bendPpoints
                    field.set("bendPoints (#):", row, 0, leftColumnAlignment)
                    field.set(graph.getValue("bendPoints.size"), row, 1, rightColumnAlignment)
                    row = row + 1

                    // noOf edges
                    field.set("edges (#):", row, 0, leftColumnAlignment)
                    field.set(graph.getValue("edges.size"), row, 1, rightColumnAlignment)
                    row = row + 1

                    // size of adjacency matrix
                    val x = graph.getVariables("adjacency")
                    var y = 0
                    if (x.size > 0) {
                        y = x.get(0).getValue.getVariables.size
                    }
                    field.set("adjacency matrix:", row, 0, leftColumnAlignment)
                    field.set("(" + x.size + " x " + y + ")", row, 1, rightColumnAlignment)
                    row = row + 1
                    
                } else {
                    // noOf nodes
                    field.set("nodes (#):", row, 0, leftColumnAlignment)
                    field.set(graph.getValue("nodes.size"), row, 1, rightColumnAlignment)
                    row = row + 1
                }

				// fill the KText into the ContainerRendering
                for (text : field) {
                    it.children += text
                }
            ]
        ]
    }

    def createNodes(KNode rootNode, IVariable graph) {
        val nodes = graph.getVariable("nodes")

        val newNode = rootNode.addNodeById(nodes) => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
            ]

            // create all nodes
            nodes.linkedList.forEach[IVariable node |
                it.nextTransformation(node, false)
            ]
        ]

        // create edge from header node to visualization
        graph.createTopElementEdge(nodes, "visualization")
        rootNode.children += newNode
        return newNode
    }
    
    /**
     * Creates all edges in a given visualization node. By adding the corresponding value, the adjacency
     * matrix is also displayed
     * 
     * @param rootNode
     *              the visualization node the edges will be inserted into
     * @param graph
     *              the FGraph containing the edges to insert
     */
    def createEdges(KNode rootNode, IVariable graph) {
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
                    // more than one bendpoint: create a node containing bendPoints
                    rootNode.addNodeById(bendPoints)  => [
                        // create container rectangle 
                        it.data += renderingFactory.createKRectangle => [
                            it.lineWidth = 2
                        ]
                        // create all bendPoint nodes in the new bendPoint node
                        bendPoints.linkedList.forEach[IVariable bendPoint |
                            it.nextTransformation(bendPoint, false)
                        ]
                    ]
                    // create the edge from the new created node to the target node
                    bendPoints.createEdgeById(target) => [
                        it.data += renderingFactory.createKPolyline => [
                            it.setLineWidth(2)
                            it.addInheritanceTriangleArrowDecorator
                            it.setLineStyle(LineStyle::SOLID)
                        ]
                    ]
                    // set target for the "default" edge to the new created container node
                    target = bendPoints  
                    
                } else {
                    // EXACTLY one bendpoint, create a single bendpoint node
                    val IVariable bendPoint = bendPoints.linkedList.get(0)
                    rootNode.nextTransformation(bendPoint, false)
                    
                    // create the edge from the new created node to the target node
                    bendPoint.createEdgeById(target) => [
                        it.data += renderingFactory.createKPolyline => [
                            it.setLineWidth(2)
                            it.addArrowDecorator
                            it.setLineStyle(LineStyle::SOLID)
                        ]
                    ]
                    // set target for the "default" edge to the new created node
                    target = bendPoint                        
                }
            }
            // create first edge, from source to target node
            source.createEdgeById(target) => [
                it.data += renderingFactory.createKPolyline => [
                    it.setLineWidth(2)
                    it.addArrowDecorator
                    it.setLineStyle(LineStyle::SOLID)
                ]
                
                // add adjacency label to head of first edge  
                if (!adjacency.nullOrEmpty) {
                    val value = adjacency.get(sourceID).getValue.getVariables
                    it.createLabel => [
                        it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::CENTER)
                        it.setLabelSize(50,20)
                        it.text = ("Adjacency: " + value.get(targetID).getValue.getValueString)
                    ]                    
                }
            ]
        ]
    }
}