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
import de.cau.cs.kieler.core.krendering.KRendering
import de.cau.cs.kieler.core.krendering.KContainerRendering
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.klighd.debug.graphTransformations.KTextIterableField

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
    @Inject
    extension KLabelExtensions
    
    val layoutAlgorithm = "de.cau.cs.kieler.kiml.ogdf.planarization"
    val spacing = 75f
    val leftColumnAlignment = KTextIterableField$TextAlignment::RIGHT
    val rightColumnAlignment = KTextIterableField$TextAlignment::LEFT
    val topGap = 4
    val rightGap = 5
    val bottomGap = 5
    val leftGap = 4
    val vGap = 3
    val hGap = 5
    
    /**
     * {@inheritDoc}
     */
    override transform(IVariable port, Object transformationInfo) {
        if(transformationInfo instanceof Boolean) detailedView = transformationInfo as Boolean

        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            it.addLayoutParam(LayoutOptions::SPACING, spacing)
            
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
    
	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
		return 0
	}

    def createHeaderNode(KNode rootNode, IVariable port) { 
        rootNode.addNodeById(port) => [
            it.data += renderingFactory.createKRectangle => [

                var field = new KTextIterableField(topGap, rightGap, bottomGap, leftGap, vGap, hGap)
                it.headerNodeBasics(field, detailedView, port, leftColumnAlignment, rightColumnAlignment)
                var row = field.rowCount
                
                // id of port
                field.set("id:", row, 0, leftColumnAlignment)
                field.set(nullOrValue(port, "id"), row, 1, rightColumnAlignment)
                row = row + 1
   
                // hashCode of port
                field.set("hashCode:", row, 0, leftColumnAlignment)
                field.set(nullOrValue(port, "hashCode"), row, 1, rightColumnAlignment)
                row = row + 1
            
                // side of port
                field.set("side:", row, 0, leftColumnAlignment)
                field.set(port.getValue("side.name"), row, 1, rightColumnAlignment)
                row = row + 1

                if(detailedView) {
                    // show following elements only if detailedView
                    // anchor of port
                    field.set("anchor (x,y):", row, 0, leftColumnAlignment)
                    field.set("(" + port.getValue("anchor.x").round + " x " 
                                  + port.getValue("anchor.y").round + ")", row, 1, rightColumnAlignment)
                    row = row + 1
                    
                    // margin of port
                    field.set("margin (t,r,b,l):", row, 0, leftColumnAlignment)
                    field.set("(" + port.getValue("margin.top").round + " x "
                                  + port.getValue("margin.right").round + " x "
                                  + port.getValue("margin.bottom").round + " x "
                                  + port.getValue("margin.left").round + ")", row, 1, rightColumnAlignment)
                    row = row + 1

                    // owner of port
                    field.set("owner:", row, 0, leftColumnAlignment)
                    field.set("LNode " + port.getValue("owner.id") , row, 1, rightColumnAlignment)
                    row = row + 1

                    // position of port
                    field.set("pos (x,y):", row, 0, leftColumnAlignment)
                    field.set("(" + port.getValue("pos.x").round + " x "
                                  + port.getValue("pos.y").round + ")", row, 1, rightColumnAlignment)
                    row = row + 1
                    
                    // side of port
                    field.set("side:", row, 0, leftColumnAlignment)
                    field.set(port.getValue("side.name"), row, 1, rightColumnAlignment)
                    row = row + 1
                    
                    // size of port
                    field.set("size (x,y):", row, 0, leftColumnAlignment)
                    field.set("(" + port.getValue("size.x").round + " x "
                                  + port.getValue("size.y").round + ")", row, 1, rightColumnAlignment)
                    row = row + 1
                } else {
                    // if not detailedView, show a summary of following elements
                    // # of incoming edges of port
                    field.set("incomingEdges (#):", row, 0, leftColumnAlignment)
                    field.set(port.getValue("incomingEdges.size"), row, 1, rightColumnAlignment)
                    row = row + 1

                    // # of outgoing edges of port
                    field.set("outgoingEdges (#):", row, 0, leftColumnAlignment)
                    field.set(port.getValue("outgoingEdges.size"), row, 1, rightColumnAlignment)
                    row = row + 1

                    // # of labels of port
                    field.set("labels (#):", row, 0, leftColumnAlignment)
                    field.set(port.getValue("labels.size"), row, 1, rightColumnAlignment)
                    row = row + 1
                }

                // fill the KText into the ContainerRendering
                for (text : field) {
                    it.children += text
                }
            ]
        ]
    }

    def addListOfLabels(KNode rootNode, IVariable port) {
        // create a node (labels) containing the label elements
        val labels = port.getVariable("labels")
        if (!labels.getValue("size").equals("0")) {
            rootNode.addNodeById(labels) => [
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
                // add label
                labels.createLabel(it) => [
                    it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::CENTER)
                    it.setLabelSize(50,20)
                    it.text = "labels"
                ]
            ]               
        }
    }
    
    def addListOfEdges(KNode rootNode, IVariable port, IVariable edges) {
        // create a node (edges) containing the edges elements
        if (!edges.getValue("size").equals("0")) {
            rootNode.addNodeById(edges) => [
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
                // add label
                edges.createLabel(it) => [
                    it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::CENTER)
                    it.setLabelSize(50,20)
                    it.text = edges.name
                ]
            ]   
        }    
    }
}