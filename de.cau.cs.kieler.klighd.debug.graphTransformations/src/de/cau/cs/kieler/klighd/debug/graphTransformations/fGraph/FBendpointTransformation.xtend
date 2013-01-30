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
    
    override transform(IVariable bendPoint, Object transformationInfo) {
        if(transformationInfo instanceof Boolean) detailedView = transformationInfo as Boolean    
        
         return KimlUtil::createInitializedNode=> [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)

            // create KNode for given FEdge
            it.createHeaderNode(bendPoint)
            
            // if in detailedView, add node for propertyMap
            if (detailedView) it.addPropertyMapAndEdge(bendPoint.getVariable("propertyMap"), bendPoint)
        ]
    }

    def createHeaderNode(KNode rootNode, IVariable bendPoint) {
        rootNode.addNodeById(bendPoint) => [
            it.data += renderingFactory.createKEllipse => [
                it.headerNodeBasics(detailedView, bendPoint)

                // associated edge
                it.children += renderingFactory.createKText() => [
                    it.text = "edge: FEdge " + bendPoint.getVariable("edge").debugID 
                ]

                if(detailedView) {
                    it.children += renderingFactory.createKText() => [
                        it.text = "position (x,y): (" + bendPoint.getValue("position.x").round + " x " 
                                                      + bendPoint.getValue("position.y").round + ")" 
                    ]
                    
                    it.children += renderingFactory.createKText() => [
                        it.text = "size (x,y): (" + bendPoint.getValue("size.x").round + " x " 
                                                  + bendPoint.getValue("size.y").round + ")" 
                    ]
                }
            ]
        ]
    }
    
}