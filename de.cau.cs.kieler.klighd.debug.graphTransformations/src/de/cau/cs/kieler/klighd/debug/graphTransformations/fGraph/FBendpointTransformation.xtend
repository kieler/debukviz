package de.cau.cs.kieler.klighd.debug.graphTransformations.fGraph

import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKNodeTransformation
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*


class FBendpointTransformation extends AbstractKNodeTransformation {
    
    @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
//    @Inject
//    extension KEdgeExtensions
//    @Inject 
//    extension KPolylineExtensions 
//    @Inject
//    extension KColorExtensions
    
    override transform(IVariable bendPoint) {
         return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            
            it.children += bendPoint.createNode => [
//                it.setNodeSize(120,80)
                
//                it.addLayoutParam(LayoutOptions::LABEL_SPACING, 75f)
//                it.addLayoutParam(LayoutOptions::SPACING, 75f)
                
                it.data += renderingFactory.createKEllipse => [
                    it.lineWidth = 2
                    it.ChildPlacement = renderingFactory.createKGridPlacement()
                    
                    // Type of bendpoint
                    it.children += renderingFactory.createKText() => [
                        it.setForegroundColor(120,120,120)
                        it.text = bendPoint.ShortType
                    ]

                    // associated edge
                    it.children += renderingFactory.createKText() => [
                        it.text = "edge: (" + bendPoint.getValue("edge.source.label") + " -> " 
                                            + bendPoint.getValue("edge.target.label") + ")" 
                    ]

                    it.children += renderingFactory.createKText() => [
                        it.text = "position (x,y): (" + bendPoint.getValue("position.x").round(1) + " x " 
                                                      + bendPoint.getValue("position.y").round(1) + ")" 
                    ]
                    
                    it.children += renderingFactory.createKText() => [
                        it.text = "size (x,y): (" + bendPoint.getValue("size.x").round(1) + " x " 
                                                  + bendPoint.getValue("size.y").round(1) + ")" 
                    ]
                ]
            ]
        ]
    }    
}