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

class PEdgeTransformation extends AbstractKielerGraphTransformation {
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
    
    val layoutAlgorithm = "de.cau.cs.kieler.klay.layered"
    val spacing = 75f
    val leftColumnAlignment = HorizontalAlignment::RIGHT
    val rightColumnAlignment = HorizontalAlignment::LEFT
    
    val showPropertyMap = ShowTextIf::DETAILED

	val showID= ShowTextIf::ALWAYS
	val showHashCode= ShowTextIf::DETAILED
	val showFaces = ShowTextIf::DETAILED
	val showParent = ShowTextIf::DETAILED
	val showSource = ShowTextIf::DETAILED
	val showTarget = ShowTextIf::DETAILED
	val showBendPoints = ShowTextIf::DETAILED
    val showBendPointsCount = ShowTextIf::COMPACT

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
        ]
    }
    
	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
	    var retVal = if(showPropertyMap.conditionalShow(detailedView)) 2 else 1
		return retVal
	}
    
    def addHeaderNode(KNode rootNode, IVariable edge) { 
        rootNode.addNodeById(edge) => [
            it.data += renderingFactory.createKRectangle => [
                
                val table = it.headerNodeBasics(detailedView, edge)

                // id
	            if (showID.conditionalShow(detailedView)) {
		            table.addGridElement("id:", leftColumnAlignment)
		            table.addGridElement(edge.nullOrValue("id"), rightColumnAlignment)
	            } 

                // isDirected
	            if (showHashCode.conditionalShow(detailedView)) {
		            table.addGridElement("isDirected:", leftColumnAlignment)
		            table.addGridElement(edge.nullOrValue("isDirected"), rightColumnAlignment)
	            } 
   
                // source
	            if (showSource.conditionalShow(detailedView)) {
		            table.addGridElement("source:", leftColumnAlignment)
		            table.addGridElement(edge.nullOrTypeAndID("source"), rightColumnAlignment)
	            } 

                // target
	            if (showTarget.conditionalShow(detailedView)) {
		            table.addGridElement("target:", leftColumnAlignment)
		            table.addGridElement(edge.nullOrTypeAndID("target"), rightColumnAlignment)
	            } 

	            // parent
	            if (showParent.conditionalShow(detailedView)) {
	                table.addGridElement("parent:", leftColumnAlignment)
	                table.addGridElement(edge.nullOrTypeAndID("parent"), rightColumnAlignment)
	            }

	            // leftFace
	            if (showFaces.conditionalShow(detailedView)) {
	                table.addGridElement("leftFace:", leftColumnAlignment)
	                table.addGridElement(edge.nullOrTypeAndID("leftFace"), rightColumnAlignment)
	            }

	            // rightFace
	            if (showParent.conditionalShow(detailedView)) {
	                table.addGridElement("rightFace:", leftColumnAlignment)
	                table.addGridElement(edge.nullOrTypeAndID("rightFace"), rightColumnAlignment)
	            }

                // # of bendPoints
        	    if (showBendPointsCount.conditionalShow(detailedView)) {
		            table.addGridElement("bendPoints (#):", leftColumnAlignment)
		            table.addGridElement(edge.nullOrSize("bendPoints"), rightColumnAlignment)
	            } 

                // list of bendPoints
        	    if (showBendPoints.conditionalShow(detailedView)) {
        	    	val bendPoints = edge.getVariable("bendPoints").linkedList
	            	table.addGridElement("bendPoints (x,y):", leftColumnAlignment)
	            	
                	if (bendPoints.size == 0) {
                        // no bendPoints on edge
		            	table.addGridElement("(none)", rightColumnAlignment)
                    } else {
                    	// first bendPoint
                    	table.addGridElement(bendPoints.head.nullOrKVektor(""), rightColumnAlignment)
                        // all following bendPoints
                        bendPoints.tail.forEach[IVariable bendPoint |
                            table.addBlankGridElement
                            table.addGridElement(bendPoint.nullOrKVektor(""), rightColumnAlignment)
                        ]                        
                    }
				}
            ]
        ]
    }
}