package de.cau.cs.kieler.klighd.debug.graphTransformations.fGraph

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*


class FEdgeTransformation extends AbstractKielerGraphTransformation {
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
    
    override transform(IVariable edge, Object transformationInfo) {
        if(transformationInfo instanceof Boolean) detailedView = transformationInfo as Boolean

        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            
            // create KNode for given FEdge
            it.createHeaderNode(edge)

            // if in detailedView, add node for propertyMap and labels
            if (detailedView) {
                
                // add propertyMap
                it.addPropertyMapAndEdge(edge.getVariable("propertyMap"), edge)
                
                // add labels node
                it.addLabels(edge)
                
                // add bendpoints node
                it.addBendPoints(edge)

            }
        ]
    }
    
    def createHeaderNode(KNode rootNode, IVariable edge) { 
        rootNode.addNodeById(edge) => [
            it.data += renderingFactory.createKRectangle => [
                it.headerNodeBasics(detailedView, edge)
                
                if(detailedView) {
                    // show following elements only if detailedView
                    // source of edge
                    it.children += renderingFactory.createKText => [
                        it.text = "source: FNode " + edge.getValue("source.id") + " " + edge.getVariable("source").debugID
                    ]

                    // target of edge
                    it.children += renderingFactory.createKText => [
                        it.text = "source: FNode " + edge.getValue("target.id") + " " + edge.getVariable("target").debugID
                    ]
                    
                } else {
                    // if not detailedView, show a summary of following elements
                    // # of bendPoints
                    it.children += renderingFactory.createKText => [
                        it.text = "bendPoints (#): " + edge.getValue("bendpoints.size")
                    ]
                    
                    // # of labels of port
                    it.children += renderingFactory.createKText => [
                        it.text = "labels (#): " + edge.getValue("labels.size")
                    ]
                }
            ]
        ]
    }
    
    def addLabels(KNode rootNode, IVariable edge) {
        val labels = edge.getVariable("labels")
        
        if (!labels.getValue("size").equals("0")) {
 
            // create container node
            rootNode.addNodeById(labels) => [
                it.data += renderingFactory.createKRectangle => [
                    if(detailedView) it.lineWidth = 4 else it.lineWidth = 2
                    it.ChildPlacement = renderingFactory.createKGridPlacement
                ]
                    
                // create all nodes for labels
                labels.linkedList.forEach [ label |
                    it.nextTransformation(label, false)
                ]
            ]
            
            // create edge from header node to labels node
            edge.createEdgeById(labels) => [
                it.data += renderingFactory.createKPolyline => [
                    it.setLineWidth(2)
                    it.addArrowDecorator
                ]
                labels.createLabel(it) => [
                    it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::CENTER)
                    it.setLabelSize(50,20)
                    it.text = "labels"
                ]
            ]
        }        
    }

    def addBendPoints(KNode rootNode, IVariable edge) {
        val bendPoints = edge.getVariable("bendpoints")
        
        if (!bendPoints.getValue("size").equals("0")) {
            
            // create container node
            rootNode.addNodeById(bendPoints) => [
                it.data += renderingFactory.createKRectangle => [
                    if(detailedView) it.lineWidth = 4 else it.lineWidth = 2
                    it.ChildPlacement = renderingFactory.createKGridPlacement
                ]
                    
                // create all nodes for bendPoints
                bendPoints.linkedList.forEach [ bendPoint |
                    it.nextTransformation(bendPoint, false)
                ]
            ]
            
            // create edge from header node to labels node
            edge.createEdgeById(bendPoints) => [
                it.data += renderingFactory.createKPolyline => [
                    it.setLineWidth(2)
                    it.addArrowDecorator
                ]
                labels.createLabel(it) => [
                    it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::CENTER)
                    it.setLabelSize(50,20)
                    it.text = "bendpoints"
                ]
            ]
        } 
    }


}