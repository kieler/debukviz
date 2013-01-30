package de.cau.cs.kieler.klighd.debug.graphTransformations.fGraph

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
import de.cau.cs.kieler.core.krendering.HorizontalAlignment
import de.cau.cs.kieler.core.properties.IProperty
import de.cau.cs.kieler.core.krendering.KEllipse
import de.cau.cs.kieler.core.krendering.KContainerRendering
import de.cau.cs.kieler.klay.planar.graph.*

import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement
import static de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph.LGraphTransformation.*
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions

class FNodeTransformation extends AbstractKielerGraphTransformation {
    
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
    
    /**
     * {@inheritDoc}
     */
    override transform(IVariable node, Object transformationInfo) {
        if(transformationInfo instanceof Boolean) detailedView = transformationInfo as Boolean

        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            
            // create KNode for given LNode
            it.createHeaderNode(node)
            
            // add nodes for propertyMap and ports, if in detailed mode
            if (detailedView) {
                // add propertyMap
                it.addPropertyMapAndEdge(node.getVariable("propertyMap"), node)
                
                //add node for ports
//                it.addPorts(node)
            }        

        ]
    }
    
    /**
     * As there is no writeDotGraph in FGraph we don't have a prototype for formatting the nodes
     */
    def createHeaderNode(KNode rootNode, IVariable node) { 
        rootNode.addNodeById(node) => [
            
            it.data += renderingFactory.createKRectangle => [
                it.headerNodeBasics(detailedView, node)
                
                // id of node
                it.addKText(node, "id", "", ": ")
                
                // label of node (there is only one)
                it.addKText(node, "label", "", ": ")
                
                if (detailedView) {
                    // parent
                    val parent = node.getVariable("parent")
                    it.children += renderingFactory.createKText => [
                        if(parent.valueIsNotNull) {
                            it.text = "parent: FNode " + parent.getValue("id") + " " + parent.getValue.getValueString
                        } else {
                            it.text = "parent: null"
                        }
                    ]
                    // displacement
                    it.children += renderingFactory.createKText => [
                        it.text = "displacement (x,y): (" + node.getValue("displacement.x").round + " x " 
                                                          + node.getValue("displacement.y").round + ")" 
                    ]
                    
                    // position
                    it.children += renderingFactory.createKText => [
                        it.text = "position (x,y): (" + node.getValue("position.x").round + " x " 
                                                      + node.getValue("position.y").round + ")" 
                    ]
                    
                    // size
                    it.children += renderingFactory.createKText => [
                        it.text = "size (x,y): (" + node.getValue("size.x").round + " x " 
                                                  + node.getValue("size.y").round + ")" 
                    ]
                }
            ]

//TODO: childArea verstehen
/*          val bla = renderingFactory.createKChildArea => [
                it.setBackgroundColor("cadetBlue1".color)
            ]
            it.data += bla
            
            
            it.children += node.getVariable("displacement").createNode => [
                it.setNodeSize(15,15)
                it.data += renderingFactory.createKRectangle => [
                    it.lineWidth = 4
                ]
            ]
*/        ]
    }
}















