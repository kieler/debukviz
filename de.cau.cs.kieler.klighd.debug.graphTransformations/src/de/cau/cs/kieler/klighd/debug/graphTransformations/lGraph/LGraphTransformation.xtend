package de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.HorizontalAlignment
import de.cau.cs.kieler.core.krendering.LineStyle
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

class LGraphTransformation extends AbstractKielerGraphTransformation {
    
    @Inject
    extension KNodeExtensions
    @Inject 
    extension KPolylineExtensions 
    @Inject
    extension KRenderingExtensions
    @Inject
    extension KLabelExtensions
    
    val layoutAlgorithm = "de.cau.cs.kieler.kiml.ogdf.planarization"
    val spacing = 75f
    val leftColumnAlignment = HorizontalAlignment::RIGHT
    val rightColumnAlignment = HorizontalAlignment::LEFT
    val showPropertyMap = ShowTextIf::DETAILED
    val showVisulalization = ShowTextIf::DETAILED

    val showID = ShowTextIf::ALWAYS
    val showHashCode = ShowTextIf::ALWAYS
    val showHashCodeCounter = ShowTextIf::DETAILED
    val showSize = ShowTextIf::DETAILED
    val showInsets = ShowTextIf::DETAILED
    val showOffset = ShowTextIf::DETAILED
    val showNodesCount = ShowTextIf::COMPACT
    val showLayersCount = ShowTextIf::COMPACT
    
    /**
     * {@inheritDoc}
     */
	override transform(IVariable graph, Object transformationInfo) {
        detailedView = transformationInfo.isDetailed
        
        return KimlUtil::createInitializedNode => [
            it.addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            it.addLayoutParam(LayoutOptions::SPACING, spacing)

			it.addInvisibleRendering
     		it.addHeaderNode(graph)
     		
            // add propertyMap
            if(showPropertyMap.conditionalShow(detailedView))
                it.addPropertyMapNode(graph.getVariable("propertyMap"), graph)
                
            // create the graph visualization
            if(showVisulalization.conditionalShow(detailedView))
                it.createVisualization(graph)
        ]
	}
    
	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
	    var retVal = if(showPropertyMap.conditionalShow(detailedView)) 2 else 1
        if(showVisulalization.conditionalShow(detailedView)) retVal = retVal + 1
		return retVal
	}
	
	def addHeaderNode(KNode rootNode, IVariable graph) {
		rootNode.addNodeById(graph) => [
    		it.data += renderingFactory.createKRectangle => [

                val table = it.headerNodeBasics(detailedView, graph)
                
                // id of graph
                if(showID.conditionalShow(detailedView)) {
                    table.addGridElement("id:", leftColumnAlignment) 
                    table.addGridElement(graph.nullOrValue("id"), rightColumnAlignment) 
                }
                
                // hashCode of graph
                if(showHashCode.conditionalShow(detailedView)) {
                    table.addGridElement("hashCode:", leftColumnAlignment) 
                    table.addGridElement(graph.nullOrValue("hashCode"), rightColumnAlignment) 
                }
    			
                // hashCodeCounter of graph
                if(showHashCodeCounter.conditionalShow(detailedView)) {
                    table.addGridElement("hashCodeCounter:", leftColumnAlignment) 
                    table.addGridElement(graph.nullOrValue("hashCodeCounter.count"), rightColumnAlignment) 
                }

                // size of graph
                if(showSize.conditionalShow(detailedView)) {
                    table.addGridElement("size (x,y):", leftColumnAlignment) 
                    table.addGridElement(graph.nullOrSize(""), rightColumnAlignment) 
                }
                    
                // insets of graph
                if(showInsets.conditionalShow(detailedView)) {
                    table.addGridElement("insets (t,r,b,l):", leftColumnAlignment) 
                    table.addGridElement(graph.nullOrLInsets("insets"), rightColumnAlignment) 
                }

                // offset of graph
                if(showOffset.conditionalShow(detailedView)) {
                    table.addGridElement("offset (x,y):", leftColumnAlignment) 
                    table.addGridElement(graph.nullOrKVektor("offset"), rightColumnAlignment) 
                }

			    // # of nodes
                if(showNodesCount.conditionalShow(detailedView)) {
                    var count = Integer::parseInt(graph.getValue("layerlessNodes.size"))
                    for(layer : graph.getVariable("layers").linkedList) {
                        count = count + Integer::parseInt(layer.getValue("nodes.size"))
                    }
                    table.addGridElement("nodes (#):", leftColumnAlignment) 
                    table.addGridElement("" + count, rightColumnAlignment) 
                }

			    // # of layers
                if(showLayersCount.conditionalShow(detailedView)) {
                    table.addGridElement("layers (#):", leftColumnAlignment) 
                    table.addGridElement(graph.nullOrSize("layers"), rightColumnAlignment) 
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
          rootNode.nextTransformation(node, false)
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
    
    def getEdgeType(IVariable edge) {
    	val type = edge.getVariable("propertyMap").getValFromHashMap("EDGE_TYPE")
    	if (type == null) {
	        return "NORMAL"
    	} else {
	        return type.getValue("name")   
    	}
    }
}





