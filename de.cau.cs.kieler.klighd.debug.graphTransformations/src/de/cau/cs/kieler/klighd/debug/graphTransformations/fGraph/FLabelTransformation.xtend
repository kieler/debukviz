package de.cau.cs.kieler.klighd.debug.graphTransformations.fGraph

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

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.klighd.debug.graphTransformations.KTextIterableField

class FLabelTransformation extends AbstractKielerGraphTransformation {
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
        
    /**
     * {@inheritDoc}
     */
    override transform(IVariable label, Object transformationInfo) {
        if(transformationInfo instanceof Boolean) detailedView = transformationInfo as Boolean

        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            it.addLayoutParam(LayoutOptions::SPACING, spacing)
            
            // create KNode for given FLabel
            it.createHeaderNode(label)
            
            // add propertyMap
            if (detailedView) it.addPropertyMapAndEdge(label.getVariable("propertyMap"), label)
        ]
    }
    
    def createHeaderNode(KNode rootNode, IVariable label) { 
        rootNode.addNodeById(label) => [
            
            it.data += renderingFactory.createKRectangle => [

                val field = new KTextIterableField(topGap, rightGap, bottomGap, leftGap, vGap, hGap)
                it.headerNodeBasics(field, detailedView, label)
                var row = field.rowCount
                
                // text of label
                field.set("text:", row, 0, leftColumnAlignment)
                field.set(nullOrValue(label, "text"), row, 1, rightColumnAlignment)
                row = row + 1

                if(detailedView) {
                    // show following elements only if detailedView
                    // edge of label
                    field.set("edge:", row, 0, leftColumnAlignment)
                    field.set("FEdge " + label.getVariable("edge").debugID, row, 1, rightColumnAlignment)
                    row = row + 1
                
                    // position of label
                    field.set("position (x,y):", row, 0, leftColumnAlignment)
                    field.set("(" + label.getValue("position.x").round + " x " 
                                  + label.getValue("position.y").round + ")", row, 1, rightColumnAlignment)
                    row = row + 1

                    // size of label
                    field.set("size (x,y):", row, 0, leftColumnAlignment)
                    field.set("(" + label.getValue("size.x").round + " x " 
                                  + label.getValue("size.y").round + ")", row, 1, rightColumnAlignment)
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