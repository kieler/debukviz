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

import static de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph.LGraphTransformation.*
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions

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
    /**
     * {@inheritDoc}
     */
    override transform(IVariable graph, Object transformationInfo) {
        if(transformationInfo instanceof Boolean) detailedView = transformationInfo as Boolean

        return KimlUtil::createInitializedNode=> [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            
            // create header node
            it.createHeaderNode(graph)
            
            // add the propertyMap and visualization if in detailed mode
            if (detailedView) {
                // add mropertyMap
                it.addPropertyMapAndEdge(graph.getVariable("propertyMap"), graph)
                
                // create all nodes (in a new visualization node)
                val visualizationNode = it.createNodes(graph)
                
                // create all edges (in the given visualization node) 
                visualizationNode.createEdges(graph)
            }
        ]
    }
    
    def createHeaderNode(KNode rootNode, IVariable graph) {
        rootNode.addNodeById(graph) => [
            it.data += renderingFactory.createKRectangle => [
                it.headerNodeBasics(detailedView, graph)

                if (detailedView) {
                    // noOf labels
                    it.children += renderingFactory.createKText => [
                        it.text = "labels (#): " + graph.getValue("labels.size")
                    ]
                    
                    // noOf bendPpoints
                    it.children += renderingFactory.createKText => [
                        it.text = "bendPoints (#): " + graph.getValue("bendPoints.size")
                    ]
    
                    // noOf edges
                    it.children += renderingFactory.createKText => [
                        it.text = "edges (#): " + graph.getValue("edges.size")
                    ]
                    
                    // size of adjacency matrix
                    it.children += renderingFactory.createKText => [
                        val x = graph.getVariables("adjacency")
                        var y = 0
                        if (x.size > 0) {
                            y = x.get(0).getValue.getVariables.size
                        }
                        it.text = "adjacency matrix: " + x.size + " x " + y
                    ]
                } else {
                    // noOf nodes
                    it.children += renderingFactory.createKText => [
                        it.text = "nodes (#): " + graph.getValue("nodes.size")
                    ]
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
        graph.createEdgeById(nodes) => [
            it.data += renderingFactory.createKPolyline => [
                it.setLineWidth(2)
                it.addArrowDecorator
                it.setLineStyle(LineStyle::SOLID)
            ]
            nodes.createLabel(it) => [
                it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::CENTER)
                it.setLabelSize(50,20)
                it.text = "visualization"
            ]
        ]
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
                    val bendPoint = bendPoints.linkedList.get(0)
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
//                // add all labels to tail of first edge  
//                edge.getVariable("labels").linkedList.forEach[IVariable label |
//                    label.createLabel(it) => [
//                        it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::TAIL)
//                        it.setLabelSize(50,20)
//                        it.text = label.getValue("text")
//                    ]                    
//                ]
                
                // add adjacency label to head of first edge  
                if (!adjacency.nullOrEmpty) {
                    val value = adjacency.get(sourceID).getValue.getVariables
                    value.createLabel(it) => [
                        it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::CENTER)
                        it.setLabelSize(50,20)
                        it.text = ("Adjacency: " + value.get(targetID).getValue.getValueString)
                    ]                    
                }
            ]
        ]
    }
}