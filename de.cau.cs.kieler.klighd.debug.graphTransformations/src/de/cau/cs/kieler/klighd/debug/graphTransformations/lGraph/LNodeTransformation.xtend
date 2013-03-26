/*
 * KIELER - Kiel Integrated Environment for Layout Eclipse RichClient
 *
 * http://www.informatik.uni-kiel.de/rtsys/kieler/
 * 
 * Copyright 2013 by
 * + Christian-Albrechts-University of Kiel
 *   + Department of Computer Science
 *     + Real-Time and Embedded Systems Group
 * 
 * This code is provided under the terms of the Eclipse Public License (EPL).
 * See the file epl-v10.html for the license text.
 */
 package de.cau.cs.kieler.klighd.debug.graphTransformations.lGraph

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.HorizontalAlignment
import de.cau.cs.kieler.core.krendering.KContainerRendering
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.debug.graphTransformations.AbstractKielerGraphTransformation
import de.cau.cs.kieler.klighd.debug.graphTransformations.ShowTextIf
import javax.inject.Inject
import org.eclipse.debug.core.model.IVariable

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*

/*
 * Transformation for an IVariable representing a LNode.
 * 
 * @ author tit
 */
 class LNodeTransformation extends AbstractKielerGraphTransformation {
	@Inject 
    extension KNodeExtensions
    @Inject
    extension KRenderingExtensions
    
    /** The layout algorithm to use. */
    val layoutAlgorithm = "de.cau.cs.kieler.kiml.ogdf.planarization"
    /** The spacing to use. */
    val spacing = 75f
    /** The horizontal alignment for the left column of all grid layouts. */
    val leftColumnAlignment = HorizontalAlignment::RIGHT
    /** The horizontal alignment for the right column of all grid layouts. */
    val rightColumnAlignment = HorizontalAlignment::LEFT

    /** Specifies when to show the property map. */
    val showPropertyMap = ShowTextIf::DETAILED
    /** Specifies when to show the ports node. */
    val showPorts = ShowTextIf::DETAILED

    /** Specifies when to show the size. */
    val showName = ShowTextIf::ALWAYS
    /** Specifies when to show the size. */
    val showSize = ShowTextIf::DETAILED
    /** Specifies when to show the position. */
    val showPos = ShowTextIf::DETAILED
    /** Specifies when to show the margin. */
    val showMargin = ShowTextIf::DETAILED
    /** Specifies when to show the insets. */
    val showInsets = ShowTextIf::DETAILED
    /** Specifies when to show the owner. */
    val showOwner = ShowTextIf::ALWAYS
    /** Specifies when to show the id. */
    val showID = ShowTextIf::ALWAYS
    /** Specifies when to show the hashCode. */
    val showHashCode = ShowTextIf::ALWAYS
    /** Specifies when to show the number of ports. */
    val showPortsCount = ShowTextIf::COMPACT
    /** Specifies when to show the number of labels. */
    val showLabelsCount = ShowTextIf::COMPACT
    
    /**
     * {@inheritDoc}
     */
    override transform(IVariable node, Object transformationInfo) {
        detailedView = transformationInfo.isDetailed
        
        return KimlUtil::createInitializedNode => [
            addLayoutParam(LayoutOptions::ALGORITHM, layoutAlgorithm)
            addLayoutParam(LayoutOptions::SPACING, spacing)

			addInvisibleRendering
            addHeaderNode(node)
            
            // add propertyMap
            if(showPropertyMap.conditionalShow(detailedView))
                addPropertyMapNode(node.getVariable("propertyMap"), node)
                
            //add node for ports
            if(showPorts.conditionalShow(detailedView))
                addPortsNode(node)
        ]
    }

	/**
	 * {@inheritDoc}
	 */
	override getNodeCount(IVariable model) {
	    var retVal = if(showPropertyMap.conditionalShow(detailedView)) 2 else 1
	    if(showPorts.conditionalShow(detailedView)) retVal = retVal + 1
		return retVal
	}
    
    /**
     * Creates the header node containing basic informations for this element and adds it to the rootNode.
     * 
     * @param rootNode
     *              The KNode the new created KNode will be placed in.
     * @param edge
     *              The IVariable representing the node transformed in this transformation.
     * 
     * @return The new created header KNode.
     */
     def addHeaderNode(KNode rootNode, IVariable node) {
        rootNode.addNodeById(node) => [
            // Get the nodeType
            val nodeType = node.nodeType
            var KContainerRendering container

            var KContainerRendering table
            
            if (nodeType == "NORMAL" ) {
                /*
                 * Normal nodes. (If nodeType is null, the default type is taken, which is "NORMAL")
                 *  - are represented by an rectangle  
                 */ 
                 container = renderingFactory.createKRectangle
                 table = container.headerNodeBasics(detailedView, node)
            } else {
                /*
                 * Dummy nodes.
                 *  - are represented by an ellipses
                 *  - if they are a "NORTH_SOUTH_PORT"-node, and the origin is a LNode:
                 *    add first label of origin as text
                 */
                container = renderingFactory.createKEllipse
                table = container.headerNodeBasics(detailedView, node)

                val origin = node.getVariable("propertyMap").getValFromHashMap("origin")
                table.addGridElement("origin:", leftColumnAlignment) 
                if (nodeType == "NORTH_SOUTH_PORT" && origin.getType == "LNode") {
                    table.addGridElement("" + origin.getVariable("labels").linkedList.get(0), rightColumnAlignment) 
                } else {
                    table.addGridElement("" + origin.nullOrTypeAndID(""), rightColumnAlignment) 
                }
            }

            container.setForegroundColor(node)

            // name of node
            if(showName.conditionalShow(detailedView)) {
                // Name of the node is the first label
                val labels = node.getVariable("labels").linkedList
                var labelText = ""
                if(labels.isEmpty) {
                    // no name given
                    labelText = "(null)"
                } else {
                    val label = labels.get(0).getValue("text")
                    if(label.length == 0) {
                        labelText = "\"\""
                    } else {
                        labelText = label
                    }
                }
                if(!detailedView) {
                    labelText = labelText + node.getValueString
                }
                table.addGridElement("name:", leftColumnAlignment) 
                table.addGridElement(labelText, rightColumnAlignment) 
            }

            // id of node
            if(showID.conditionalShow(detailedView)) {
                table.addGridElement("id:", leftColumnAlignment) 
                table.addGridElement(node.nullOrValue("id"), rightColumnAlignment) 
            }

            //owner (layer)
            if(showOwner.conditionalShow(detailedView)) {
                table.addGridElement("owner:", leftColumnAlignment) 
                table.addGridElement(node.nullOrTypeAndHashAndIDs("owner"), rightColumnAlignment) 
            }

            // hashCode of node
            if(showHashCode.conditionalShow(detailedView)) {
                table.addGridElement("hashCode:", leftColumnAlignment) 
                table.addGridElement(node.nullOrValue("hashCode"), rightColumnAlignment) 
            }

            // insets
            if(showInsets.conditionalShow(detailedView)) {
                table.addGridElement("insets (b,l,r,t):", leftColumnAlignment) 
                table.addGridElement(node.nullOrLInsets("insets"), rightColumnAlignment)
            }
                
            //margin
            if(showMargin.conditionalShow(detailedView)) {
                table.addGridElement("margin (b,l,r,t):", leftColumnAlignment) 
                table.addGridElement(node.nullOrLInsets("margin"), rightColumnAlignment)
            }

            // position
            if(showPos.conditionalShow(detailedView)) {
                table.addGridElement("pos (x,y):", leftColumnAlignment) 
                table.addGridElement(node.nullOrKVektor("pos"), rightColumnAlignment)
            }
                
            // size
            if(showSize.conditionalShow(detailedView)) {
                table.addGridElement("size (x,y):", leftColumnAlignment) 
                table.addGridElement(node.nullOrKVektor("size"), rightColumnAlignment)
            }

            // # of labels
            if(showLabelsCount.conditionalShow(detailedView)) {
                table.addGridElement("labels (#):", leftColumnAlignment) 
                table.addGridElement(node.nullOrSize("labels"), rightColumnAlignment) 
            }

            // # of ports
            if(showPortsCount.conditionalShow(detailedView)) {
                table.addGridElement("ports (#):", leftColumnAlignment) 
                table.addGridElement(node.nullOrSize("ports"), rightColumnAlignment) 
            }

            // add the node-symbol to the surrounding KNode
            data += container
        ]
    }
    
    /**
     * Creates a node containing all ports of this node and creates an edge from header node to it.
     * 
     * @param rootNode
     *              The KNode the new created KNode will be placed in.
     * @param node
     *              The IVariable representing the node transformed in this transformation.
     * 
     * @return The new created KNode.
     */
     def addPortsNode(KNode rootNode, IVariable node) {
        val ports = node.getVariable("ports")

        // create a node (ports) containing the port elements
        val newNode = rootNode.addNodeById(ports) => [
            val rendering = renderingFactory.createKRectangle => [ rendering |
                data += rendering
                if(detailedView) rendering.lineWidth = 4 else rendering.lineWidth = 2
            ]
            
            if (ports.getValue("size").equals("0")) {
                // there are no ports
                rendering.addKText("(none)")
            } else {
                // create all ports
                ports.linkedList.forEach [ port |
                    nextTransformation(port, false)
                ]
            }
        ]
        // create edge from header node to ports node
        node.createTopElementEdge(ports, "ports")
        
        return newNode 
    }
    
    /**
     * Sets the foreground color of the given rendering depending on the type of the node.
     * 
     *  original values from de.cau.cs.kieler.klay.layered.properties.NodeType:
     *  case "COMPOUND_SIDE": return "#808080"
     *  case "EXTERNAL_PORT": return "#cc99cc"
     *  case "LONG_EDGE": return "#eaed00"
     *  case "NORTH_SOUTH_PORT": return "#0034de"
     *  case "LOWER_COMPOUND_BORDER": return "#18e748"
     *  case "LOWER_COMPOUND_PORT": return "#2f6d3e"
     *  case "UPPER_COMPOUND_BORDER": return "#fb0838"
     *  case "UPPER_COMPOUND_PORT": return "#b01d38"
     *  default: return "#000000"
     *  coding: #RGB", where each component is given as a two-digit hexadecimal value.
     * 
     * @param rendering
     *              The KContainerRending those foreground color shall be set.
     * @param node
     *              The IVariable representing a LNode those type will define the color. 
     */
     def void setForegroundColor(KContainerRendering rendering, IVariable node) {
        val type = node.nodeType
        switch (type) {
            case "COMPOUND_SIDE": rendering.setForegroundColor(128,128,128)
            case "EXTERNAL_PORT": rendering.setForegroundColor(204,153,204)
            case "LONG_EDGE": rendering.setForegroundColor(234,237,0)
            case "NORTH_SOUTH_PORT": rendering.setForegroundColor(0,52,222)
            case "LOWER_COMPOUND_BORDER": rendering.setForegroundColor(24,231,72)
            case "LOWER_COMPOUND_PORT": rendering.setForegroundColor(47,109,62)
            case "UPPER_COMPOUND_BORDER": rendering.setForegroundColor(251,8,56)
            case "UPPER_COMPOUND_PORT": rendering.setForegroundColor(176,29,56)
            default: rendering.setForegroundColor(0,0,0)
        }
    }
    
    /**
     * Returns the type of node, or <code>NORMAL</code>, if no type is given in the propertyMap.
     * 
     * @param node
     *              The node those type shall be returned.
     * @return The type of the node.
     * 
     */    
    def getNodeType(IVariable node) {
    	val map =  node.getVariable("propertyMap")
        val type = map.getValFromHashMap("nodeType")
        if (type == null) {
            return "NORMAL"
        } else {
            return type.getValue("name")   
        }
    }
}