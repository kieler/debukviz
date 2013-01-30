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

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation

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
    
    override transform(IVariable label, Object transformationInfo) {
        if(transformationInfo instanceof Boolean) detailedView = transformationInfo as Boolean

        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            
            // create KNode for given LLabel
            it.createHeaderNode(label)
            
            // add propertyMap
            if (detailedView) it.addPropertyMapAndEdge(label.getVariable("propertyMap"), label)
        ]
    }
    
    def createHeaderNode(KNode rootNode, IVariable label) { 
        rootNode.addNodeById(label) => [
            it.data += renderingFactory.createKRectangle => [
                it.headerNodeBasics(detailedView, label)
                
                // id of label
                it.addKText(label, "id", "", ": ")
   
                // hashCode of label
                it.addKText(label, "hashCode", "", ": ")
                
                // text of label
                it.addKText(label, "text", "", ": ")
                
                if(detailedView) {
                    // show following elements only if detailedView
                    // position of label
                    it.children += renderingFactory.createKText => [
                        it.text = "pos (x,y): (" + label.getValue("pos.x").round + " x " 
                                                 + label.getValue("pos.y").round + ")" 
                    ]

                    // size of label
                    it.children += renderingFactory.createKText => [
                        it.text = "size (x,y): (" + label.getValue("size.x").round + " x " 
                                                  + label.getValue("size.y").round + ")" 
                    ]

                    // side of label
                    it.children += renderingFactory.createKText => [
                        it.text = "side: " + label.getValue("side.name") 
                    ]
                }
            ]
        ]
    }
}