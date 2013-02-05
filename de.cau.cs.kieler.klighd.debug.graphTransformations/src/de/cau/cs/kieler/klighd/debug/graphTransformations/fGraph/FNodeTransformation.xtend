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
			if (children.valueIsNotNull) {
				if ( Integer::parseInt(children.getValue("size")) > 0) {
		            if (detailedView) {
			            // add a node for the children
		            	it.createChildNodeAndEdge(children)
		            	it.addChildren(children)
		            } else {
			            // add child-area to header-node
			            headerNode.data += renderingFactory.createKChildArea => [
			            	it.placementData = renderingFactory.createKDirectPlacementData => [
								it.topLeft = createKPosition(LEFT, field.width, 0, TOP, 5, 0)
								it.bottomRight = createKPosition(RIGHT, 0, 0, BOTTOM, 5, 0)
							]
			            ]
			            headernode.addChildren(children)
		            }
				}
			}
            
        ]
    }
	def createChildNodeAndEdge(KNode node, IVariable variable) { }

    

    
    /**
     * As there is no writeDotGraph in FGraph we don't have a prototype for formatting the nodes
     */
    def createHeaderNode(KNode rootNode, IVariable node) { 
        rootNode.addNodeById(node) => [
            it.data += renderingFactory.createKRectangle => [
                
                it.headerNodeBasics(field, detailedView, node, leftColumnAlignment, rightColumnAlignment)
                var row = field.rowCount
                
                // id of node
                field.set("id:", row, 0, leftColumnAlignment)
                field.set(nullOrValue(node, "id"), row, 1, rightColumnAlignment)
                row = row + 1
                
                // label of node (there is only one)
                field.set("label:", row, 0, leftColumnAlignment)
                field.set(nullOrValue(node, "label"), row, 1, rightColumnAlignment)
                row = row + 1
                
            	
                if (detailedView) {
                    // parent
                    val parent = node.getVariable("parent")
                    field.set("parent:", row, 0, leftColumnAlignment)
                    if(parent.valueIsNotNull) {
                        field.set("FNode " + parent.getValue("id") + " " 
                                           + parent.getValue.getValueString, row, 1, rightColumnAlignment)
                    } else {
                        field.set("null", row, 1, rightColumnAlignment)
                    }
                    row = row + 1
                    
                    // displacement
                    field.set("displacement (x,y):", row, 0, leftColumnAlignment)
                    field.set("(" + node.getValue("displacement.x").round + " x " 
                                  + node.getValue("displacement.y").round + ")", row, 1, rightColumnAlignment)
                    row = row + 1

                    // position
                    field.set("position (x,y):", row, 0, leftColumnAlignment)
                    field.set("(" + node.getValue("position.x").round + " x " 
                                  + node.getValue("position.y").round + ")", row, 1, rightColumnAlignment)
                    row = row + 1
                    
                    // size
                    field.set("size (x,y):", row, 0, leftColumnAlignment)
                    field.set("(" + node.getValue("size.x").round + " x " 
                                  + node.getValue("size.y").round + ")", row, 1, rightColumnAlignment)
                    row = row + 1
                }

                // fill the KText into the ContainerRendering
                for (text : field) {
                    it.children += text
                }
            ]
        ]
    }
}






