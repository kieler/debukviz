package de.cau.cs.kieler.klighd.debug.graphTransformations.pGraph

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
import de.cau.cs.kieler.klighd.debug.graphTransformations.KTextIterableField

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf

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
    val showPropertyMap = ShowTextIf::DETAILED
    val showLabels = ShowTextIf::DETAILED
    
    /**
     * {@inheritDoc}
     */    
    override transform(IVariable edge, Object transformationInfo) {
        detailedView = transformationInfo.isDetailed

        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            it.addLayoutParam(LayoutOptions::SPACING, spacing)

            // create a rendering to the outer node, as the node will be black, otherwise            
            it.data += renderingFactory.createKRectangle => [
                it.invisible = true
            ]
            
            // create KNode for given LEdge
            it.createHeaderNode(edge)

            // add propertyMap
            if(detailedView.conditionalShow(showPropertyMap))
                it.addPropertyMapAndEdge(edge.getVariable("propertyMap"), edge)
                
            // add labels node
            if(detailedView.conditionalShow(showLabels))
                it.addLabels(edge)
        ]
    }
    
	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
	    var retVal = if(detailedView.conditionalShow(showPropertyMap)) 2 else 1
	    if(detailedView.conditionalShow(showLabels)) retVal = retVal +1
		return retVal
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
                    it.text = "labels"
                ]
            ]
        }        
    }

    
    def createHeaderNode(KNode rootNode, IVariable edge) { 
        rootNode.addNodeById(edge) => [
            it.data += renderingFactory.createKRectangle => [
                
                val field = new KTextIterableField(topGap, rightGap, bottomGap, leftGap, vGap, hGap)
                it.headerNodeBasics(field, detailedView, edge, leftColumnAlignment, rightColumnAlignment)
                var row = field.rowCount
                
                // id of edge
                field.set("id:", row, 0, leftColumnAlignment)
                field.set(nullOrValue(edge, "id"), row, 1, rightColumnAlignment)
                row = row + 1

                // hashCode of edge
                field.set("hashCode:", row, 0, leftColumnAlignment)
                field.set(nullOrValue(edge, "hashCode"), row, 1, rightColumnAlignment)
                row = row + 1
   
                if(detailedView) {
                    // show following elements only if detailedView
                    // source of edge
                    // source of edge
                    field.set("source:", row, 0, leftColumnAlignment)
                    field.set("LNode " + edge.getValue("source.id") + " " 
                                       + edge.getVariable("source").getValueString, row, 1, rightColumnAlignment)
                    row = row + 1

                    // target of edge
                    field.set("target:", row, 0, leftColumnAlignment)
                    field.set("LNode " + edge.getValue("target.id") + " " 
                                       + edge.getVariable("target").getValueString, row, 1, rightColumnAlignment)
                    row = row + 1

                    // list of bendPoints
                    if (edge.getValue("bendPoints.size").equals("0")) {
                        // no bendPoints on edge
                        field.set("bendPoints:", row, 0, leftColumnAlignment)
                        field.set("none", row, 1, rightColumnAlignment)
                        row = row + 1
                    } else {
                        field.set("bendPoints (x,y):", row, 0, leftColumnAlignment)
                        // create list of bendPoints
                        for (bendPoint : edge.getVariable("bendPoints").linkedList) {
                            field.set("("+ bendPoint.getValue("x").round + ", "
                                         + bendPoint.getValue("y").round + ")", row, 1, rightColumnAlignment)
                            row = row + 1
                        }
                    }
                } else {
                    // if not detailedView, show a summary of following elements
                    // # of bendPoints
                        field.set("bendPoints (#):", row, 0, leftColumnAlignment)
                        field.set(edge.getValue("bendPoints.size"), row, 1, rightColumnAlignment)
                    
                    // # of labels of port
                        field.set("labels (#):", row, 0, leftColumnAlignment)
                        field.set(edge.getValue("labels.size"), row, 1, rightColumnAlignment)
                }

                // fill the KText into the ContainerRendering
                for (text : field) {
                    it.children += text
                }
            ]
        ]
    }
}