package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.KRenderingFactory
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.core.util.Pair
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.TransformationContext
import de.cau.cs.kieler.klighd.transformations.AbstractTransformation
import java.util.LinkedList
import javax.inject.Inject

import static de.cau.cs.kieler.klighd.debug.transformations.LinkedListDiagramSynthesis.*

class LinkedListDiagramSynthesis<E> extends AbstractTransformation<LinkedList<E>, KNode> {
        
    @Inject
    extension KNodeExtensions
    
    @Inject
    extension KEdgeExtensions
    
    @Inject
    extension KRenderingExtensions
    
    @Inject
    extension KPolylineExtensions
    
    @Inject
    extension KColorExtensions
    
    private static val KRenderingFactory renderingFactory = KRenderingFactory::eINSTANCE

    /**
     * {@inheritDoc}
     */
    override KNode transform(LinkedList<E> choice, TransformationContext<LinkedList<E>, KNode> transformationContext) {
        use(transformationContext)
        
        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            
            if (!choice.nullOrEmpty) {
                it.createInternalNode(choice.head)
                it.createChildNode(choice.head, choice.tail)
            };
        ]
    }
            
    def createChildNode(KNode rootNode, E parent, Iterable<E> tail){
        if (!tail.nullOrEmpty) {
            rootNode.createInternalNode(tail.head)
            createEdge(parent, tail.head)
            createChildNode(rootNode, tail.head, tail.tail)
        }
    }
    
    def createInternalNode(KNode rootNode, E element) {
        rootNode.children += element.createNode().putToLookUpWith(element) => [
            it.setNodeSize(100,80)
            it.data += renderingFactory.createKRectangle() => [
                it.setLineWidth(2)
                it.setBackgroundColor("lemon".color)
            ]
        ]
    }
    
    def createEdge(E child, E parent) {
        new Pair(child, parent).createEdge() => [
            it.source = parent.node
            it.target = child.node
            it.data += renderingFactory.createKPolyline() => [
                it.setLineWidth(2)
            ]
        ]
    }
}