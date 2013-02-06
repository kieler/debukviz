package de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph
import de.cau.cs.kieler.core.krendering.KContainerRendering
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.LayoutOptions

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.klighd.debug.graphTransformations.KTextIterableField
import de.cau.cs.kieler.core.krendering.HorizontalAlignment
import de.cau.cs.kieler.core.krendering.VerticalAlignment

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

class LLayerTransformation extends AbstractKielerGraphTransformation {

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
    @Inject
    extension KLabelExtensions
    
    val layoutAlgorithm = "de.cau.cs.kieler.kiml.ogdf.planarization"
    val spacing = 75f
    val leftColumnAlignment = KTextIterableField$TextAlignment::RIGHT
    val rightColumnAlignment = KTextIterableField$TextAlignment::LEFT
    val topGap = 4
    val rightGap = 5
    val bottomGap = 5
    val leftGap = 4
    val vGap = 3
    val hGap = 5
    
    /**
     * {@inheritDoc}
     */
	override transform(IVariable layer, Object transformationInfo) {
        if(transformationInfo instanceof Boolean) detailedView = transformationInfo as Boolean
        
        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            it.addLayoutParam(LayoutOptions::SPACING, spacing)
            
            // create KNode for given LLayer
            it.createHeaderNode(layer)
            
            // add nodes for propertymap and ports, if in detailed mode
            if (detailedView) {
                // addpropertymap
                it.addPropertyMapAndEdge(layer.getVariable("propertyMap"), node)
                
                //add node for ports
                it.addPorts(layer)
            }        
    	]
	}
	def createHeaderNode(KNode rootNode, IVariable layer) {
        rootNode.addNodeById(layer) => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
	            it.ChildPlacement = renderingFactory.createKGridPlacement => [
	                it.numColumns = 2
	            ]
	            it.setVerticalAlignment(VerticalAlignment::TOP)    	
	            it.setHorizontalAlignment(HorizontalAlignment::LEFT)    	

	
	            // id of layer
	            it.addGridElement("id:")
	            field.set("id:", row, 0, leftColumnAlignment)
	            field.set(nullOrValue(port, "id"), row, 1, rightColumnAlignment)
	                row = row + 1
	   
	                // hashCode of port
	            field.set("hashCode:", row, 0, leftColumnAlignment)
	            field.set(nullOrValue(port, "hashCode"), row, 1, rightColumnAlignment)
	            row = row + 1
	        
	            // side of port
	            field.set("side:", row, 0, leftColumnAlignment)
	            field.set(port.getValue("side.name"), row, 1, rightColumnAlignment)
	            row = row + 1

            if(detailedView) {

	}

}