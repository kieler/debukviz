package de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.HorizontalAlignment
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

class LEdgeTransformation extends AbstractKielerGraphTransformation {
    @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
    
    val layoutAlgorithm = "de.cau.cs.kieler.kiml.ogdf.planarization"
    val spacing = 75f
    val leftColumnAlignment = HorizontalAlignment::RIGHT
    val rightColumnAlignment = HorizontalAlignment::LEFT

    val showPropertyMap = ShowTextIf::DETAILED
    val showLabelsNode = ShowTextIf::DETAILED
    val showLabelsCount = ShowTextIf::COMPACT
	val showBendPointsCount = ShowTextIf::COMPACT
	val showBendPoints = ShowTextIf::DETAILED
	val showTarget = ShowTextIf::DETAILED
	val showSource = ShowTextIf::DETAILED
	val showHashCode = ShowTextIf::DETAILED
	val showID = ShowTextIf::ALWAYS
    
    /**
     * {@inheritDoc}
     */    
    override transform(IVariable edge, Object transformationInfo) {
        detailedView = transformationInfo.isDetailed

        return KimlUtil::createInitializedNode => [
            addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            addLayoutParam(LayoutOptions::SPACING, spacing)

			addInvisibleRendering
            addHeaderNode(edge)
            
            // add propertyMap
            if(showPropertyMap.conditionalShow(detailedView))
                addPropertyMapNode(edge.getVariable("propertyMap"), edge)
            
            // add labels node
            if(showLabelsNode.conditionalShow(detailedView))
                addLabels(edge)
        ]
    }
    
	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
	    var retVal = if(showPropertyMap.conditionalShow(detailedView)) 2 else 1
        if(showLabelsNode.conditionalShow(detailedView)) (retVal = retVal + 1)
        return retVal
	}
    
    def addLabels(KNode rootNode, IVariable edge) {
        val labels = edge.getVariable("labels")
        
        if (!labels.getValue("size").equals("0")) {
 
            // create container node
            rootNode.addNodeById(labels) => [
                data += renderingFactory.createKRectangle => [
                    if(detailedView) lineWidth = 4 else lineWidth = 2
                    ChildPlacement = renderingFactory.createKGridPlacement
                ]
                    
                // create all nodes for labels
                labels.linkedList.forEach [ label |
                    nextTransformation(label, false)
                ]
            ]
            
            // create edge from header node to labels node
			edge.createTopElementEdge(labels, "labels")
        }        
    }

    
    def addHeaderNode(KNode rootNode, IVariable edge) { 
        rootNode.addNodeById(edge) => [
            data += renderingFactory.createKRectangle => [
                
                val table = headerNodeBasics(detailedView, edge)

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
	            if (showTarget.conditionalShow(detailedView)) {
		            table.addGridElement("target:", leftColumnAlignment)
		            table.addGridElement(edge.nullOrTypeAndID("target"), rightColumnAlignment)
	            } 

                // list of bendPoints
	            if (showBendPoints.conditionalShow(detailedView)) {
	            	table.addGridElement("bendPoints (x,y):", leftColumnAlignment)
                    if (edge.getValue("bendPoints.size").equals("0")) {
                        // no bendPoints on edge
						table.addGridElement("(none)", rightColumnAlignment)
                    } else {
                    	// first BendPoint
                    	val head = edge.getVariable("bendPoints").linkedList.head
                    	table.addGridElement(head.nullOrKVektor(""), rightColumnAlignment)
                        // create list of bendPoints
                        for (bendPoint : edge.getVariable("bendPoints").linkedList.tail) {
                            table.addGridElement(bendPoint.nullOrKVektor(""), rightColumnAlignment)
                        }
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
            ]
        ]
    }
}
