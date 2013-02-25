package de.cau.cs.kieler.klighd.debug.graphTransformations.pGraph

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.KContainerRendering
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.KlighdDebugPlugin
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*
import de.cau.cs.kieler.core.krendering.HorizontalAlignment

class PNodeTransformation extends AbstractKielerGraphTransformation {
    
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
	val showEdges = ShowTextIf::DETAILED

	val showID = ShowTextIf::ALWAYS
	val showSize = ShowTextIf::DETAILED
	val showPos = ShowTextIf::DETAILED
    val showType = ShowTextIf::DETAILED
    val showParent = ShowTextIf::DETAILED      

    /**
     * {@inheritDoc}
     */
    override transform(IVariable node, Object transformationInfo) {
        detailedView = transformationInfo.isDetailed

        return KimlUtil::createInitializedNode => [
        
            it.addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            it.addLayoutParam(LayoutOptions::SPACING, spacing)

			it.addInvisibleRendering
            it.createHeaderNode(node)

            // add propertyMap
            if(showPropertyMap.conditionalShow(detailedView))
                it.addPropertyMapNode(node.getVariable("propertyMap"), node)

            // add edges node
            if(showEdges.conditionalShow(detailedView))
            	it.addEdgesNode(node)
        ]
    }
    
    def createHeaderNode(KNode rootNode, IVariable node) {
        rootNode.addNodeById(node) => [
            // either an ellipse or a rectangle
            var KContainerRendering container
            val type = node.getValue("type.name")

            // comments at PGraph.writeDotGraph is not consistent to the code in the method
            // here I am following the display style implemented
            switch type {
                case "NORMAL" : {
                    // Normal nodes are represented by an ellipse
                    container = renderingFactory.createKEllipse
                    container.lineWidth = 2
                }
                case "FACE" : {
                    // Face nodes are represented by an rectangle
                    container = renderingFactory.createKRectangle
                    container.lineWidth = 2
                }
                default : {
                    // other nodes are represented by a bold ellipse
                    // in writeDotGraph they were originally represented by a filled circle
                    container = renderingFactory.createKEllipse
                    container.lineWidth = 4
                }
                // coloring is ignored
            }
            
            val table = container.headerNodeBasics(detailedView, node)

            // PNodes don't have a name or labels
            // id of node
            if (showID.conditionalShow(detailedView)) {
                table.addGridElement("id:", leftColumnAlignment)
                table.addGridElement(node.nullOrValue("id"), rightColumnAlignment)
            }
            
            // type
            if (showType.conditionalShow(detailedView)) {
                table.addGridElement("type:", leftColumnAlignment)
                table.addGridElement(type, rightColumnAlignment)
            }
            
            // parent
            if (showParent.conditionalShow(detailedView)) {
                table.addGridElement("parent:", leftColumnAlignment)
                table.addGridElement(node.nullOrTypeAndID("parent"), rightColumnAlignment)
            }
            
            // size
            if (showSize.conditionalShow(detailedView)) {
                table.addGridElement("size (x,y):", leftColumnAlignment)
                table.addGridElement(node.nullOrKVektor("size"), rightColumnAlignment)
            }

            // position
            if (showPos.conditionalShow(detailedView)) {
                table.addGridElement("pos (x,y):", leftColumnAlignment)
                table.addGridElement(node.nullOrKVektor("pos"), rightColumnAlignment)
            }

            it.data += container
        ]
    }
                
	def void addEdgesNode(KNode rootNode, IVariable node) {
        val edges = node.getVariable("edges")
        
        // create rectangle for outer node 
        rootNode.addNodeById(edges) => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
                if(edges.linkedList.size == 0) {
                	// no edges to this node
                    it.addGridElement("none", HorizontalAlignment::CENTER)
                }
            ]

            // create nodes for all edges
		    edges.linkedList.forEach[IVariable element |
          		it.nextTransformation(element, false)
	        ]

	        // create edge from root node to the visualization node
    	    node.createTopElementEdge(edges, "edges")
        ]
		
	}

	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
		return if(showPropertyMap.conditionalShow(detailedView)) 2 else 1
	}
}