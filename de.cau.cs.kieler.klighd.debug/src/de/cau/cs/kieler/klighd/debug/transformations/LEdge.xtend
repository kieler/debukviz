package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.klighd.debug.transformations.AbstractKNodeTransformation
import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.klighd.TransformationContext
import org.eclipse.debug.core.model.IVariable
import de.cau.cs.kieler.core.util.Pair
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.KRenderingFactory
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.kiml.options.LayoutOptions

class LEdge extends AbstractKNodeTransformation {
    
    
    extension KNodeExtensions kNodeExtensions = new KNodeExtensions()
    extension KEdgeExtensions kEdgeExtensions = new KEdgeExtensions()
    extension KRenderingExtensions kRenderingExtensions = new KRenderingExtensions()
    extension KColorExtensions kColorExtensions = new KColorExtensions()
    
    
    private static val KRenderingFactory renderingFactory = KRenderingFactory::eINSTANCE

    override transform(IVariable model, TransformationContext<IVariable,KNode> transformationContext) {
        use(transformationContext)
        return KimlUtil::createInitializedNode=> [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            it.createHeaderNode(variable)
            it.createLayerlessNodes(variable.getVariableByName("layerlessNodes"))
            it.createLayeredNodes(variable.getVariableByName("layers"))
            it.createEdges(variable.getVariableByName("layerlessNodes"))
            it.createEdges(variable.getVariableByName("layers"))
        ]
    }
    
    def createEdges(KNode rootNode, IVariable variable) {
        for(node : variable.linkedList) {
            for(port : node.getVariableByName("ports").linkedList) {
                for(outgoingEdge : port.getVariableByName("outgoingEdges").linkedList) {
                    createEdge(outgoingEdge)
                }
            }
        }
    }
    
    def createEdge(IVariable edge) {
        val parent = edge.getVariableByName("source")
        val child = edge.getVariableByName("target")
        new Pair(parent, child).createEdge() => [
            it.source = parent.node
            it.target = child.node
            it.data += renderingFactory.createKPolyline() => [
                it.setLineWidth(2)
                switch()
            ]
        ]
    }  
}