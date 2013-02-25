package de.cau.cs.kieler.klighd.debug.graphTransformations.pGraph

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.KRenderingFactory
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import org.eclipse.debug.core.model.IVariable
import javax.inject.Inject
import de.cau.cs.kieler.core.krendering.LineStyle
import de.cau.cs.kieler.core.properties.IProperty
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.klighd.debug.graphTransformations.KTextIterableField
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf
import de.cau.cs.kieler.core.krendering.HorizontalAlignment

class PFaceTransformation extends AbstractKielerGraphTransformation {
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
    
    val layoutAlgorithm = "de.cau.cs.kieler.klay.layered"
    val spacing = 75f
    val leftColumnAlignment = HorizontalAlignment::RIGHT
    val rightColumnAlignment = HorizontalAlignment::LEFT

    val showPropertyMap = ShowTextIf::DETAILED
	val showHeaderNode = ShowTextIf::DETAILED
	val showVisualization = ShowTextIf::ALWAYS
        
	val showEdgeCount = ShowTextIf::COMPACT
	val showNodeCount = ShowTextIf::COMPACT
    /**
     * {@inheritDoc}
     */
    override transform(IVariable face, Object transformationInfo) {
        detailedView = transformationInfo.isDetailed

        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            it.addLayoutParam(LayoutOptions::SPACING, spacing)

			it.addInvisibleRendering

            if(showHeaderNode.conditionalShow(detailedView))
	            it.addHeaderNode(face)

            // add propertyMap
            if(showPropertyMap.conditionalShow(detailedView))
                it.addPropertyMapNode(face.getVariable("propertyMap"), face)
                
            // create the graph visualization
            if(showVisualization.conditionalShow(detailedView)) {
	            // create all nodes (in a new visualization node)
                val visualizationNode = it.addVisualization(face)
                // create all edges (in the given visualization node) 
                visualizationNode.createEdges(face)
            }            
    	]
    }

    def addHeaderNode(KNode rootNode, IVariable face) {
        rootNode.addNodeById(face) => [
            it.data += renderingFactory.createKRectangle => [
                
                val table = it.headerNodeBasics(detailedView, face)

                if (showNodeCount.conditionalShow(detailedView)) {
                    table.addGridElement("nodes (#):", leftColumnAlignment)
                    table.addGridElement(face.nullOrSize("nodes"), rightColumnAlignment)
                }

                if (showEdgeCount.conditionalShow(detailedView)) {
                    table.addGridElement("edges (#):", leftColumnAlignment)
                    table.addGridElement(face.nullOrSize("edges"), rightColumnAlignment)
                }
            ]
        ]
    }

	def addVisualization(KNode rootNode, IVariable face) {
        val nodes = face.getVariable("nodes")

        val newNode = rootNode.addNodeById(nodes) => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
            ]

            // create all nodes
            nodes.linkedList.forEach[IVariable node |
                it.nextTransformation(node, false)
            ]
        ]

        // create edge from header node to visualization
        face.createTopElementEdge(nodes, "visualization")
        rootNode.children += newNode
        return newNode
	}
    
	def void createEdges(KNode rootNode, IVariable face) {
//TODO: kantenbeschriftungen, wie von Miro benannt
		face.getVariable("edges").linkedList.forEach[IVariable edge |
            // IVariables the edge has to connect
            val source = edge.getVariable("source")
            var target = edge.getVariable("target")
            
            source.createEdgeById(target) => [
                it.data += renderingFactory.createKPolyline => [
                    it.setLineWidth(2)
                    it.addArrowDecorator
                    it.setLineStyle(LineStyle::SOLID)
                ]
            ]
		]
	}

	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
		return if(showPropertyMap.conditionalShow(detailedView)) 2 else 1
	}
}
