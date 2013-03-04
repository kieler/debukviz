package de.cau.cs.kieler.klighd.debug.graphTransformations.pGraph

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.HorizontalAlignment
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

class PLabelTransformation extends AbstractKielerGraphTransformation {
    @Inject
    extension KNodeExtensions 
    @Inject
    extension KRenderingExtensions
        
    val layoutAlgorithm = "de.cau.cs.kieler.klay.layered"
    val spacing = 75f
    val leftColumnAlignment = HorizontalAlignment::RIGHT
    val rightColumnAlignment = HorizontalAlignment::LEFT
    
    val showPropertyMap = ShowTextIf::DETAILED
	val showID = ShowTextIf::ALWAYS
	val showHashCode = ShowTextIf::DETAILED
	val showText = ShowTextIf::ALWAYS
	val showPosition = ShowTextIf::DETAILED
	val showSize = ShowTextIf::DETAILED
	val showSide = ShowTextIf::DETAILED

        
    override transform(IVariable label, Object transformationInfo) {
        detailedView = transformationInfo.isDetailed

        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            it.addLayoutParam(LayoutOptions::SPACING, spacing)

			it.addInvisibleRendering
            it.data += renderingFactory.createKRectangle => [
                it.invisible = true
            ]
            
            // create KNode for given LLabaddPropertyMapNodeateHeaderNode(label)
            
            // add propertyMap
            if(showPropertyMap.conditionalShow(detailedView))
                it.addPropertyMapNode(label.getVariable("propertyMap"), label)
        ]
    }
    
	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
		return if(showPropertyMap.conditionalShow(detailedView)) 2 else 1
	}
    
    def createHeaderNode(KNode rootNode, IVariable label) { 
        rootNode.addNodeById(label) => [
            it.data += renderingFactory.createKRectangle => [

                val table = it.headerNodeBasics(detailedView, label)

                // id of label
	            if (showID.conditionalShow(detailedView)) {
		            table.addGridElement("id:", leftColumnAlignment)
		            table.addGridElement(label.nullOrValue("id"), rightColumnAlignment)
	            } 
   
                // hashCode of label
	            if (showHashCode.conditionalShow(detailedView)) {
		            table.addGridElement("hashCode:", leftColumnAlignment)
		            table.addGridElement(label.nullOrValue("hashCode"), rightColumnAlignment)
	            } 

                // text of label
	            if (showText.conditionalShow(detailedView)) {
		            table.addGridElement("text:", leftColumnAlignment)
		            table.addGridElement(label.nullOrValue("text"), rightColumnAlignment)
	            } 

                // position of label
	            if (showPosition.conditionalShow(detailedView)) {
		            table.addGridElement("pos (x,y):", leftColumnAlignment)
		            table.addGridElement(label.nullOrKVektor("pos"), rightColumnAlignment)
	            } 

                // size of label
	            if (showSize.conditionalShow(detailedView)) {
		            table.addGridElement("size:", leftColumnAlignment)
		            table.addGridElement(label.nullOrKVektor("size"), rightColumnAlignment)
	            } 

                // side of label
	            if (showSide.conditionalShow(detailedView)) {
		            table.addGridElement("side:", leftColumnAlignment)
		            table.addGridElement(label.nullOrName("side"), rightColumnAlignment)
	            } 
            ]
        ]
    }
}