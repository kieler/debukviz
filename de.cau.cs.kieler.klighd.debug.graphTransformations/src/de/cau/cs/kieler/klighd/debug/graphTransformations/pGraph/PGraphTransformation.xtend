package de.cau.cs.kieler.klighd.debug.graphTransformations.pGraph

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.LayoutOptions
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
import de.cau.cs.kieler.core.properties.IProperty
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.klighd.debug.graphTransformations.KTextIterableField

class PGraphTransformation extends AbstractKielerGraphTransformation {
    
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

                val graphNode = it.createNodes(graph)
                graphNode.createEdges(graph.getVariable("edges",false))
                            
                // create the faces visualization
                it.createFaces(graph)
                
            }
        ]
    }
    
    def createHeaderNode(KNode rootNode, IVariable graph) {
        rootNode.addNodeById(graph) => [
            it.data += renderingFactory.createKRectangle => [

                val field = new KTextIterableField(topGap, rightGap, bottomGap, leftGap, vGap, hGap)
                it.headerNodeBasics(field, detailedView, graph)
                var row = field.rowCount

                // id of graph
                field.set("id:", row, 0, leftColumnAlignment)
                field.set(nullOrValue(graph, "id"), row, 1, rightColumnAlignment)
                row = row + 1
                
                if(detailedView) {
                    // various graph variables
                    field.set("parent:", row, 0, leftColumnAlignment)
                    field.set(nullOrValue(graph, "parent"), row, 1, rightColumnAlignment)
                    row = row + 1
    
                    field.set("changedFaces:", row, 0, leftColumnAlignment)
                    field.set(nullOrValue(graph, "changedFaces"), row, 1, rightColumnAlignment)
                    row = row + 1
    
                    // external face
                    field.set("externalFace:", row, 0, leftColumnAlignment)
                    field.set(typeAndId(graph, "externalFace"), row, 1, rightColumnAlignment)
                    row = row + 1
    
                    field.set("faceIndex:", row, 0, leftColumnAlignment)
                    field.set(nullOrValue(graph, "faceIndex"), row, 1, rightColumnAlignment)
                    row = row + 1
    
                    field.set("edgeIndex:", row, 0, leftColumnAlignment)
                    field.set(nullOrValue(graph, "edgeIndex"), row, 1, rightColumnAlignment)
                    row = row + 1
    
                    field.set("nodeIndex:", row, 0, leftColumnAlignment)
                    field.set(nullOrValue(graph, "nodeIndex"), row, 1, rightColumnAlignment)
                    row = row + 1

                    // position
                    field.set("pos (x,y):", row, 0, leftColumnAlignment)
                    field.set("(" + graph.getValue("pos.x").round + " x " 
                                  + graph.getValue("pos.y").round + ")", row, 1, rightColumnAlignment)
                    row = row + 1
                    
                    // size
                    field.set("size (x,y):", row, 0, leftColumnAlignment)
                    field.set("(" + graph.getValue("size.x").round + " x " 
                                  + graph.getValue("size.y").round + ")", row, 1, rightColumnAlignment)
                    row = row + 1
    
                    // graph type
                    field.set("type:", row, 0, leftColumnAlignment)
                    field.set(graph.getValue("type.name"), row, 1, rightColumnAlignment)
                    row = row + 1
                }

                // fill the KText into the ContainerRendering
                for (text : field) {
                    it.children += text
                }
            ]
        ]
    }
    
    

    def createVisualization(KNode rootNode, IVariable graph) {
        
    }

    def createNodes(KNode rootNode, IVariable graph) {
        val nodes = graph.getVariable("nodes")
        
        // create outer nodes rectangle
        val KNode newNode = nodes.createNode => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
            ]

            // add label
            nodes.createLabel(it) => [
                it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::CENTER)
                it.setLabelSize(50,20)
                it.text = "visualization"
            ]

            // create all nodes
            nodes.getVariable("map").getVariables("table").filter[e | e.valueIsNotNull].forEach[IVariable node |
                it.children += nextTransformation(node.getVariable("key"))
            ]
        ]

        // create edge from root node to the nodes node
        graph.createEdge(nodes) => [
            it.data += renderingFactory.createKPolyline => [
                it.setLineWidth(2)
                it.addArrowDecorator
                it.setLineStyle(LineStyle::SOLID)
            ]
        ]
        // add nodes node to the surrounding element
        rootNode.children += newNode
        return newNode
    }

    def createEdges(KNode rootNode, IVariable edgesHashSet) {
        edgesHashSet.getVariables("map.table").filter[e | e.valueIsNotNull].forEach[IVariable e |
            val edge = e.getVariable("key")
            // get the bendPoints assigned to the edge
            val bendPoints = edge.getVariable("bendPoints")
            val bla = bendPoints.getValue("size")
            val bendCount = Integer::parseInt(bla)
            
            // IVariables the edge has to connect
            val source = edge.getVariable("source")
            var target = edge.getVariable("target")

            // true if edge is directed
            val isDirected = edge.getValue("isDirected").equals("true")
            
            // create bendPoint nodes
            if(bendCount > 0) {
                if(bendCount > 1) {
                    // more than one bendPoint: create a container node, containing the bendPoints
                    rootNode.children += bendPoints.createNode => [
                        // create container rectangle 
                        it.data += renderingFactory.createKRectangle() => [
                            it.lineWidth = 4
                        ]
                        // create all bendPoint nodes
                        bendPoints.linkedList.forEach[IVariable bendPoint |
                            it.createBendPoint(bendPoint)
                        ]
                    ]
                    // create the edge from the new created node to the target node
                    bendPoints.createEdge(target) => [
                        it.data += renderingFactory.createKPolyline => [
                            it.setLineWidth(2)
                            if (isDirected) {
                                it.addArrowDecorator
                            } else {
                                it.addInheritanceTriangleArrowDecorator
                            }
                            it.setLineStyle(LineStyle::SOLID)
                        ];
                    ]
                    // set target for the "default" edge to the new created container node
                    target = bendPoints  
                    
                } else {
                    // exactly one bendPoint, create a single bendPoint node
                    val bendPoint = bendPoints.linkedList.get(0)
                    rootNode.createBendPoint(bendPoint)
                    // create the edge from the new created node to the target node
                    bendPoint.createEdge(target) => [
                        it.data += renderingFactory.createKPolyline => [
                            it.setLineWidth(2)
                            it.addInheritanceTriangleArrowDecorator
                            it.setLineStyle(LineStyle::SOLID)
                        ]
                    ]
                    // set target for the "default" edge to the new created node
                    target = bendPoint                        
                }
            }
            // create first edge, from source to either new bendPoint or target node
            source.createEdge(target) => [
                it.data += renderingFactory.createKPolyline => [
                    it.setLineWidth(2)
                    if (isDirected) {
                        it.addArrowDecorator
                    } else {
                        it.addInheritanceTriangleArrowDecorator
                    }
                    it.setLineStyle(LineStyle::SOLID)
                ]
            ]
        ]
    }
    
    def createBendPoint(KNode rootNode, IVariable bendPoint) {
        bendPoint.createNode => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 2
                it.ChildPlacement = renderingFactory.createKGridPlacement

                // bendPoints are just KVectors, so give a speaking name here
                it.children += renderingFactory.createKText => [
                    it.text = "bendPoint"
                ]
                
                // position
                it.children += renderingFactory.createKText => [
                    it.text = "pos (x,y): (" + bendPoint.getValue("pos.x").round + " x " 
                                             + bendPoint.getValue("pos.y").round + ")" 
                ]
            ]
        ]        
    }

    def createFaces(KNode rootNode, IVariable graph) {
        val faces = graph.getVariable("faces")
        
        // create outer faces node
        faces.createNode => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
            ]
            
            // add label
            faces.createLabel(it) => [
                it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::CENTER)
                it.setLabelSize(50,20)
                it.text = "faces"
            ]
            
            val filteredFaces = faces.getVariable("map").getVariables("table").filter[e | e.valueIsNotNull]

            if (filteredFaces.size == 0) {
                // there are no faces, so create a small empty box
                it.setNodeSize(40,30)
            } else {
                //there are faces, so create nodes for all faces
                filteredFaces.forEach[IVariable face | it.children += nextTransformation(face.getVariable("key"))]
            }
        ]        
        // create edge from root node to the faces node
        graph.createEdge(faces) => [
            it.data += renderingFactory.createKPolyline => [
                it.setLineWidth(2)
                it.addArrowDecorator
                it.setLineStyle(LineStyle::SOLID)
            ]
        ]
    }
}