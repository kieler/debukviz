package de.cau.cs.kieler.klighd.debug.graphTransformations.pGraph

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

class PFaceTransformation extends AbstractKielerGraphTransformation {
    @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
    @Inject
    extension PEdgeRenderer
    
    
    val layoutAlgorithm = "de.cau.cs.kieler.klay.layered"
    val spacing = 75f
    val leftColumnAlignment = HorizontalAlignment::RIGHT
    val rightColumnAlignment = HorizontalAlignment::LEFT

    val showPropertyMap = ShowTextIf::DETAILED
	val showVisualization = ShowTextIf::DETAILED
        
	val showID = ShowTextIf::ALWAYS
	val showAdjacentNodes = ShowTextIf::ALWAYS
	val showAdjacentEdges = ShowTextIf::DETAILED
	val showEdgeCount = ShowTextIf::NEVER
	val showNodeCount = ShowTextIf::NEVER
    /**
     * {@inheritDoc}
     */
    override transform(IVariable face, Object transformationInfo) {
        detailedView = transformationInfo.isDetailed

        return KimlUtil::createInitializedNode => [
            addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            addLayoutParam(LayoutOptions::SPACING, spacing)

			addInvisibleRendering
            addHeaderNode(face)

            // add propertyMap
            if(showPropertyMap.conditionalShow(detailedView))
                addPropertyMapNode(face.getVariable("propertyMap"), face)
                
            // create the graph visualization
            if(showVisualization.conditionalShow(detailedView))
     	       addVisualization(face)
    	]
    }

    def addHeaderNode(KNode rootNode, IVariable face) {
        rootNode.addNodeById(face) => [
println("adding face")
            data += renderingFactory.createKRectangle => [
                
                val table = headerNodeBasics(detailedView, face)
                
                if (showID.conditionalShow(detailedView)) {
println("adding showID")
                    table.addGridElement("id:", leftColumnAlignment)
                    table.addGridElement(face.nullOrValue("id"), rightColumnAlignment)
                }
                
                if (showAdjacentNodes.conditionalShow(detailedView)) {
println("adding showAdjacentNodes")
                    table.addGridElement("nodes:", leftColumnAlignment)
                    val nodes = face.getVariable("nodes").toLinkedList
                    if (nodes.size == 0) {
                    	table.addGridElement("(none)", rightColumnAlignment)
                    } else {
                    	table.addGridElement(nodes.head.getValue("id"), rightColumnAlignment)
                    	nodes.tail.forEach[ n |
                    		table.addBlankGridElement;
                    		table.addGridElement(n.getValue("id"), rightColumnAlignment)
                    	]
                    }
                }
                
                if (showAdjacentEdges.conditionalShow(detailedView)) {
println("adding showAdjacentEdges")
                    table.addGridElement("edges:", leftColumnAlignment)
                    val edges = face.getVariable("edges").toLinkedList
                    if (edges.size == 0) {
                    	table.addGridElement("(none)", rightColumnAlignment)
                    } else {
                    	table.addGridElement(edges.head.edgeString, rightColumnAlignment)
                    	edges.tail.forEach[ e |
                    		table.addBlankGridElement;
                    		table.addGridElement(e.edgeString, rightColumnAlignment)
                    	]
                    }
                }

                if (showNodeCount.conditionalShow(detailedView)) {
println("adding showNodeCount")
                    table.addGridElement("nodes (#):", leftColumnAlignment)
                    table.addGridElement(face.nullOrSize("nodes.map"), rightColumnAlignment)
                }

                if (showEdgeCount.conditionalShow(detailedView)) {
println("adding showEdgeCount")
                    table.addGridElement("edges (#):", leftColumnAlignment)
                    table.addGridElement(face.nullOrSize("edges.map"), rightColumnAlignment)
                }
            ]
        ]
    }
    
    def edgeString (IVariable edge) {
    	return edge.getValueString + 
    		   " " + 
    		   edge.getVariable("source").getValue("id") +
    		   " -> " + 
    		   edge.getVariable("target").getValue("id")
    }

	def addVisualization(KNode rootNode, IVariable face) {
        val nodes = face.getVariable("nodes")
        val nodeList = nodes.toLinkedList

        // create rectangle for outer node 
        val newNode = rootNode.addNodeById(nodes) => [
            data += renderingFactory.createKRectangle => [
                lineWidth = 4
                if(nodeList.size == 0) {
                	// graph is empty
                    addGridElement("(none)", HorizontalAlignment::CENTER)
                }
            ]

            // create all nodes
            nodeList.forEach[IVariable node |
                nextTransformation(node, false)
            ]
            
            // create all edges
            addAllEdges(face)
        ]

        // create edge from header node to visualization
        face.createTopElementEdge(nodes, "visualization")
        rootNode.children += newNode
        return newNode
	}
    
	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
		return if(showPropertyMap.conditionalShow(detailedView)) 2 else 1
	}
}
