package de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph

import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import org.eclipse.debug.core.model.IVariable
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

class LEdgeTransformation extends AbstractKielerGraphTransformation {
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
    
    override transform(IVariable edge, Object transformationInfo) {
        if(transformationInfo instanceof Boolean) {
            detailedView = transformationInfo as Boolean
        }
println("LEdge detailedView: " +detailedView)
//        detailedView = false
//TODO: crash if dedailedView: "OGDF error: Process terminated with exit value -1073741676."
println("LEdge transInfo: " + transformationInfo)
        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            
            // create KNode for given LEdge
            it.createHeaderNode(edge)
println("LEdge: headerDone")
            // add node for propertyMap and labels
            if (detailedView) {
                // add propertyMap
                it.addPropertyMapAndEdge(edge.getVariable("propertyMap"), edge)
                
                // add labels node
                val labels = edge.getVariable("labels")
                if (labels.getValue("size").equals("0")) {
                    it.createLabels(labels)
                    edge.createEdgeById(labels) => [
                        it.data += renderingFactory.createKPolyline => [
                            it.setLineWidth(2)
                            it.addArrowDecorator
                        ]
                    ]
                }
            }
println("LEdge: all done")
        ]
    }
    
    def createHeaderNode(KNode rootNode, IVariable edge) { 
        rootNode.addNewNodeById(edge) => [
            it.data += renderingFactory.createKRectangle => [
                it.headerNodeBasics(detailedView, edge)
                
                // id of edge
                it.children += createKText(edge, "id", "", ": ")

                // hashCode of edge
                it.children += createKText(edge, "hashCode", "", ": ")
   
                if(detailedView) {
                    // show following elements only if detailedView
                    // source of edge
                    it.children += renderingFactory.createKText => [
                        it.text = "source: LNode " + edge.getValue("source.id") 
                    ]

                    // target of edge
                    it.children += renderingFactory.createKText => [
                        it.text = "source: LNode " + edge.getValue("target.id") 
                    ]
                    
                    // list of bendPoints
                    if (edge.getValue("bendPoints.size") == "0") {
                        // no bendPoints on edge
                        it.children += renderingFactory.createKText => [
                            it.text = "bendPoints: none"
                        ]
                    } else {
                        it.children += renderingFactory.createKText => [
                            it.text = "bendPoints (x,y):"
                        ]
                        // create list of bendPoints
                        edge.getVariable("bendPoints").linkedList.forEach [ bendPoint |
                            it.children += renderingFactory.createKText => [
                            it.text = bendPoint.getValue("x").round(1) + " x "
                                    + bendPoint.getValue("y").round(1) + ")"
                            ]
                        ]
                    }
                } else {
                    // if not detailedView, show a summary of following elements
                    // # of bendPoints
                    it.children += renderingFactory.createKText => [
                        it.text = "bendPoints (#): " + edge.getValue("bendPoints.size")
                    ]
                    
                    // # of labels of port
                    it.children += renderingFactory.createKText => [
                        it.text = "labels (#): " + edge.getValue("labels.size")
                    ]
                }
            ]
        ]
    }

    def createLabels(KNode rootNode, IVariable labels) { 
        rootNode.addNewNodeById(labels) => [
            // create container node
            it.data += renderingFactory.createKRectangle => [
                if(detailedView) it.lineWidth = 4 else it.lineWidth = 2
                it.ChildPlacement = renderingFactory.createKGridPlacement
                
                // create nodes for labels
                labels.linkedList.forEach [ label |
                    rootNode.nextTransformation(label, false)
                ]
            ]
        ]
    }
}