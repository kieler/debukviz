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

import static de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph.LGraphTransformation.*
import javax.inject.Inject
import de.cau.cs.kieler.core.krendering.LineStyle
import de.cau.cs.kieler.core.properties.IProperty
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKNodeTransformation
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.kiml.klayoutdata.impl.KShapeLayoutImpl
import javax.swing.text.Position
import de.cau.cs.kieler.core.kgraph.KLabeledGraphElement
import de.cau.cs.kieler.core.util.Pair

class FGraphTransformation extends AbstractKNodeTransformation {
    
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
    
    /**
     * {@inheritDoc}
     */
    override transform(IVariable graph) {
        return KimlUtil::createInitializedNode=> [
//            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.graphviz.dot")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            
            it.createHeaderNode(graph)
            val graphNode = it.createNodes(graph)
            graphNode.createEdges(graph.getVariable("edges"), graph.getVariable("adjacency"))
//            graphNode.createAdjacency(graph)
        ]

    }
    
    def createHeaderNode(KNode rootNode, IVariable graph) {
        rootNode.children += graph.createNode => [
//          it.setNodeSize(120,80)
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
                it.backgroundColor = "lemon".color
                it.ChildPlacement = renderingFactory.createKGridPlacement()

                // Type of graph
                it.children += renderingFactory.createKText => [
                    it.setForegroundColor(120,120,120)
                    it.text = graph.ShortType
                ]

                // name of variable
                it.children += renderingFactory.createKText => [
                    it.text = "VarName: " + graph.name 
                ]
                
                // noOf bendpoints
                it.children += renderingFactory.createKText => [
                    it.text = "BendPoints (#): " + graph.getValue("bendPoints.size")
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
            ]
        ]
    }

    def createNodes(KNode rootNode, IVariable graph) {
        val nodes = graph.getVariable("nodes")

        // create outer nodes rectangle
        val KNode newNode = nodes.createNode => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
            ]
            it.addLabel("Graph visualization")
            nodes.linkedList.forEach[IVariable node |
            	setTransformationInfo()
                it.nextTransformation(node)
            ]
        ]
        // create edge from root node to the nodes node
        graph.createEdge(nodes) => [
            it.data += renderingFactory.createKPolyline => [
                it.setLineWidth(2)
                it.addArrowDecorator
                it.setLineStyle(LineStyle::SOLID)
            ]
        ]
        rootNode.children += newNode
        return newNode
    }
    
    def createAdjacency(KNode rootNode, IVariable graph){
        val adjacency = graph.getVariable("adjacency")
        rootNode.children += adjacency.createNode => [
            // TODO: create an adjacency matrix
            it.setNodeSize(20,20)
            it.data += renderingFactory.createKRectangle() => [
                it.lineWidth = 4
            ]
        ]
        graph.createEdge(adjacency) => [
            it.data += renderingFactory.createKPolyline => [
                it.setLineWidth(2)
                it.addArrowDecorator
                it.setLineStyle(LineStyle::SOLID)
            ]
            KimlUtil::createInitializedLabel(it) => [
                it.setText("adjacency")
            ]
        ]
    } 
    
    def createEdges(KNode rootNode, IVariable edgesLinkedList, IVariable adjacency) {
        edgesLinkedList.linkedList.forEach[IVariable edge |
            val bendPoints = edge.getVariable("bendpoints")
            val bendCount = Integer::parseInt(bendPoints.getValue("size"))
            
            val source = edge.getVariable("source")
            var target = edge.getVariable("target")
            val sourceID = Integer::parseInt(source.getValue("id"))
            val targetID = Integer::parseInt(target.getValue("id"))
            
            // create bendPoint nodes
            if(bendCount > 0) {
                if(bendCount > 1) {
                    // more than one bendpoint: create a node containing bendpoints
                    rootNode.children += bendPoints.createNode => [
                        // create container node 
                        it.data += renderingFactory.createKRectangle() => [
                            it.lineWidth = 4
                        ]
                        // create all bendPoint nodes
                        bendPoints.linkedList.forEach[IVariable bendPoint |
                            it.nextTransformation(bendPoint)
                        ]
                    ]
                    // create the edge from the new created node to the target node
                        bendPoints.createEdge(target) => [
                            it.data += renderingFactory.createKPolyline => [
                                it.setLineWidth(2)
                                it.addInheritanceTriangleArrowDecorator
                                it.setLineStyle(LineStyle::SOLID)
                            ];
                        ]
                        // set target for the "default" edge to the new created node
                        target = bendPoints  
                    
                } else {
                    // exactly one bendpoint, create a single bendpoint node
                    val bendPoint = bendPoints.linkedList.get(0)
                    rootNode.nextTransformation(bendPoint)
                    // create the edge from the new created node to the target node
                    bendPoint.createEdge(target) => [
                        it.data += renderingFactory.createKPolyline => [
                            it.setLineWidth(2)
                            it.addInheritanceTriangleArrowDecorator
                            it.setLineStyle(LineStyle::SOLID)
                        ]
                    ]
                    // set target for the "default" edge to the new created node
                    target = bendPoint                        
                }
            }
            // create first edge, either from source to new or target node
            source.createEdge(target) => [
                it.data += renderingFactory.createKPolyline => [
                    it.setLineWidth(2)
                    it.addArrowDecorator
                    it.setLineStyle(LineStyle::SOLID)
                ]
                // add labels 
                edge.getVariables("labels").forEach[IVariable label |
                    it.addLabel(label.getValue("text"))
                ]
                // add label with adjacency value
                it.addLabel("Adjacency: " + 
                    adjacency.getValue.getVariables.get(sourceID).getValue.getVariables.get(targetID)
                )
            ]
        ]
    }
}