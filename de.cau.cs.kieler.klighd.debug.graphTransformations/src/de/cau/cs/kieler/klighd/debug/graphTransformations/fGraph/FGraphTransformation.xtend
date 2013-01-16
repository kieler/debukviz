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
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            
            it.createHeaderNode(graph)
            it.createBendPoints(graph)
            it.createAdjacency(graph)
            it.createNodes(graph)
            it.createEdges(graph.getVariableByName("edges"))
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

                // adjacency matrix
                it.children += renderingFactory.createKText => [
                    //TODO: create link (or representation) for adjacency matrix
                    it.text = "adjacency matrix: to be considered" 
                ]
            ]
        ]
    }

    def createNodes(KNode rootNode, IVariable graph) {
        val nodes = graph.getVariableByName("nodes")

        rootNode.children += nodes.createNode => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
            ]
            nodes.linkedList.forEach[IVariable node |
            	setTransformationInfo()
                it.nextTransformation(node)
            ]
        ]
        graph.createEdge(nodes) => [
            it.data += renderingFactory.createKPolyline => [
                it.setLineWidth(2)
                it.addArrowDecorator
                it.setLineStyle(LineStyle::SOLID)
            ]
            KimlUtil::createInitializedLabel(it) => [
                it.setText("Nodes")
            ]
        ]
    }
    
    def createBendPoints(KNode rootNode, IVariable graph) {
        val bendPoints = graph.getVariableByName("bendPoints")
        rootNode.children += bendPoints.createNode => [
                it.data += renderingFactory.createKRectangle() => [
                    it.lineWidth = 4
                ]
                if (Integer::parseInt(bendPoints.getValueByName("size")) > 0) {
                    // render the bendpoints
                    bendPoints.linkedList.forEach[IVariable bendPoint |
                        it.nextTransformation(bendPoint)
                    ]
                } else {
                    // no Bendpoints, so give a minimal, static size to the node
                    it.setNodeSize(20,20)
                }
        ]
        var edge = graph.createEdge(bendPoints) => [
            it.data += renderingFactory.createKPolyline => [
                it.setLineWidth(2)
                it.addArrowDecorator
                it.setLineStyle(LineStyle::SOLID)
            ]
        ]
        KimlUtil::createInitializedLabel(edge) => [
            it.setText("bendPoints")
        ]
    }

    def createAdjacency(KNode rootNode, IVariable graph){
        val adjacency = graph.getVariableByName("adjacency")
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
    
    def createEdges(KNode rootNode, IVariable edgesLinkedList) {
        edgesLinkedList.linkedList.forEach[IVariable edge |
            edge.getVariableByName("source").createEdge(edge.getVariableByName("target")) => [
                it.data += renderingFactory.createKPolyline => [
                    it.setLineWidth(2)
                    it.addArrowDecorator
                    it.setLineStyle(LineStyle::SOLID)
                ]
            ]
        ]
    }
}