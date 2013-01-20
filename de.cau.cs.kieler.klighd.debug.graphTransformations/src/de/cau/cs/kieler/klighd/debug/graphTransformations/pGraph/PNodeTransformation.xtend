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
import org.eclipse.debug.core.model.IVariable
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKNodeTransformation
import de.cau.cs.kieler.core.krendering.KEllipse
import de.cau.cs.kieler.core.krendering.KContainerRendering
import de.cau.cs.kieler.klay.planar.graph.*

class PNodeTransformation extends AbstractKNodeTransformation {
    
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
    override transform(IVariable node) {
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            
            it.children += node.createNode => [
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
                
                container.ChildPlacement = renderingFactory.createKGridPlacement                    

                // Type of node
                container.children += renderingFactory.createKText() => [
                    it.setForegroundColor(120,120,120)
                    it.text = node.ShortType
                ]
                                        
                // PNodes don't have a name or labels
                // id of node
                container.children += node.createKText("id", "", ": ")
                
                // position
                container.children += renderingFactory.createKText() => [
                    it.text = "position (x,y): (" + node.getValue("pos.x").round(1) + " x " 
                                                  + node.getValue("pos.y").round(1) + ")" 
                ]
                
                // size
                container.children += renderingFactory.createKText() => [
                    it.text = "size (x,y): (" + node.getValue("size.x").round(1) + " x " 
                                              + node.getValue("size.y").round(1) + ")" 
                ]
                
                it.data += container
            ]
        ]
    }
}