package de.cau.cs.kieler.klighd.debug.graphTransformations.pGraph

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
import de.cau.cs.kieler.core.properties.IProperty
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation

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
    
    /**
     * {@inheritDoc}
     */
    override transform(IVariable graph, Object transformationInfo) {
        return KimlUtil::createInitializedNode=> [
            it.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.klay.layered")
            it.addLayoutParam(LayoutOptions::SPACING, 75f)
            
            it.createHeaderNode(graph)
            val graphNode = it.createNodes(graph)

            graphNode.createEdges(graph.getVariable("edges",false))
                            
            it.createFaces(graph)
        ]
    }
    
    def createHeaderNode(KNode rootNode, IVariable graph) {
        rootNode.children += graph.createNode => [
//          it.setNodeSize(120,80)
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
                it.backgroundColor = "lemon".color
                it.ChildPlacement = renderingFactory.createKGridPlacement

                // type of graph
                it.children += renderingFactory.createKText => [
                    it.setForegroundColor(120,120,120)
                    it.text = graph.getType
                ]
                
                // name of variable
                it.children += renderingFactory.createKText => [
                    it.text = "VarName: " + graph.name 
                ]

                // various graph variables
                it.children += createKText(graph, "faceIndex", "", ": ")
                it.children += createKText(graph, "changedFaces", "", ": ")
                it.children += createKText(graph, "externalFace", "", ": ")
                it.children += createKText(graph, "edgeIndex", "", ": ")
                it.children += createKText(graph, "nodeIndex", "", ": ")
                it.children += createKText(graph, "parent", "", ": ")
                
                // position
                it.children += renderingFactory.createKText => [
                    it.text = "pos (x,y): (" + graph.getValue("pos.x").round(1) + " x " 
                                              + graph.getValue("pos.y").round(1) + ")" 
                ]
                
                // size
                it.children += renderingFactory.createKText => [
                    it.text = "size (x,y): (" + graph.getValue("size.x").round(1) + " x " 
                                              + graph.getValue("size.y").round(1) + ")" 
                ]

                // graph type
                it.children += renderingFactory.createKText => [
                    it.text = "type: " + graph.getValue("type.name")
                ]
            ]
        ]
    }

    def createNodes(KNode rootNode, IVariable graph) {
        val nodes = graph.getVariable("nodes")
        
        // create outer nodes rectangle
        val KNode newNode = nodes.createNode => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
            ]
            it.addLabel("Graph visualization")
            // create all nodes
            nodes.getVariable("map").getVariables("table").filter[e | e.valueIsNotNull].forEach[IVariable node |
                it.nextTransformation(node.getVariable("key"))
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
                    it.text = "pos (x,y): (" + bendPoint.getValue("pos.x").round(1) + " x " 
                                             + bendPoint.getValue("pos.y").round(1) + ")" 
                ]
            ]
        ]        
    }

    def createFaces(KNode rootNode, IVariable graph) {
        val faces = graph.getVariable("faces")
        // create outer faces node
        faces.createNode => [
            // create outer faces rectangle
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
            ]
            it.addLabel("Faces")
            
            val filteredFaces = faces.getVariable("map").getVariables("table").filter[e | e.valueIsNotNull]

            if (filteredFaces.size == 0) {
                // there are no faces, so create a small empty box
                it.setNodeSize(40,30)
            } else {
                //there are faces, so create nodes for all faces
                filteredFaces.forEach[IVariable face | it.nextTransformation(face.getVariable("key"))]
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