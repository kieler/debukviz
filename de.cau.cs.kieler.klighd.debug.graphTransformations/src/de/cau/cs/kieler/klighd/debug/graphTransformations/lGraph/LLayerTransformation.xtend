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
import de.cau.cs.kieler.core.krendering.LineStyle

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
    
    val showHashCode = ShowTextIf::ALWAYS
    val showID = ShowTextIf::DETAILED
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
            if(detailedView.conditionalShow(showPropertyMap))  
            	it.addPropertyMapAndEdge(layer.getVariable("propertyMap"), layer)

            //add visualization containing nodes of layer and edges between the nodes of this layer
            if (detailedView.conditionalShow(showVisualization)) {
                it.createVisualization(layer)
            }
        ]
	}
	
	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
		return 0
	}

	/**
     * Creates a node containing a visualisation of the layer. It includes all nodes on the layer 
     * and all edges spanning between them. Also creates an edge from the node registered for 
     * {@code layer} to the new node.
     *  
     * @param rootNode
     *            the node the visualization node will be included in
     * @param layer
     *            the layer to be visualized
     * @return the new created node
     */
	def createVisualization(KNode rootNode, IVariable layer) {
		val nodes = layer.getVariable("nodes")
		
        return rootNode.addNodeById(nodes) => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
            ]
            // add all nodes
		    nodes.linkedList.forEach[IVariable node |
          		it.nextTransformation(node, false)
	        ]
	        
	        // add the edges, if they are span between two nodes of this layer
	        nodes.linkedList.forEach[IVariable node |
	        	node.getVariable("ports").linkedList.forEach[IVariable port |
	        		port.getVariable("outgoingEdges").linkedList.forEach[IVariable edge |
	        			
	        			// verify that the current edge has to be created
	        			val target = edge.getVariable("target.owner")
	        			if(nodes.containsValWithID(target.valueString)) {
		                    node.createEdgeById(target) => [
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
	        			}
	        		]
	        	]
	        ]
        // create edge from node registered to layer to the new node
		layer.createTopElementEdge(nodes, "visualization")
        ]
    }

	def createHeaderNode(KNode rootNode, IVariable layer) {
        return rootNode.addNodeById(layer) => [
            it.data += renderingFactory.createKRectangle => [

                val table = it.headerNodeBasics(detailedView, layer)
	
	            // id of layer
	            if (detailedView.conditionalShow(showID)) {
		            table.addGridElement("id:", leftColumnAlignment)
		            table.addGridElement(nullOrValue(layer, "id"), rightColumnAlignment)
	            } 
	   
                // hashCode of layer
	            if (detailedView.conditionalShow(showHashCode)) {
		            table.addGridElement("hashCode:", leftColumnAlignment)
		            table.addGridElement(layer.getValue("hashCode"), rightColumnAlignment)
	            }

	            // owner of layer
	            if (detailedView.conditionalShow(showOwner)) {
		            table.addGridElement("owner:", leftColumnAlignment)
		            table.addGridElement(layer.typeAndId("owner"), rightColumnAlignment)
	            }

	            // size of layer
	            if (detailedView.conditionalShow(showSize)) {
		            table.addGridElement("size (x, y):", leftColumnAlignment)
		            table.addGridElement(layer.getValue("size.x") + ", " + layer.getValue("size.y"), rightColumnAlignment)
				}
			]
		]
	}
	
    def getEdgeType(IVariable edge) {
    	val type = edge.getVariable("propertyMap").getValFromHashMap("EDGE_TYPE")
    	if (type == null) {
	        return "NORMAL"
    	} else {
	        return type.getValue("name")   
    	}
    }
}