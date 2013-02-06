package de.cau.cs.kieler.klighd.debug.graphTransformations.fGraph

import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.klighd.debug.graphTransformations.KTextIterableField

class FBendpointTransformation extends AbstractKielerGraphTransformation {
    
    @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
    @Inject
    extension KEdgeExtensions
    @Inject 
    extension KPolylineExtensions 
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
     override transform(IVariable bendPoint, Object transformationInfo) {
        if(transformationInfo instanceof Boolean) detailedView = transformationInfo as Boolean    
        
         return KimlUtil::createInitializedNode=> [
            it.addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            it.addLayoutParam(LayoutOptions::SPACING, spacing)

            // create KNode for given FEdge
            it.createHeaderNode(bendPoint)
            
            // add propertyMap
            if (detailedView) it.addPropertyMapAndEdge(bendPoint.getVariable("propertyMap"), bendPoint)
        ]
    }

    def createHeaderNode(KNode rootNode, IVariable bendPoint) {
        rootNode.addNodeById(bendPoint) => [
            it.data += renderingFactory.createKEllipse => [
                
                val field = new KTextIterableField(topGap, rightGap, bottomGap, leftGap, vGap, hGap)
                it.headerNodeBasics(field, detailedView, bendPoint, leftColumnAlignment, rightColumnAlignment)
                var row = field.rowCount
                
                // associated edge
                field.set("edge:", row, 0, leftColumnAlignment)
                field.set("FEdge " + bendPoint.getVariable("edge").getValueString, row, 1, rightColumnAlignment)
                row = row + 1

                if(detailedView) {
                    // position of bendPoint
                    field.set("position (x,y):", row, 0, leftColumnAlignment)
                    field.set("(" + bendPoint.getValue("position.x").round + " x " 
                                  + bendPoint.getValue("position.y").round + ")", row, 1, rightColumnAlignment)
                    row = row + 1
                    
                    // size of bendPoint
                    field.set("size (x,y):", row, 0, leftColumnAlignment)
                    field.set("(" + bendPoint.getValue("size.x").round + " x " 
                                  + bendPoint.getValue("size.y").round + ")", row, 1, rightColumnAlignment)
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