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
import de.cau.cs.kieler.core.krendering.VerticalAlignment
import de.cau.cs.kieler.core.properties.IProperty
import de.cau.cs.kieler.core.krendering.KEllipse
import de.cau.cs.kieler.core.krendering.KContainerRendering

import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement
import static de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph.LGraphTransformation.*
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.klighd.krendering.PlacementUtil
import java.util.ArrayList
import de.cau.cs.kieler.klighd.debug.graphTransformations.KTextIterableField

class FNodeTransformation extends AbstractKielerGraphTransformation {
    float height
    float width
    
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
    @Inject
    extension KTextIterableField
    
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
            
            
            it.addTestNode(node)
            
            
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
            	it.childPlacement = renderingFactory.createKGridPlacement => [
            		it.numColumns = 1;
            	];
            	
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
        ]
    }
    
    def addTestNode(KNode rootNode, IVariable node) {
        
        val float leftMargin = 5
        val float topMargin = 5
        val float rightMargin = 5
        val float bottomMargin = 5 
        
        rootNode.children += createNode => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 1       

                val myKText = new KTextIterableField( topMargin, rightMargin, bottomMargin, leftMargin, 3, 3)
        
                myKText.set("My first Text", 0, 0)
                myKText.set("my last Text", 5, 5)
                myKText.set("1.111", 1, 1, LEFT_ALIGN)
                myKText.set("1.1", 2, 1, RIGHT_ALIGN)
                myKText.set("1.1", 3, 1, LEFT_ALIGN)
                myKText.set("3.3", 3, 3)
                myKText.set("4.4", 4, 4)
                
                it.addKText(myKText)
            ]
                            
            val  einz = node.getVariable("displacement")
            val  zwei = node.getVariable("label")
            val  drei = node.getVariable("position")
        
            it.children += createNodeById(einz) => [
                it.setNodeSize(15,15)
                it.data += renderingFactory.createKRectangle => [
                    it.lineWidth = 0
                ]
            ]
            
            it.children += createNodeById(zwei) => [
                it.setNodeSize(15,15)
                it.data += renderingFactory.createKRectangle => [
                    it.lineWidth = 0
                ]
            ] 

            it.children += createNodeById(drei) => [
                it.setNodeSize(15,15)
                it.data += renderingFactory.createKRectangle => [
                    it.lineWidth = 0
                ]
            ] 
            
            einz.createEdgeById(zwei) => [
                it.data += renderingFactory.createKPolyline => [
                    it.setLineWidth(2)
                    it.addArrowDecorator
                ]
            ]

            einz.createEdgeById(drei) => [
                it.data += renderingFactory.createKPolyline => [
                    it.setLineWidth(2)
                    it.addArrowDecorator
                ]
            ]

            zwei.createEdgeById(drei) => [
                it.data += renderingFactory.createKPolyline => [
                    it.setLineWidth(2)
                    it.addArrowDecorator
                ]
            ]
 
            it.children += createNode => [
                it.setNodeSize(15,15)
                it.data += renderingFactory.createKRectangle => [
                    it.lineWidth = 0
                ]
            ] 

            it.children += createNode => [
                it.setNodeSize(15,15)
                it.data += renderingFactory.createKRectangle => [
                    it.lineWidth = 0
                ]
            ] 

            it.children += createNode => [
                it.setNodeSize(15,15)
                it.data += renderingFactory.createKRectangle => [
                    it.lineWidth = 0
                ]
            ]                                     
        ]
    } 
}






