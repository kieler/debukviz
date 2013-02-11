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
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf
import de.cau.cs.kieler.core.krendering.HorizontalAlignment

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
    val leftColumnAlignment = HorizontalAlignment::RIGHT
    val rightColumnAlignment = HorizontalAlignment::LEFT

    val showPropertyMap = ShowTextIf::DETAILED
    val showEdgesNode = ShowTextIf::DETAILED
    val showLabelsNode = ShowTextIf::DETAILED

    val showEdgesCount = ShowTextIf::COMPACT
    val showLabelsCount = ShowTextIf::COMPACT
    val showSize = ShowTextIf::DETAILED
    val showSide = ShowTextIf::ALWAYS
    val showPosition = ShowTextIf::DETAILED
    val showOwner = ShowTextIf::DETAILED
    val showMargin = ShowTextIf::DETAILED
    val showAncor = ShowTextIf::DETAILED
    val showHashCode = ShowTextIf::DETAILED
    
    /**
     * {@inheritDoc}
     */
    override transform(IVariable port, Object transformationInfo) {
        detailedView = transformationInfo.isDetailed

        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            it.addLayoutParam(LayoutOptions::SPACING, spacing)

			it.addInvisibleRendering
            it.addHeaderNode(port)

            // add propertyMap
            if(showPropertyMap.conditionalShow(detailedView))
                it.addPropertyMapNode(port.getVariable("propertyMap"), port)
                
            // add incoming/outgoing edges node
            if(showEdgesNode.conditionalShow(detailedView)) {
                it.addListOfEdges(port, port.getVariable("incomingEdges"))
                it.addListOfEdges(port, port.getVariable("outgoingEdges"))
            }
                
            // add labels
            if(showLabelsNode.conditionalShow(detailedView))
                it.addListOfLabels(port)
        ]
    }
    
	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
	    var retVal = if(showPropertyMap.conditionalShow(detailedView)) 2 else 1
	    if(showEdgesNode.conditionalShow(detailedView)) retVal = retVal + 1
		if(showLabelsNode.conditionalShow(detailedView)) retVal = retVal + 1
	    return retVal
	}

    def addHeaderNode(KNode rootNode, IVariable port) { 
        rootNode.addNodeById(port) => [
            it.data += renderingFactory.createKRectangle => [

                val table = it.headerNodeBasics(detailedView, port)

                // id of node
                table.addGridElement("id:", leftColumnAlignment)
                if(detailedView) {
                    table.addGridElement(port.nullOrValue("id"), rightColumnAlignment)
                } else {
                    table.addGridElement(port.nullOrValue("id") + port.getValueString, rightColumnAlignment)
                }
   
                // hashCode of port
                if(showHashCode.conditionalShow(detailedView)) {
                    table.addGridElement("hashCode:", leftColumnAlignment)
                    table.addGridElement(port.nullOrValue("hashCode"), rightColumnAlignment)
                }
            
                // anchor of port
                if(showAncor.conditionalShow(detailedView)) {
                    table.addGridElement("anchor (x,y):", leftColumnAlignment)
                    table.addGridElement(port.nullOrKVektor("anchor"), rightColumnAlignment)
                }

                // margin of port
                if(showMargin.conditionalShow(detailedView)) {
                    table.addGridElement("margin (t,r,b,l):", leftColumnAlignment)
                    table.addGridElement(port.nullOrTRBL("margin"), rightColumnAlignment)
                }

                // owner of port
                if(showOwner.conditionalShow(detailedView)) {
                    table.addGridElement("owner:", leftColumnAlignment)
                    table.addGridElement(port.nullOrTypeAndID("owner"), rightColumnAlignment)
                }
/*                    
                    field.set("owner:", row, 0, leftColumnAlignment)
                    field.set("LNode " + port.getValue("owner.id") + port.getValue("owner"), row, 1, rightColumnAlignment)
                    row = row + 1
 */
                // position of port
                if(showPosition.conditionalShow(detailedView)) {
                    table.addGridElement("pos (x,y):", leftColumnAlignment)
                    table.addGridElement(port.nullOrKVektor("pos"), rightColumnAlignment)
                }
                
                // side of port
                if(showSide.conditionalShow(detailedView)) {
                    table.addGridElement("side:", leftColumnAlignment)
                    table.addGridElement(port.nullOrName("side"), rightColumnAlignment)
                }

                // size of port
                if(showSize.conditionalShow(detailedView)) {
                    table.addGridElement("size (x,y):", leftColumnAlignment)
                    table.addGridElement(port.nullOrKVektor("size"), rightColumnAlignment)
                }

                // # of incoming/outgoing edges of port
                if(showEdgesCount.conditionalShow(detailedView)) {
                    table.addGridElement("incomingEdges (#):", leftColumnAlignment)
                    table.addGridElement(port.nullOrSize("incomingEdges"), rightColumnAlignment)
                    table.addGridElement("outgoingEdges (#):", leftColumnAlignment)
                    table.addGridElement(port.nullOrSize("outgoingEdges"), rightColumnAlignment)
                }

                // # of labels of port
                if(showLabelsCount.conditionalShow(detailedView)) {
                    table.addGridElement("labels (#):", leftColumnAlignment)
                    table.addGridElement(port.nullOrSize("labels"), rightColumnAlignment)
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