package de.cau.cs.kieler.klighd.debug.graphTransformations.pGraph

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
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKNodeTransformation
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions


class PGraphTransformation extends AbstractKNodeTransformation {
    
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
            it.createNodes(graph.getVariableByName("nodes"))
            it.createEdges(graph.getVariableByName("edges", "java.util.LinkedHashSet<de.cau.cs.kieler.klay.planar.graph.PEdge>"))
        ]

    }
    
    def createHeaderNode(KNode rootNode, IVariable graph) {
        rootNode.children += graph.createNode => [
//          it.setNodeSize(120,80)
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
                it.ChildPlacement = renderingFactory.createKGridPlacement

                it.children += renderingFactory.createKText => [
                    it.setForegroundColor(120,120,120)
                    it.text = graph.ShortType
                ]
                
                it.children += renderingFactory.createKText => [
                    it.text = "VarName: " + graph.name 
                ]

                it.children += createKText(graph, "faceIndex", "", ": ")
                it.children += createKText(graph, "changedFaces", "", ": ")
                it.children += createKText(graph, "externalFace", "", ": ")
                
                it.children += createKText(graph, "edgeIndex", "", ": ")
                it.children += createKText(graph, "nodeIndex", "", ": ")
                it.children += createKText(graph, "parent", "", ": ")
                it.children += createKText(graph, "parent", "", ": ")

                it.children += renderingFactory.createKText => [
                    it.text = "pos (x,y): (" + graph.getValueByName("pos.x").round(1) + " x " 
                                              + graph.getValueByName("pos.y").round(1) + ")" 
                ]
                
                it.children += renderingFactory.createKText => [
                    it.text = "size (x,y): (" + graph.getValueByName("size.x").round(1) + " x " 
                                              + graph.getValueByName("size.y").round(1) + ")" 
                ]

                it.children += renderingFactory.createKText => [
                    it.text = "type: " + graph.getValueByName("type.name")
                ]
            ]
        ]
    }

    def createNodes(KNode rootNode, IVariable nodesHashSet) {
        nodesHashSet.getVariableByName("map").getVariablesByName("table").filter[e | e.valueIsNotNull].forEach[IVariable node |
            rootNode.nextTransformation(node.getVariableByName("key"))
        ]
    }

    def createEdges(KNode rootNode, IVariable edgesHashSet) {
        edgesHashSet.getVariableByName("map").getVariablesByName("table").filter[e | e.valueIsNotNull].forEach[IVariable edge |
            edge.getVariableByName("key.source")
                .createEdge(edge.getVariableByName("key.target")) => [
                it.data += renderingFactory.createKPolyline => [
                    it.setLineWidth(2)
                    it.addArrowDecorator
                    it.setLineStyle(LineStyle::SOLID)
                ]
            ]
        ]
    }
}