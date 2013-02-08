package de.cau.cs.kieler.klighd.debug.graphTransformations.fGraph

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
import de.cau.cs.kieler.core.krendering.HorizontalAlignment
import de.cau.cs.kieler.core.krendering.VerticalAlignment
import de.cau.cs.kieler.core.properties.IProperty
import de.cau.cs.kieler.core.krendering.KEllipse
import de.cau.cs.kieler.core.krendering.KContainerRendering

import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement
import static de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph.LGraphTransformation.*
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.klighd.krendering.PlacementUtil
import java.util.ArrayList
import de.cau.cs.kieler.klighd.debug.graphTransformations.KTextIterableField
import de.cau.cs.kieler.core.krendering.HorizontalAlignment

class FNodeTransformation extends AbstractKielerGraphTransformation {
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
    @Inject
    extension KTextIterableField
        
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
    val field = new KTextIterableField(topGap, rightGap, bottomGap, leftGap, vGap, hGap)
    
    /**
     * {@inheritDoc}
     */
    override transform(IVariable node, Object transformationInfo) {
        if(transformationInfo instanceof Boolean) detailedView = transformationInfo as Boolean

        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            it.addLayoutParam(LayoutOptions::SPACING, spacing)
            
            // create KNode for given LNode
            val headerNode = it.createHeaderNode(node)

            // add propertyMap
            if (detailedView) it.addPropertyMapAndEdge(node.getVariable("propertyMap"), node)

			val children = node.getVariable("children")
			
//TODO: add children nodes

			if (children.valueIsNotNull) {
				if ( Integer::parseInt(children.getValue("size")) > 0) {
		            if (detailedView) {
			            // add a node for the children
		            	it.createChildNodeAndEdge(children)
//		            	it.addChildren(children)
		            } else {
			            // add child-area to header-node
			            headerNode.data += renderingFactory.createKChildArea => [
			            	it.placementData = renderingFactory.createKAreaPlacementData => [
								it.topLeft = createKPosition(LEFT, field.width, 0, TOP, 5, 0)
								it.bottomRight = createKPosition(RIGHT, 0, 0, BOTTOM, 5, 0)
							]
			            ]
//			            headernode.addChildren(children)
		            }
				}
			}
            
        ]
    }

	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
		return 0
	}

	def createChildNodeAndEdge(KNode node, IVariable variable) { }

    

    
    /**
     * As there is no writeDotGraph in FGraph we don't have a prototype for formatting the nodes
     */
    def createHeaderNode(KNode rootNode, IVariable node) { 
        rootNode.addNodeById(node) => [
            it.data += renderingFactory.createKRectangle => [
                
                val table = it.headerNodeBasics(detailedView, node)
                var row = field.rowCount
                
                // id of node
                table.addGridElement("id:", HorizontalAlignment::RIGHT)
                table.addGridElement(nullOrValue(node, "id"), HorizontalAlignment::LEFT)
                
                // label of node (there is only one)
                table.addGridElement("label:", HorizontalAlignment::RIGHT)
                table.addGridElement(nullOrValue(node, "label"), HorizontalAlignment::LEFT)

                if (detailedView) {
                    // parent
	                table.addGridElement("parent:", HorizontalAlignment::RIGHT)
                    table.addGridElement(node.typeAndId("parent"), HorizontalAlignment::LEFT)
                    
                    // displacement
	                table.addGridElement("displacement (x,y):", HorizontalAlignment::RIGHT)
	                table.addGridElement("(" + node.getValue("displacement.x").round + ", " 
                                  			 + node.getValue("displacement.y").round + ")", 
                                  			 HorizontalAlignment::LEFT)

                    // position
	                table.addGridElement("position (x,y):", HorizontalAlignment::RIGHT)
	                table.addGridElement("(" + node.getValue("position.x").round + ", " 
	                                  	     + node.getValue("position.y").round + ")",
	                                  	     HorizontalAlignment::LEFT)
                    
                    // size
	                table.addGridElement("size (x,y):", HorizontalAlignment::RIGHT)
	                table.addGridElement("(" + node.getValue("size.x").round + ", " 
                                  			 + node.getValue("size.y").round + ")", 
                                  			 HorizontalAlignment::LEFT)
                }

                // fill the KText into the ContainerRendering
                for (text : field) {
                    it.children += text
                }
            ]
        ]
    }
}






