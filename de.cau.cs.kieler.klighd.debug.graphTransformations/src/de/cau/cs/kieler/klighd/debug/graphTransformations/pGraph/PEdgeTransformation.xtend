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
import de.cau.cs.kieler.core.krendering.HorizontalAlignment

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
    val leftColumnAlignment = HorizontalAlignment::RIGHT
    val rightColumnAlignment = HorizontalAlignment::LEFT
    
//TODO: was wann?    
    val showPropertyMap = ShowTextIf::DETAILED
    val showLabels = ShowTextIf::DETAILED
	val showBendPoints= ShowTextIf::DETAILED
	val showSource= ShowTextIf::DETAILED
	val showHashCode= ShowTextIf::DETAILED
	val showID= ShowTextIf::DETAILED
    val showBendPointsCount = ShowTextIf::DETAILED
    val showLabelsCount= ShowTextIf::DETAILED

    /**
     * {@inheritDoc}
     */    
    override transform(IVariable edge, Object transformationInfo) {
        detailedView = transformationInfo.isDetailed

        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            it.addLayoutParam(LayoutOptions::SPACING, spacing)

			it.addInvisibleRendering
			it.addHeaderNode(edge)

            // add propertyMap
            if(showPropertyMap.conditionalShow(detailedView))
                it.addPropertyMapNode(edge.getVariable("propertyMap"), edge)
                
            // add labels node
            if(showLabels.conditionalShow(detailedView))
                it.addLabelsNode(edge)
        ]
    }
    
	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
	    var retVal = if(showPropertyMap.conditionalShow(detailedView)) 2 else 1
	    if(showLabels.conditionalShow(detailedView)) retVal = retVal +1
		return retVal
	}
    
    def addLabelsNode(KNode rootNode, IVariable edge) {
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

    
    def addHeaderNode(KNode rootNode, IVariable edge) { 
        rootNode.addNodeById(edge) => [
            it.data += renderingFactory.createKRectangle => [
                
                val table = it.headerNodeBasics(detailedView, edge)

                // id of edge
	            if (showID.conditionalShow(detailedView)) {
		            table.addGridElement("id:", leftColumnAlignment)
		            table.addGridElement(edge.nullOrValue("id"), rightColumnAlignment)
	            } 

                // hashCode of edge
	            if (showHashCode.conditionalShow(detailedView)) {
		            table.addGridElement("hashCode:", leftColumnAlignment)
		            table.addGridElement(edge.nullOrValue("hashCode"), rightColumnAlignment)
	            } 
   
                // source of edge
	            if (showSource.conditionalShow(detailedView)) {
		            table.addGridElement("source:", leftColumnAlignment)
		            table.addGridElement(edge.nullOrTypeAndID("source"), rightColumnAlignment)
	            } 

                // target of edge
	            if (showID.conditionalShow(detailedView)) {
		            table.addGridElement("target:", leftColumnAlignment)
		            table.addGridElement(edge.nullOrTypeAndID("target"), rightColumnAlignment)
	            } 

//TODO: bendpoints (erstes element separat)
                // list of bendPoints
        	    if (showBendPoints.conditionalShow(detailedView)) {
	            	table.addGridElement("bendPoints (x,y):", leftColumnAlignment)
	            	
                	if (edge.getValue("bendPoints.size").equals("0")) {
                        // no bendPoints on edge
		            	table.addGridElement("(none)", rightColumnAlignment)
                    } else {
                        // create list of bendPoints
                        for (bendPoint : edge.getVariable("bendPoints").linkedList) {
			            	table.addGridElement(bendPoint.nullOrKVektor(""), rightColumnAlignment)
                        }
                    }

                // # of bendPoints
        	    if (showBendPointsCount.conditionalShow(detailedView)) {
		            table.addGridElement("bendPoints (#):", leftColumnAlignment)
		            table.addGridElement(edge.nullOrSize("bendPoints"), rightColumnAlignment)
	            } 
                    
                    // # of labels of port
        	    if (showLabelsCount.conditionalShow(detailedView)) {
		            table.addGridElement("labels (#):", leftColumnAlignment)
		            table.addGridElement(edge.nullOrSize("labels"), rightColumnAlignment)
	            } 
	            
            }
            ]
        ]
    }
}