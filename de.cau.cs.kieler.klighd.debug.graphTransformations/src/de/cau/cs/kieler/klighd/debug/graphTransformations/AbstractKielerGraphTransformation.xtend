package de.cau.cs.kieler.klighd.debug.graphTransformations

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.KContainerRendering
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation
import de.cau.cs.kieler.klighd.krendering.PlacementUtil
import java.util.LinkedList
import javax.inject.Inject
import org.eclipse.debug.core.DebugException
import org.eclipse.debug.core.model.IVariable
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.core.krendering.HorizontalAlignment
import de.cau.cs.kieler.core.krendering.VerticalAlignment

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*
import de.cau.cs.kieler.core.krendering.KGridPlacementData
import de.cau.cs.kieler.core.krendering.LineStyle

abstract class AbstractKielerGraphTransformation extends AbstractDebugTransformation {
	
    @Inject
    extension KNodeExtensions
//    @Inject
//    extension KEdgeExtensions
    @Inject 
    extension KPolylineExtensions 
    @Inject
    extension KRenderingExtensions
    @Inject
    extension KColorExtensions
    @Inject
    extension KLabelExtensions
	@Inject 
    extension KEdgeExtensions
    
    val topGap = 4
    val rightGap = 7
    val bottomGap = 5
    val leftGap = 4
    val vGap = 3
    val hGap = 5
    
//    protected GraphTransformationInfo gtInfo = new GraphTransformationInfo
    protected Boolean detailedView = true

	def conditionalShow(boolean isDetailed, ShowTextIf enum) {
		if (enum == ShowTextIf::ALWAYS) {
			return true
		} else {
			return (isDetailed == (enum == ShowTextIf::DETAILED))
		}
	}
	
