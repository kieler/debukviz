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
import de.cau.cs.kieler.core.krendering.KEllipse
import de.cau.cs.kieler.core.krendering.KContainerRendering
import de.cau.cs.kieler.klay.planar.graph.*
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.klighd.debug.graphTransformations.KTextIterableField

class PNodeTransformation extends AbstractKielerGraphTransformation {
    
    @Inject
    extension KNodeExtensions
    @Inject
    extension KEdgeExtensions
    @Inject
    extension KRenderingExtensions
    @Inject
    extension KColorExtensions
        
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
    
    /**
     * {@inheritDoc}
     */
    override transform(IVariable node, Object transformationInfo) {
        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            it.addLayoutParam(LayoutOptions::SPACING, spacing)
            
            it.addNodeById(node) => [
println("registering node for " + node.getValueString)
                // either an ellipse or a rectangle
                var KContainerRendering container
    
                // comments at PNode.writeDotGraph is not consistent to the code in the method
                // here I am following the display style implemented
                switch node.getValue("type.name") {
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
                        // TODO: coloring is ignored, as the original model seems to have only one color
                    }
                }
                
                val field = new KTextIterableField(topGap, rightGap, bottomGap, leftGap, vGap, hGap)
                container.headerNodeBasics(field, detailedView, node, leftColumnAlignment, rightColumnAlignment)
                var row = field.rowCount

                // PNodes don't have a name or labels
                // id of node
                field.set("id:", row, 0, leftColumnAlignment)
                field.set(nullOrValue(node, "id"), row, 1, rightColumnAlignment)
                row = row + 1

                // position
                field.set("pos (x,y):", row, 0, leftColumnAlignment)
                field.set("(" + node.getValue("pos.x").round + ", " 
                              + node.getValue("pos.y").round + ")", row, 1, rightColumnAlignment)
                row = row + 1
                
                // size
                field.set("size (x,y):", row, 0, leftColumnAlignment)
                field.set("(" + node.getValue("size.x").round + ", " 
                              + node.getValue("size.y").round + ")", row, 1, rightColumnAlignment)
                row = row + 1

                // fill the KText into the ContainerRendering
                for (text : field) {
                    container.children += text
                }
                
                it.data += container
            ]
        ]
    }
    
	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
		return 0
	}
}