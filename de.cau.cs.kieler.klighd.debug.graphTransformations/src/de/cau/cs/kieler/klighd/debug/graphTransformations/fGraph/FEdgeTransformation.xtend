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
import de.cau.cs.kieler.klighd.debug.graphTransformations.KTextIterableField
import de.cau.cs.kieler.core.krendering.HorizontalAlignment

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf


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
    val showLabelsMap = ShowTextIf::DETAILED
    val showBendPointsMap = ShowTextIf::DETAILED
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
            
            // create KNode for given FEdge
            it.createHeaderNode(edge)

            // add propertyMap
            if(detailedView.conditionalShow(showPropertyMap))
                it.addPropertyMapAndEdge(edge.getVariable("propertyMap"), edge)
                
            // add labels node
            if(detailedView.conditionalShow(showLabelsMap))
                it.addLabels(edge)
                
            // add bendpoints node
            if(detailedView.conditionalShow(showBendPointsMap))
                it.addBendPoints(edge)
        ]
    }
    
	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
	    var retVal = if(detailedView.conditionalShow(showPropertyMap)) 1 else 0
        if(detailedView.conditionalShow(showLabelsMap)) retVal = retVal +1
        if(detailedView.conditionalShow(showBendPointsMap)) retVal = retVal + 1
		return retVal
	}

    def createHeaderNode(KNode rootNode, IVariable edge) { 
        rootNode.addNodeById(edge) => [
            it.data += renderingFactory.createKRectangle => [

                val field = new KTextIterableField(topGap, rightGap, bottomGap, leftGap, vGap, hGap)
                it.headerNodeBasics(field, detailedView, edge, leftColumnAlignment, rightColumnAlignment)
                var row = field.rowCount
                
                if(detailedView) {
                    // show following elements only if detailedView
                    // source of edge
                    field.set("source:", row, 0, leftColumnAlignment)
                    field.set("FNode " + edge.getValue("source.id") + " " 
                                       + edge.getVariable("source").getValueString, row, 1, rightColumnAlignment)
                    row = row + 1

                    // target of edge
                    field.set("target:", row, 0, leftColumnAlignment)
                    field.set("FNode " + edge.getValue("target.id") + " " 
                                       + edge.getVariable("target").getValueString, row, 1, rightColumnAlignment)
                    row = row + 1
                } else {
                    // if not detailedView, show a summary of following elements
                    // # of bendPoints
                    field.set("bendPoints (#):", row, 0, leftColumnAlignment)
                    field.set(edge.getValue("bendpoints.size"), row, 1, rightColumnAlignment)
                    row = row + 1
                    
                    // # of labels of port
                    field.set("labels (#):", row, 0, leftColumnAlignment)
                    field.set(edge.getValue("labels.size"), row, 1, rightColumnAlignment)
                    row = row + 1
                }

                // fill the KText into the ContainerRendering
                for (text : field) {
                    it.children += text
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
            edge.createTopElementEdge(labels, "labels")
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
            edge.createTopElementEdge(bendPoints, "bendpoints")
        } 
    }


}