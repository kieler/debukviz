package de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.LineStyle
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*
import de.cau.cs.kieler.klighd.debug.graphTransformations.KTextIterableField

class LGraphTransformation extends AbstractKielerGraphTransformation {
    
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
	override transform(IVariable graph, Object transformationInfo) {
        if(transformationInfo instanceof Boolean) detailedView = transformationInfo as Boolean
        
        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            it.addLayoutParam(LayoutOptions::SPACING, spacing)
            
            // create header node
     		it.createHeaderNode(graph)
     		
     		// add the propertyMap and visualization, if in detailed mode
      		if (detailedView) {
                // add propertyMap
                it.addPropertyMapAndEdge(graph.getVariable("propertyMap"), graph)
                
                // create the visualization
                it.createVisualization(graph)
    
            }
        ]
	}
	
	def createHeaderNode(KNode rootNode, IVariable graph) {
		rootNode.addNodeById(graph) => [
    		it.data += renderingFactory.createKRectangle => [

                val field = new KTextIterableField(topGap, rightGap, bottomGap, leftGap, vGap, hGap)
                it.headerNodeBasics(field, detailedView, graph, leftColumnAlignment, rightColumnAlignment)
                var row = field.rowCount
                
                // id of graph
                field.set("id:", row, 0, leftColumnAlignment)
                field.set(nullOrValue(graph, "id"), row, 1, rightColumnAlignment)
                row = row + 1
                
                // hashCode of graph
                field.set("hashCode:", row, 0, leftColumnAlignment)
                field.set(nullOrValue(graph, "hashCode"), row, 1, rightColumnAlignment)
                row = row + 1
    			
    			if(detailedView) {
                    // hashCodeCounter of graph
                    field.set("hashCodeCounter:", row, 0, leftColumnAlignment)
                    field.set(graph.getValue("hashCodeCounter.count"), row, 1, rightColumnAlignment)
                    row = row + 1
                    
                    // size of graph
                    // size
                    field.set("size (x,y):", row, 0, leftColumnAlignment)
                    field.set("(" + graph.getValue("size.x").round + " x " 
                                  + graph.getValue("size.y").round + ")", row, 1, rightColumnAlignment)
                    row = row + 1
                    
                    // insets of graph
                    field.set("insets (t,r,b,l):", row, 0, leftColumnAlignment)
                    field.set("(" + graph.getValue("insets.top").round + " x "
                                  + graph.getValue("insets.right").round + " x "
                                  + graph.getValue("insets.bottom").round + " x "
                                  + graph.getValue("insets.left").round + ")", row, 1, rightColumnAlignment)
                    row = row + 1

                    // offset of graph
                    field.set("offset (x,y):", row, 0, leftColumnAlignment)
                    field.set("(" + graph.getValue("offset.x").round + " x " 
                                  + graph.getValue("offset.y").round + ")", row, 1, rightColumnAlignment)
                    row = row + 1
    			} else {
    			    // # of nodes
                    var count = Integer::parseInt(graph.getValue("layerlessNodes.size"))
                    for(layer : graph.getVariable("layers").linkedList) {
                        count = count + Integer::parseInt(layer.getValue("nodes.size"))
                    }
                    field.set("nodes (#):", row, 0, leftColumnAlignment)
                    field.set("" + count, row, 1, rightColumnAlignment)
                    row = row + 1

    			    // # of layers
                    field.set("layers (#):", row, 0, leftColumnAlignment)
                    field.set(graph.getValue("layers.size"), row, 1, rightColumnAlignment)
    			}

                // fill the KText into the ContainerRendering
                for (text : field) {
                    it.children += text
                }
            ]
		]
	}

    // create a node (visualization) containing the graphical visualisation of the LGraph
	def createVisualization(KNode rootNode, IVariable graph) {
		val visualization = graph.getVariable("layerlessNodes")
		
        rootNode.addNodeById(visualization) => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
            ]
            
            // create all nodes (layerless and layered)
	  		it.createNodes(graph.getVariable("layerlessNodes"))
	  		for (layer : graph.getVariable("layers").linkedList) {
	  		    it.createNodes(layer.getVariable("nodes"))
	  		}

            // create all edges
            // first for all layerlessNodes ...
            it.createEdges(graph.getVariable("layerlessNodes"))
            // ... then iterate through all layers
            graph.getVariable("layers").linkedList.forEach[IVariable layer |
                it.createEdges(layer.getVariable("nodes"))   
            ]
  		]
  		
	    // create edge from header node to visualization
        graph.createEdgeById(visualization) => [
            it.data += renderingFactory.createKPolyline => [
                it.setLineWidth(2)
                it.addArrowDecorator
                it.setLineStyle(LineStyle::SOLID)
            ]
            visualization.createLabel(it) => [
                it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::CENTER)
                it.setLabelSize(50,20)
                it.text = "visualization"
            ]
        ]   
	}
	
	def createNodes(KNode rootNode, IVariable nodes) {
	    nodes.linkedList.forEach[IVariable node |
          rootNode.children += nextTransformation(node, false)
        ]
	}

    def createEdges(KNode rootNode, IVariable layer) {
        layer.linkedList.forEach[IVariable node |
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
    }
    
//TODO: defaultwert ist wohl überflüssig... !?!
    def getEdgeType(IVariable edge) {
    	val type = edge.getVariable("propertyMap").getValFromHashMap("EDGE_TYPE")
    	if (type == null) {
	        return "NORMAL"
    	} else {
	        return type.getValue("name")   
    	}
    }
}





