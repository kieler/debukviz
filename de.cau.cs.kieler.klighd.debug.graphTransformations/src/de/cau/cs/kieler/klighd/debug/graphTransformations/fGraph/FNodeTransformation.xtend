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
import de.cau.cs.kieler.core.properties.IProperty
import de.cau.cs.kieler.core.krendering.KEllipse
import de.cau.cs.kieler.core.krendering.KContainerRendering
import de.cau.cs.kieler.klay.planar.graph.*

import static de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph.LGraphTransformation.*
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation

class FNodeTransformation extends AbstractKielerGraphTransformation {
    
    @Inject
    extension KNodeExtensions
    @Inject
    extension KEdgeExtensions
    @Inject
    extension KRenderingExtensions
    @Inject
    extension KColorExtensions
    
    /**
     * {@inheritDoc}
     */
    override transform(IVariable node, Object transformationInfo) {
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            
            it.children += node.createNodeById => [
//                it.setNodeSize(120,80)
                
//                it.addLayoutParam(LayoutOptions::LABEL_SPACING, 75f)
//                it.addLayoutParam(LayoutOptions::SPACING, 75f)
                
                it.data += renderingFactory.createKRectangle => [
                    it.lineWidth = 2
                    it.ChildPlacement = renderingFactory.createKGridPlacement()
                    
                    // Type of node
                    it.children += renderingFactory.createKText() => [
                        it.setForegroundColor(120,120,120)
                        it.text = node.getType
                    ]
                    
                    // id of node
                    it.children += node.createKText("id", "", ": ")
                    // label of node (there is only one)
                    it.children += node.createKText("label", "", ": ")
                    
                    // displacement
                    it.children += renderingFactory.createKText() => [
                        it.text = "displacement (x,y): (" + node.getValue("displacement.x").round(1) + " x " 
                                                          + node.getValue("displacement.y").round(1) + ")" 
                    ]
                    
                    // position
                    it.children += renderingFactory.createKText() => [
                        it.text = "position (x,y): (" + node.getValue("position.x").round(1) + " x " 
                                                      + node.getValue("position.y").round(1) + ")" 
                    ]
                    
                    // size
                    it.children += renderingFactory.createKText() => [
                        it.text = "size (x,y): (" + node.getValue("size.x").round(1) + " x " 
                                                  + node.getValue("size.y").round(1) + ")" 
                    ]
                ]
            ]
        ]
    }
}