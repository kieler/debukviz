package de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph

import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import org.eclipse.debug.core.model.IVariable
import org.eclipse.debug.core.model.IVariable
import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.LineStyle
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable
import de.cau.cs.kieler.core.krendering.KRendering
import de.cau.cs.kieler.core.krendering.KContainerRendering
import de.cau.cs.kieler.klighd.debug.graphTransformations.KTextIterableField

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf

class LLabelTransformation extends AbstractKielerGraphTransformation {
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
    val showPropertyMap = ShowTextIf::DETAILED
        
    override transform(IVariable label, Object transformationInfo) {
        detailedView = transformationInfo.isDetailed

        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            it.addLayoutParam(LayoutOptions::SPACING, spacing)

it.addInvisibleRendering
            it.data += renderingFactory.createKRectangle => [
                it.invisible = true
            ]
            
            // create KNode for given LLabel
            it.createHeaderNode(label)
            
            // add propertyMap
            if(showPropertyMap.conditionalShow(detailedView))
                it.addPropertyMapNode(label.getVariable("propertyMap"), label)
        ]
    }
    
	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
		return if(showPropertyMap.conditionalShow(detailedView)) 2 else 1
	}
    
    def createHeaderNode(KNode rootNode, IVariable label) { 
        rootNode.addNodeById(label) => [
            it.data += renderingFactory.createKRectangle => [

                val field = new KTextIterableField(topGap, rightGap, bottomGap, leftGap, vGap, hGap)
                it.headerNodeBasics(field, detailedView, label, leftColumnAlignment, rightColumnAlignment)
                var row = field.rowCount
                
                // id of label
                field.set("id:", row, 0, leftColumnAlignment)
                field.set(nullOrValue(label, "id"), row, 1, rightColumnAlignment)
                row = row + 1
   
                // hashCode of label
                field.set("hashCode:", row, 0, leftColumnAlignment)
                field.set(nullOrValue(label, "hashCode"), row, 1, rightColumnAlignment)
                row = row + 1
                
                // text of label
                field.set("text:", row, 0, leftColumnAlignment)
                field.set(nullOrValue(label, "text"), row, 1, rightColumnAlignment)
                row = row + 1
                
                if(detailedView) {
                    // show following elements only if detailedView
                    // position of label
                    field.set("pos (x,y):", row, 0, leftColumnAlignment)
                    field.set("(" + label.getValue("pos.x").round + ", " 
                                  + label.getValue("pos.y").round + ")", row, 1, rightColumnAlignment)
                    row = row + 1
                    
                    // size of label
                    field.set("size (x,y):", row, 0, leftColumnAlignment)
                    field.set("(" + label.getValue("size.x").round + ", " 
                                  + label.getValue("size.y").round + ")", row, 1, rightColumnAlignment)
                    row = row + 1

                    // side of label
                    field.set("side:", row, 0, leftColumnAlignment)
                    field.set(label.getValue("side.name"), row, 1, rightColumnAlignment)
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