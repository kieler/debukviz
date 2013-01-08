package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.TransformationContext
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

class HashMapTransformation extends AbstractDebugTransformation {
   
    @Inject
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
    @Inject 
    extension KPolylineExtensions 
    
    override transform(IVariable model, TransformationContext<IVariable,KNode> transformationContext) {
        use(transformationContext);
        return KimlUtil::createInitializedNode() => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            it.addLayoutParam(LayoutOptions::DIRECTION, Direction::UP)
            model.getVariablesByName("table").filter[variable | variable.valueIsNotNull].forEach[
                IVariable variable | it.createKeyValueNode(variable)
            ]
        ]
    }
    
    def createKeyValueNode(KNode node, IVariable variable) {
       val key = variable.getVariableByName("key")
       val value = variable.getVariableByName("value")
       node.createInnerNode(key,"Key")
       node.createInnerNode(value,"Value")
       key.createEdge(value) => [
            it.data += renderingFactory.createKPolyline() => [
                it.setLineWidth(2);
                it.addArrowDecorator();
            ];
        ]; 
    }
    
    def createInnerNode(KNode node, IVariable variable, String text) {
        node.children += variable.createNode().putToLookUpWith(variable) => [
            it.children += it.createNode() => [
                it.data += renderingFactory.createKText() => [
                    it.text = text
                ]
            ]
            it.nextTransformation(variable,null)
       ] 
    }
}