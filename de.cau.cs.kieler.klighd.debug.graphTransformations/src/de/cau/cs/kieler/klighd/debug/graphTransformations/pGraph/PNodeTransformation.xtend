package de.cau.cs.kieler.klighd.debug.graphTransformations.pGraph

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.KContainerRendering
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.KlighdDebugPlugin
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable
import org.eclipse.ui.plugin
import org.eclipse.jface.preference

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

class PNodeTransformation extends AbstractKielerGraphTransformation {
    
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

    val showFaces = ShowTextIf::DETAILED
    val showPropertyMap = ShowTextIf::DETAILED
    val showVisualization = ShowTextIf::DETAILED
    val showType = ShowTextIf::DETAILED
    val showPosition = ShowTextIf::DETAILED
    val showNodeIndex = ShowTextIf::DETAILED
    val showEdgeIndex = ShowTextIf::DETAILED
    val showFaceIndex = ShowTextIf::DETAILED
    val showExternalFaces = ShowTextIf::DETAILED
    val showChangedFaces = ShowTextIf::DETAILED
    val showParent = ShowTextIf::DETAILED      

    val store = KlighdDebugPlugin::getDefault()
    val prefStore = store.getPreferenceStore()
    val flat = prefStore.getString(KlighdDebugPlugin::LAYOUT).equals(KlighdDebugPlugin::FLAT_LAYOUT)
    
    /**
     * {@inheritDoc}
     */
    override transform(IVariable node, Object transformationInfo) {
    if(transformationInfo instanceof Boolean) detailedView = transformationInfo as Boolean

        return KimlUtil::createInitializedNode => [
        
            it.addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            it.addLayoutParam(LayoutOptions::SPACING, spacing)
            
            // create KNode for given LNode
            it.createHeaderNode(node)

            // add propertyMap
            if(detailedView.conditionalShow(showPropertyMap))
                it.addPropertyMapAndEdge(node.getVariable("propertyMap"), node)
        ]
    }
    
    def createHeaderNode(KNode rootNode, IVariable node) {
        rootNode.addNodeById(node) => [
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
            
            container.headerNodeBasics(detailedView, node)
/*
            // PNodes don't have a name or labels
            // id of node
            field.set("id:", row, 0, leftColumnAlignment)
            field.set(nullOrValue(node, "id"), row, 1, rightColumnAlignment)
            row = row + 1

            // position
            field.set("pos (x,y):", row, 0, leftColumnAlignment)
            field.set("(" + node.getValue("pos.x").round + ", " 
                          + node.getValue("pos.y").round + ")", row, 1, rightColumnAlignment)
            row = row + 1
            
            // size
            field.set("size (x,y):", row, 0, leftColumnAlignment)
            field.set("(" + node.getValue("size.x").round + ", " 
                          + node.getValue("size.y").round + ")", row, 1, rightColumnAlignment)
            row = row + 1

            // fill the KText into the ContainerRendering
            for (text : field) {
                container.children += text
            }
  */           
            it.data += container
        ]
    }
                

	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
		return 0
	}
}