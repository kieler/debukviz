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
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf

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
    val showPropertyMap = ShowTextIf::DETAILED
    
    /**
     * {@inheritDoc}
     */
    override transform(IVariable node, Object transformationInfo) {
        detailedView = transformationInfo.isDetailed

        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            it.addLayoutParam(LayoutOptions::SPACING, spacing)

			it.addInvisibleRendering
            it.addHeaderNode(node)

            // add propertyMap
            if(showPropertyMap.conditionalShow(detailedView))
                it.addPropertyMapNode(node.getVariable("propertyMap"), node)
        ]
    }

	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
		return if(showPropertyMap.conditionalShow(detailedView)) 2 else 1
	}
    
    /**
     * As there is no writeDotGraph in FGraph we don't have a prototype for formatting the nodes
     */
    def addHeaderNode(KNode rootNode, IVariable node) { 
        rootNode.addNodeById(node) => [
            it.data += renderingFactory.createKRectangle => [
                
                val table = it.headerNodeBasics(detailedView, node)

                // id of node
                table.addGridElement("id:", HorizontalAlignment::RIGHT)
                table.addGridElement(nullOrValue(node, "id"), HorizontalAlignment::LEFT)
                
                // label of node (there is only one)
                table.addGridElement("label:", HorizontalAlignment::RIGHT)
                table.addGridElement(nullOrValue(node, "label"), HorizontalAlignment::LEFT)

                if (detailedView) {
                    // parent
	                table.addGridElement("parent:", HorizontalAlignment::RIGHT)
                    table.addGridElement(node.nullOrTypeAndID("parent"), HorizontalAlignment::LEFT)
                    
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
            ]
        ]
    }
}