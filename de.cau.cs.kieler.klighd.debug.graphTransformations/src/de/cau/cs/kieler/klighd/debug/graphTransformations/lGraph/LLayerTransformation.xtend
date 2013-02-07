package de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.HorizontalAlignment
import de.cau.cs.kieler.core.krendering.VerticalAlignment
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

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
    val leftColumnAlignment = HorizontalAlignment::RIGHT
    val rightColumnAlignment = HorizontalAlignment::LEFT
    
    val showHashCode = ShowTextIf::DETAILED
    val showID = ShowTextIf::ALWAYS
    val showNodes = ShowTextIf::DETAILED
	val showOwner = ShowTextIf::DETAILED
    val showSize = ShowTextIf::DETAILED

	val showPropertyMap = ShowTextIf::DETAILED
	val showVisualization = ShowTextIf::DETAILED
        
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
            
            // add propertyMap
            if(detailedView.equals(showPropertyMap))  
            	it.addPropertyMapAndEdge(layer.getVariable("propertyMap"), layer)

            //add node for nodes of layer and add edges between the nodes of this layer
            if (detailedView.equals(showVisualization)) {
            	it.createNodesNode(layer)
            }
        ]
	}
	
	def createNodesNode(KNode rootNode, IVariable layer) {
		val nodes = layer.getVariable("nodes")
        return rootNode.addNodeById(nodes) => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
            ]
		    nodes.linkedList.forEach[IVariable node |
          		it.children += nextTransformation(node, false)
	        ]
	        // add the edges, if they are span between two nodes of this layer
	        nodes.linkedList.forEach[IVariable node |
	        	node.getVariable("ports").linkedList.forEach[IVariable port |
	        		port.getVariable("outgoingEdges").linkedList.forEach[IVariable edge |
	                    edge.getVariable("source.owner")
	                        .createEdgeById(edge.getVariable("target.owner")) => [
	        				it.data += renderingFactory.createKPolyline => [
		            		    it.setLineWidth(2)
	                            it.addArrowDecorator
	                            
	                            switch edge.edgeType {
	                                case "COMPOUND_DUMMY" : it.setLineStyle(LineStyle::DASH)
	                                case "COMPOUND_SIDE" : it.setLineStyle(LineStyle::DOT)
	                                default : it.setLineStyle(LineStyle::SOLID)
	                            }
	    	    			]
	        			]
	        		]
	        	]
	        ]
		layer.createTopElementEdge(nodes, "visualization")
        ]
    }

	def createHeaderNode(KNode rootNode, IVariable layer) {
        return rootNode.addNodeById(layer) => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
	            it.ChildPlacement = renderingFactory.createKGridPlacement => [
	                it.numColumns = 2
	            ]
	            it.setVerticalAlignment(VerticalAlignment::TOP)    	
	            it.setHorizontalAlignment(HorizontalAlignment::LEFT)    	

	
	            // id of layer
	            if (detailedView.equals(showID)) {
		            it.addGridElement("id:", leftColumnAlignment)
		            it.addGridElement(nullOrValue(layer, "id"), rightColumnAlignment)
	            } 
	   
                // hashCode of layer
	            if (detailedView.equals(showHashCode)) {
		            it.addGridElement("hashCode:", leftColumnAlignment)
		            it.addGridElement(layer.getValue("hashCode"), rightColumnAlignment)
	            }

	            // owner of layer
	            if (detailedView.equals(showOwner)) {
		            it.addGridElement("owner:", leftColumnAlignment)
		            it.addGridElement("LGraph " + layer.typeAndId("owner"), rightColumnAlignment)
	            }

	            // size of layer
	            if (detailedView.equals(showSize)) {
		            it.addGridElement("size (x, y):", leftColumnAlignment)
		            it.addGridElement(layer.getValue("size.x") + ", " + layer.getValue("size.y"), rightColumnAlignment)
				}
			]
		]
	}
}