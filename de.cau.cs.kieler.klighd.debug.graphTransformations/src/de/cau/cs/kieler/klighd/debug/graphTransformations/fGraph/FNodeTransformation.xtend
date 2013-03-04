package de.cau.cs.kieler.klighd.debug.graphTransformations.fGraph

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.HorizontalAlignment
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

class FNodeTransformation extends AbstractKielerGraphTransformation {
    @Inject 
    extension KNodeExtensions
        
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