package de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph

import org.eclipse.debug.core.model.IVariable
import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.LineStyle
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable
import de.cau.cs.kieler.core.krendering.KRendering
import de.cau.cs.kieler.core.krendering.KContainerRendering

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation

class LPortTransformation extends AbstractKielerGraphTransformation {
    
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
    override transform(IVariable port, Object transformationInfo) {
        if(transformationInfo instanceof Boolean) {
            detailedView = transformationInfo as Boolean
        }
println("LPort detailedView: " +detailedView)
//TODO: crash if detailedView is true. "OGDF error: Process terminated with exit value -1073741676."
        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
//            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            
            // create KNode for given LPort
            it.createHeaderNode(port)

            // add nodes for incoming and outgoing edges, propertyMap and list of labels
            if (detailedView) {
                // add propertyMap
                it.addPropertyMapAndEdge(port.getVariable("propertyMap"), port)
                
                // add incoming/outgoing edges node
                it.addListOfEdges(port, port.getVariable("incomingEdges"))
                it.addListOfEdges(port, port.getVariable("outgoingEdges"))
                
                // add labels
                it.addListOfLabels(port)
            }        
        ]
    }
    
    def createHeaderNode(KNode rootNode, IVariable port) { 
        rootNode.addNewNodeById(port) => [
            it.data += renderingFactory.createKRectangle => [
                it.headerNodeBasics(detailedView, port)
                
                // id of port
                it.children += createKText(port, "id", "", ": ")
   
                // hashCode of port
                it.children += createKText(port, "hashCode", "", ": ")
            
                // side of port
                it.children += renderingFactory.createKText => [
                    it.text = "side: " + port.getValue("side.name")
                ]
                
                if(detailedView) {
                    // show following elements only if detailedView
                    // anchor of port
                    it.children += renderingFactory.createKText => [
                        it.text = "anchor (x,y): (" + port.getValue("anchor.x").round(1) + " x " 
                                                    + port.getValue("anchor.y").round(1) + ")" 
                    ]
                    
                    // margin of port
                    it.children += renderingFactory.createKText => [
                        it.text = "margin (t,r,b,l): (" + port.getValue("margin.top").round(1) + " x "
                                                        + port.getValue("margin.right").round(1) + " x "
                                                        + port.getValue("margin.bottom").round(1) + " x "
                                                        + port.getValue("margin.left").round(1) + ")"
                    ]
                    
                    // owner of port
                    it.children += renderingFactory.createKText => [
                        it.text = "owner: LNode " + port.getValue("owner.id") 
                    ]

                    // position of port
                    it.children += renderingFactory.createKText => [
                        it.text = "pos (x,y): (" + port.getValue("pos.x").round(1) + " x "
                                                 + port.getValue("pos.y").round(1) + ")"
                    ]
                    
                    // size of port
                    it.children += renderingFactory.createKText => [
                        it.text = "side: " + port.getValue("side.name") 
                    ]
                    
                    // size of port
                    it.children += renderingFactory.createKText => [
                        it.text = "size (x,y): (" + port.getValue("size.x").round(1) + " x "
                                                  + port.getValue("size.y").round(1) + ")"
                    ]
                } else {
                    // if not detailedView, show a summary of following elements
                    // # of incoming edges of port
                    it.children += renderingFactory.createKText => [
                        it.text = "incomingEdges (#): " + port.getValue("incomingEdges.size")
                    ]

                    // # of outgoing edges of port
                    it.children += renderingFactory.createKText => [
                        it.text = "outgoingEdges (#): " + port.getValue("outgoingEdges.size")
                    ]
                    
                    // # of labels of port
                    it.children += renderingFactory.createKText => [
                        it.text = "labels (#): " + port.getValue("labels.size")
                    ]
                }
            ]
        ]
    }

    def addListOfLabels(KNode rootNode, IVariable port) {
        // create a node (labels) containing the label elements
        val labels = port.getVariable("labels")
        rootNode.addNewNodeById(labels) => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
            ]
            // create all labels
            labels.linkedList.forEach [ label |
                it.nextTransformation(label, false)
            ]
        ]
        // create edge from header node to labels node
        port.createEdgeById(labels) => [
            it.data += renderingFactory.createKPolyline => [
                it.setLineWidth(2)
                it.addArrowDecorator
            ]
            KimlUtil::createInitializedLabel(it) => [
                it.setText("labels")
            ]
        ]   
    }
    
    def addListOfEdges(KNode rootNode, IVariable port, IVariable edges) {
        // create a node (edges) containing the edges elements
        println(edges.getValue.getValueString)
        rootNode.addNewNodeById(edges) => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
            ]
            // create all edges
            edges.linkedList.forEach [ edge |
                it.nextTransformation(edge, false)
            ]
        ]
        // create edge from header node to edges node
        port.createEdgeById(edges) => [
            it.data += renderingFactory.createKPolyline => [
                it.setLineWidth(2)
                it.addArrowDecorator
            ]
            KimlUtil::createInitializedLabel(it) => [
                it.setText(edges.getValue.getValueString)
            ]
        ]   
    }
}