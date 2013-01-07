package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.klighd.TransformationContext
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation
import org.eclipse.debug.core.model.IVariable
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.kiml.options.LayoutOptions

class HashMapTransformation extends AbstractDebugTransformation {
   
    extension KNodeExtensions kNodeExtensions = new KNodeExtensions();
    extension KEdgeExtensions kEdgeExtensions = new KEdgeExtensions();
    extension KRenderingExtensions kRenderingExtensions = new KRenderingExtensions();
    extension KColorExtensions kColorExtensions = new KColorExtensions(); 
    
    override transform(IVariable model, TransformationContext<IVariable,KNode> transformationContext) {
        use(transformationContext);
        return KimlUtil::createInitializedNode() => [
                 it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
                 it.addLayoutParam(LayoutOptions::SPACING, 75f)
                 val String size = model.getValueByName("size");
                 val IVariable table = model.getVariableByName("table")
                 it.nextTransformation(table,null)
               ]
    }
   
}