	def createTopElementEdge(IVariable source, IVariable target, String label) {
	    // create edge from header node to visualization
        source.createEdgeById(target) => [
            it.data += renderingFactory.createKPolyline => [
                it.setLineWidth(2)
                it.addArrowDecorator
                it.setLineStyle(LineStyle::SOLID)
            ]
            target.createLabel(it) => [
                it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::CENTER)
                it.setLabelSize(50,20)
                it.text = label
        	]
        ]   
	}
    
    def hashMapToLinkedList(IVariable variable) throws DebugException {
        val retVal = new LinkedList<IVariable>
        for ( v : variable.getVariables("table")) {
            if (v.valueIsNotNull) {
                retVal.add(v)
                var next = v.getVariable("next")
                while(next.valueIsNotNull) {
                	retVal.add(next)
                	next = next.getVariable("next")
            	}
            }
    	}
    	return retVal
    }
    
    def linkedHashSetToLinkedList(IVariable variable) throws DebugException {
        val size = Integer::parseInt(variable.getValue("map.size"))
        val retVal = new LinkedList<IVariable>
        if (size > 0) {
            var next = variable.getVariable("map.header.after") 
            for (i : 1..size) {
                retVal.add(next.getVariable("key"))
                next = next.getVariable("after")
            }
        }
        return retVal
    }
    
    def round(String number, int decimalPositions) {
        return Math::round(Double::valueOf(number) * Math::pow(10, decimalPositions)) 
                    / Math::pow(10, decimalPositions)
    }
    
    def round(String number) {
        return Math::round(Double::valueOf(number))
    }
    
    /**
     * Constructs a LinkedList<IVariable> from an IVariable that is containing a LinkedList
     * 
     * @param list
     *            The IVariable that is containing the LinkedList
     * @return A LinkedList with all elements of the input variable
     * @throws NumberFormatException
     * @throws DebugException
     */
    def linkedList(IVariable list) throws NumberFormatException, DebugException {
        val size = Integer::parseInt(list.getValue("size"))
        var retVal = new LinkedList<IVariable>
        var variable = list.getVariable("header")
        var i = 0
        
        while (i < size) {
            variable = variable.getVariable("next")
            retVal.add(variable.getVariable("element"))
            i = i + 1
        }
        return retVal;
    }
    
    /**
     * Returns the value mapped to a key, out of a IVariable that is representing a HashMap
     * 
     * @param hashMap
     *            The IVariable representing the HashMap
     * @param key
     *            The key to look up
     * @return The value to which the specified key is mapped, null if the specified key is not
     *         found
     * @throws NumberFormatException
     * @throws DebugException
     */
    def getValFromHashMap(IVariable hashMap, String key) throws NumberFormatException, DebugException {
        var vars = hashMap.getVariables("table")
        
        // go through all top level entries
        for (v : vars) {
            if (v.valueIsNotNull) {
                if (v.getValue("key.id").equals(key)) {
                    return v.getVariable("value")
                } else {
                    // go through all "next" entries of the top level entry
                    var next = v.getVariable("next")
                    while(next.valueIsNotNull) {
                        if (next.getValue("key.id").equals(key)) {
                            return next.getVariable("value")
                        } 
                        next = next.getVariable("next")
                    }
                }
            }
        }
        // key not found
        return null
    }
    
    def String keyString(IVariable key) {
        switch key.getType {
            case "Property<T>" : 
                return key.getValue("id") + ":"
            case "LayoutOptionData<T>" : 
                return key.getValue("name") + ":"
            case "KNodeImpl" :
                return "KNode" + key.getValueString + " -> "
            case "KPortImpl" :
                return "KPort" + key.getValueString + " -> "
        }
        // a default statement in the switch results in a missing return statement in generated 
        // java code, so I added the default return value here
        return "<? " + key.getType +" ?> : "
    }

    def addPropertyMapAndEdge(KNode rootNode, IVariable propertyMap, IVariable headerNode) {
        if(rootNode != null && headerNode.valueIsNotNull) {
	            // create propertyMap node
	            rootNode.addNodeById(propertyMap) => [
	                it.data += renderingFactory.createKRectangle => [
	                    it.lineWidth = 4
						if(propertyMap.valueIsNotNull) {
		 					it.addHashValueElement(propertyMap)
						} else {
							it.addGridElement("null", HorizontalAlignment::CENTER)
						}
	                ]
	            ]
	
	            //create edge from header to propertyMap node
	            headerNode.createEdgeById(propertyMap) => [
	                it.data += renderingFactory.createKPolyline => [
	                    it.setLineWidth(2)
	                    it.addArrowDecorator
	                ]
	                
	                // add label to edge
	                propertyMap.createLabel(it) => [
	                    it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::CENTER)
	                    it.text = "propertyMap"
	                    val dim = PlacementUtil::estimateTextSize(it)
	                    it.setLabelSize(dim.width,dim.height)
	                ]
	            ]
        }
    }
    
    def addHashValueElement(KContainerRendering container, IVariable element) {
        switch element.getType {
             case "HashMap<K,V>" : {
                if(element.valueIsNotNull) {
                    val childs = element.hashMapToLinkedList

                    if (childs.size == 0) {
                    	container.addGridElement("(empty)", HorizontalAlignment::RIGHT)
                    } else {
						// create a new invisible rectangle containing the key and value rectangles
                        val hashContainer = container.addInvisibleRectangleGrid(2) 
//                        		it.setGridPlacementData(0f, 0f,
//                        			createKPosition(LEFT, 5f, 0f, TOP, 5f, 0f),
//                        			createKPosition(RIGHT, 5f, 0f, BOTTOM, 5f, 0f)
//                        		)

		                // add all child elements
                        for (child : childs) {
                        	// add the key
                        	hashContainer.addGridElement(child.getVariable("key").keyString, HorizontalAlignment::RIGHT)
                        	
                        	// add the value
                        	hashContainer.addHashValueElement(child.getVariable("value"))
                        }
                    }
                 } else {
                	// hashTable is null
                	container.addGridElement("(null)", HorizontalAlignment::LEFT)
                }
            }
            case "RegularEnumSet<E>" : 
                	container.addEnumSet(element)
            case "NodeGroup" :                 	
				container.addGridElement("(TODO)", HorizontalAlignment::LEFT)
            case "KNodeImpl" :
            	container.addGridElement("KNode " + element.getValueString, HorizontalAlignment::LEFT)
            case "KLabelImpl" :
            	container.addGridElement("KLabel " + element.getValueString, HorizontalAlignment::LEFT)
            case "KEdgeImpl" :
            	container.addGridElement("KEdge " + element.getValueString, HorizontalAlignment::LEFT)
            case "LNode" :
            	container.addGridElement("LNode " + element.getValue("id") + element.getValueString, 
            		HorizontalAlignment::LEFT
            	)
            case "LPort" :
            	container.addGridElement("LPort " + element.getValue("id") + element.getValueString, 
            		HorizontalAlignment::LEFT
            	)
            case "LEdge" :
            	container.addGridElement("LEdge " + element.getValue("id") + element.getValueString, 
            		HorizontalAlignment::LEFT
            	)
            case "Random" :
            	container.addGridElement("seed " + element.getValue("seed.value"), 
            		HorizontalAlignment::LEFT
            	)
        	case "NodeType" :
        		container.addGridElement(element.getValue("name"), HorizontalAlignment::LEFT)
            case "String" :
            	container.addGridElement(element.getValueString, HorizontalAlignment::LEFT)
            case "Direction" :
            	container.addGridElement(element.getValue("name"), HorizontalAlignment::LEFT)
            case "Boolean" :
            	container.addGridElement(element.getValue("value"), HorizontalAlignment::LEFT)
            case "Float" :
            	container.addGridElement(element.getValue("value"), HorizontalAlignment::LEFT)
            case "PortConstraints" :
            	container.addGridElement(element.getValue("name"), HorizontalAlignment::LEFT)
            case "EdgeLabelPlacement" :
            	container.addGridElement(element.getValue("name"), HorizontalAlignment::LEFT)
            default : {
            	container.addGridElement("<? " + element.getType + element.getValueString + "?>",
            		HorizontalAlignment::LEFT
            	)
            }
        }
    }
    
    def addEnumSet(KContainerRendering container, IVariable set) {
        // the mask representing the elements that are set
        val elemMask = Integer::parseInt(set.getValue("elements"))
        
        if (elemMask == 0) {
            return container.addGridElement("(none)", HorizontalAlignment::LEFT)
        } else {
            val hashContainer = container.addInvisibleRectangleGrid(1)

            // the elements available
            val elements = set.getVariables("universe")

            var i = 0
            // go through all elements and check if corresponding bit is set in elemMask
            while(i < elements.size) {
                var mask = Integer::parseInt(elements.get(i).getValue("ordinal")).pow2
                if(elemMask.bitwiseAnd(mask) > 0) {
                    // bit is set 
                    hashContainer.addGridElement(elements.get(i).getValue("name"), HorizontalAlignment::LEFT)
                }
                i = i +1
            }
            return hashContainer
        }
    }
    
    
    def addGridElement(KContainerRendering container, String text, HorizontalAlignment align) {
        return renderingFactory.createKText => [
            container.children += it
            it.text = text
        	it.setVerticalAlignment(VerticalAlignment::TOP)
    		it.setHorizontalAlignment(align)
    		it.setGridPlacementData(0f, 0f,
    			createKPosition(LEFT, 5f, 0f, TOP, 3f, 0f),
    			createKPosition(RIGHT, 5f, 0f, BOTTOM, 3f, 0f)
    		)
		];
    }
    
    def addInvisibleRectangleGrid(KContainerRendering container, int columns) {
		return renderingFactory.createKRectangle => [
        	container.children += it
            it.setInvisible(true)
            it.ChildPlacement = renderingFactory.createKGridPlacement => [
                it.numColumns = columns
            ]
            it.setVerticalAlignment(VerticalAlignment::TOP)    	
            it.setHorizontalAlignment(HorizontalAlignment::LEFT)    	
    	]
    }
    
    /**
     * adds a KText element to a KContainerRendering element for each option in a EnumSet, that is 
     * contained in the given IVariable 
     * 
     * @param container
     *            The KContainerRendering element the KTexts will be added to
     * @param set
     *            The IVariable containing the EnumSet to check
     */
    def enumSetToKText(KContainerRendering container, IVariable set, String prefix) {
        // the mask representing the elements that are set
        val elemMask = Integer::parseInt(set.getValue("elements"))
        if (elemMask == 0) {
            // no elements set at all
            container.children += renderingFactory.createKText => [
                it.text = prefix + "(none)"
            ] 
        } else {
            // the elements available
            val elements = set.getVariables("universe")
            var i = 0
            // go through all elements and check if corresponding bit is set in elemMask
            while(i < elements.size) {
                var mask = Integer::parseInt(elements.get(i).getValue("ordinal")).pow2
                if(elemMask.bitwiseAnd(mask) > 0) {
                    // bit is set 
                    val text = renderingFactory.createKText 
                    text.text = prefix + elements.get(i).getValue("name")
                    container.children += text 
                }
                i = i + 1
            }
        }
    }
    
    /**
     * returns 2^j 
     * 
     * @param j
     *            The exponent
     * @return
     *            The result of 2^j
     */
    def int pow2(int j) {
        if (j == 0) {
            return 1
        } else {
            var retVal = 2
            var i = 1
            while (i < j) {
                retVal = retVal * 2
                i = i + 1
            }
            return retVal
        }
    }
    
    /**
     * add a (gray colored) KText to the container, representing the short version of the type of the variable
     * 
     * @param container
     *          The KContainerRendering the KText will be added to
     * @param variable
     *          The IVariable whose type will be added
     */
    def shortType(IVariable variable) {
        return renderingFactory.createKText => [
            it.setForegroundColor(120,120,120)
            it.text = variable.getType
        ]    
    }
    
    def getValueString(IVariable variable) {
        return variable.getValue.getValueString
    }
    
    def headerNodeBasics(KContainerRendering container, Boolean detailedView, IVariable variable) {
        
        container.ChildPlacement = renderingFactory.createKGridPlacement => [
            it.numColumns = 1
        ]
        container.setVerticalAlignment(VerticalAlignment::TOP)    	
        container.setHorizontalAlignment(HorizontalAlignment::LEFT)
//		container.setGridPlacementData(0f, 0f,
//    			createKPosition(LEFT, 5f, 0f, TOP, 5f, 0f),
//    			createKPosition(RIGHT, 5f, 0f, BOTTOM, 5f, 0f)
//		)

        // type of the variable: create a rectangle for this to center the text
        if (detailedView) {
            val header = container.addInvisibleRectangleGrid(1) 
        	header.addGridElement(variable.getType, HorizontalAlignment::CENTER)
    	}

		// create the rectangle with grid layout containing the other variables to display
        val table = container.addInvisibleRectangleGrid(2) 

        if(detailedView) {
        // bold line in detailed view
        container.lineWidth = 4
        
        // name of the variable
        table.addGridElement("Variable:", HorizontalAlignment::RIGHT) => [
    		it.setFontBold(true)
        ] 
        table.addGridElement(variable.name + variable.getValueString, HorizontalAlignment::LEFT) => [ 
    		it.setFontBold(true)
        ] 

        // coloring of main element
        container.setBackground("lemon".color);
        } else {
            // slim line in not detailed view
            container.lineWidth = 2
        }
        return table
    }
    
    /**
     * deprecated
     */
    def headerNodeBasics(KContainerRendering container, KTextIterableField field, Boolean detailedView, 
    			IVariable variable, KTextIterableField$TextAlignment leftColumn, 
    								KTextIterableField$TextAlignment rightColumn) {
        if(detailedView) {
            // bold line in detailed view
            container.lineWidth = 4
            
            // type of the variable
            field.setHeader(variable.shortType)

            // name of the variable
            val text1 = renderingFactory.createKText => [
            	it.text = "Variable:"
	    		it.setFontBold(true)
            ]
            val text2 = renderingFactory.createKText => [
            	it.text = variable.name + variable.getValueString
	    		it.setFontBold(true)
            ]
            
            field.set(text1, field.rowCount, 0, leftColumn) 
            field.set(text2, field.rowCount - 1, 1, rightColumn) 

            // coloring of main element
            container.setBackground("lemon".color);
        } else {
            // slim line in not detailed view
            container.lineWidth = 2
        }
    }
    
    def addKText(KContainerRendering container, String text) {
        return renderingFactory.createKText => [
            container.children += it
            it.text = text
        ]        
    }
    
    def addKText(KContainerRendering container, KTextIterableField kTextField) {
        kTextField.forEach [
            container.children += it
        ]
    }
    
    def addKText(KContainerRendering container, IVariable variable, String valueText, String prefix, String delimiter) {
        return renderingFactory.createKText => [
            it.text = prefix + valueText + delimiter + nullOrValue(variable, valueText)
            container.children += it
        ]
    }
    
    def typeAndId(IVariable iVar, String variable) {
        val v = if(variable.equals("")) iVar else iVar.getVariable(variable)
        return v.type + " " + v.getValueString
    }

    def nullOrValue(IVariable variable, String valueName) {
            if (variable.valueIsNotNull) {
                return variable.getValue(valueName)
            } else {
                return "null"
            }
    }
    
    def containsValWithID(IVariable list, String id) {
    	for(elem : list.linkedList) {
    		if (id.equals(elem.getValueString)) return true
    	}
    	return false
    }
    

}
