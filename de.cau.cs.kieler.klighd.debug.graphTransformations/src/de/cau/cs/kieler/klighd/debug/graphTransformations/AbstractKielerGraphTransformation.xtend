package de.cau.cs.kieler.klighd.debug.graphTransformations

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.HorizontalAlignment
import de.cau.cs.kieler.core.krendering.KContainerRendering
import de.cau.cs.kieler.core.krendering.LineStyle
import de.cau.cs.kieler.core.krendering.VerticalAlignment
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.klighd.debug.KlighdDebugPlugin
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation
import de.cau.cs.kieler.klighd.krendering.PlacementUtil
import java.util.LinkedList
import javax.inject.Inject
import org.eclipse.debug.core.DebugException
import org.eclipse.debug.core.model.IVariable
import org.eclipse.jdt.debug.core.IJavaArray

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*
import de.cau.cs.kieler.core.kgraph.KEdge
import de.cau.cs.kieler.klighd.krendering.PlacementUtil
import org.eclipse.jdt.debug.core.IJavaObject

/**
 * A class containing many helper functions for the transformation of graphs of the KIELER project.
 * To ensure a uniform layout, all transformation classes should extend this class instead 
 * of AbstractDebugTransformation and use the helper functions.
 * 
 * @author tit
 */
abstract class AbstractKielerGraphTransformation extends AbstractDebugTransformation {
	
    @Inject 
    extension KPolylineExtensions 
    @Inject
    extension KRenderingExtensions
    @Inject
    extension KColorExtensions
    @Inject
    extension KLabelExtensions
    
    val leftColumnAlignment = HorizontalAlignment::RIGHT
    val rightColumnAlignment = HorizontalAlignment::LEFT
    val topGap = 1
    val rightGap = 7
    val bottomGap = 0
    val leftGap = 5
    val vGap = 2
    val hGap = 5
    
    protected Boolean detailedView = true

    /**
     * Checks if the detailed representation shall be used. Returns:
     * <ul>
     *   <li> If the layout option in the preference page is  set to 'FLAT_LAYOUT' : false</li>
     *   <li> If parameter 'info' is not an instance of Boolean : false</li>
     *   <li> Otherwise: the value of parameter 'info'</li>
     * </ul>
     * @param info 
     *              An Boolean value indicating if the detailed representation shall be used. This can
     *              be, for example, the debugTransformationInfo of a transformation.
     * @return True if the detailed representation shall be used, false otherwise.  
     */
    def boolean isDetailed(Object info) {
        val flat = KlighdDebugPlugin::getDefault().getPreferenceStore().getString(KlighdDebugPlugin::LAYOUT).equals(KlighdDebugPlugin::FLAT_LAYOUT)
        if(info instanceof Boolean) {
            return (!flat && info as Boolean)
        } else {
            return !flat
        }
    }
    
    /**
     * Helper function to decide if a given graph element has to be rendered
     * 
     * @param showTextIf 
     *              An element of the showTextIf enumeration
     * @param isDetailed 
     *              The boolean detailedView variable
     * @return True, if the given element has to be rendered, false otherwise
     */
    def conditionalShow(ShowTextIf showTextIf, boolean isDetailed) {
        if (showTextIf == ShowTextIf::ALWAYS) {
            return true
        } else if (showTextIf == ShowTextIf::NEVER) {
        	return false
        } else {
            return (isDetailed == (showTextIf == ShowTextIf::DETAILED))
        }
    }
    
    /**
     * creates an edge from source to target, adds the label to the center of the edge and formats the edge
     * Use it to create the edges in the detailed view to ensure uniform layout  
     * 
     * @param source 
     *              The IVariable connected to the source KNode
     * @param target 
     *              The IVariable connected to the target KNode
     * @param label
     *              The label added to the center of the edge
     * @return The created edge
     */	
	def createTopElementEdge(IVariable source, IVariable target, String label) {
		// only create an edge if both (source and target) have an node registered to 
		if(source.nodeExists && target.nodeExists) {
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
	}
	
    /**
     * Constructs a LinkedList<IVariable> from an IVariable that is containing a hashSet.
     * 
     * @param variable 
     *              The IVariable representing the hashSet.
     * @return The linkedList of elements.
     */ 
	def hashSetToLinkedList(IVariable variable) throws DebugException {
		val retVal = new LinkedList<IVariable>
		for (v : variable.getVariables("map.table")) {
            if (v.valueIsNotNull) {
                retVal.add(v.getVariable("key"))
                var next = v.getVariable("next")
                while(next.valueIsNotNull) {
                	retVal.add(next.getVariable("next"))
                	next = next.getVariable("next")
            	}
            }
    	}
    	return retVal
	}
	
    /**
     * Constructs a LinkedList<IVariable> from an IVariable that is containing a hashMap. 
     * Please note that the returned elements are representing HashMapEntries, so you have to check it's
     * key and value child elements to get the real values.
     * 
     * @param variable 
     *              The IVariable representing the hashMap.
     * @return The linkedList of HashMapEntries.
     */ 
    def hashMapToLinkedList(IVariable variable) throws DebugException {
        val retVal = new LinkedList<IVariable>
        for (v : variable.getVariables("table")) {
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
    
    /**
     * Constructs a LinkedList<IVariable> from an IVariable that is containing a linkedHashSet. 
     * 
     * @param variable 
     *              The IVariable representing the linkedHashSet.
     * @return The linkedList of elements.
     */ 
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
    
    /**
     * Rounds the given number to the given number of decimal places. The number will be commercially rounded.  
     * 
     * @param number 
     *              The number to round in String format.
     * @param decimalPositions 
     *              The number to decimal places.
     * @return The rounded number in double format.
     */ 
    def round(String number, int decimalPositions) {
        return Math::round(Double::valueOf(number) * Math::pow(10, decimalPositions)) 
                    / Math::pow(10, decimalPositions)
    }
    
    /**
     * Rounds the given number to zero decimal places. The number will be commercially rounded.  
     * 
     * @param number 
     *              The number to round in String format.
     * @return The rounded number in long format.
     */ 
     def round(String number) {
        return Math::round(Double::valueOf(number))
    }
    
    /**
     * A convenience function to convert a given IVariable to a linkedList of it's elements.
     * Supported types (that the IVariable may represent):  
     *  - HashSet
     *  - LinkedHashSet
     *  - LinkedList
     *  - ArrayList
     * 
     * @param variable 
     *              The IVariable representing the structure to convert.
     * @return The linkedList of elements. If the type of the underlying structure is not in the list aboth,
     *              null will be returned.
     */ 
     def toLinkedList(IVariable variable) throws DebugException {
        val index = variable.getType.indexOf("<")
        println("index: " + index)
        if (index > 0) {
            val type = variable.getType.substring(0, index)
            println("substring: " + type)
        	switch type {
        		case "HashSet":
        			return hashSetToLinkedList(variable)
    			case "LinkedHashSet":
    				return linkedHashSetToLinkedList(variable)
    			case "LinkedList":
    				return linkedList(variable)
    			case "ArrayList":
    				return arrayListToLinkedList(variable)
        	}
        } 
    	println("Type not supported by 'toLinkedList': " + variable.getType)
    	return null
    }
    
    /**
     * Converts an IVariable representing a arrayList to a linkedlist of it's elements.
     * 
     * @param variable 
     *              The IVariable representing the arrayList.
     * @return The linkedList of elements.
     */ 
    def arrayListToLinkedList(IVariable variable) throws DebugException {
    	val retVal = new LinkedList<IVariable>
    	val size = Integer::parseInt(variable.getValue("size"))
    	variable.getVariables("elementData").subList(0, size).forEach [
    		retVal.add(it)
    	]
    	return retVal
    }
    
    /**
     * Constructs a LinkedList<IVariable> from an IVariable that is containing a LinkedList.
     * 
     * @param list
     *            The IVariable representing the LinkedList.
     * @return The linkedList of elements.
     */
    def linkedList(IVariable list) {
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
     *            The IVariable representing the HashMap.
     * @param key
     *            The key to look up.
     * @return The value to which the specified key is mapped, null if the specified key is not
     *         found.
     */
    def getValFromHashMap(IVariable hashMap, String key) {
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
    
    /**
     * Creates a more convenient String for key values of the propertyMap:
     * Property<T> -> value of id
     * LayoutOptionData<T> -> value of name
     * KNodeImpl -> KNode
     * KPortImpl -> KPort
     * others -> <? 'type' ?>
     * 
     * @param key
     *            IVariable to convert
     * @return The string according to the table aboth.
     */
    def String keyString(IVariable key) {
        switch key.getType {
            case "Property<T>" : 
                return key.getValue("id") + ":"
            case (key.getVariable("name") != null) : {
                return key.getValue("name") + ":"
            }
        }
        // a default statement in the switch results in a missing return statement in generated 
        // java code, so I added the default return value here
        return key.getType + ":"
    }

    /**
     * Adds a visualization of the propertyMap to the rootNode and adds an edge from the headerNode to 
     * the created node.
     * 
     * @param rootNode
     *            The KNode the visualization will be added to
     * @param propertyMap
     *            The IVariable representing the propertyMap
     * @param headerNode
     *            The IVariable representing the headerNode from which an edge will be created.
     * @return The new created KNode.
     */
    def addPropertyMapNode(KNode rootNode, IVariable propertyMap, IVariable headerNode) {
        if(rootNode != null && headerNode.valueIsNotNull) {
            // create propertyMap node
            rootNode.addNodeById(propertyMap) => [
                it.data += renderingFactory.createKRectangle => [
                    it.lineWidth = 4
					if(propertyMap.valueIsNotNull) {
	 					it.addValueElement(propertyMap)
					} else {
						it.addGridElement("null", HorizontalAlignment::CENTER)
					}
                ]
            ]

            //create edge from header to propertyMap node (if there is a node registered to the header)
            if (headerNode.nodeExists) {
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
    }
    
    /**
     * Returns the type of the value of the given variable in a simple form.
     * This function overrides the function from AbstractDebugTransformation and adds support for 
     * nested types. The parent type will also be excluded from the result string.  
     * 
     * @param variable
     *            type of the value of this variable will be returned
     * @return type of the value of variable
     * @throws DebugException
     */
    override getType(IVariable variable) throws DebugException {
        val type = variable.getValue().getReferenceTypeName();
        val a = type.lastIndexOf('.')
        val b = type.lastIndexOf('$')
        return type.substring(Math::max(a,b) + 1)
    }
    
    /**
     * Adds an value element (right side of table) to the container rendering.
     * 
     * @param container
     *            The container rendering the new element will be added to.
     * @param element
     *            The element to add.
     * @return The new created KRendering.
     */
    def addValueElement(KContainerRendering container, IVariable element) {
        switch element.getType {
            case (element.getValue instanceof IJavaArray) : {
                // element is an array
                val myArray = element.getValue.getVariables
                if(myArray.size == 0) {
                    container.addGridElement(element.type + " (empty)", rightColumnAlignment)
                } else {
                    val arrayContainer = container.addInvisibleRectangleGrid(1)
                    myArray.forEach [arrayContainer.addValueElement(it)]
                }
            }
            case "HashMap<K,V>" : {
                if(element.valueIsNotNull) {
                    val childs = element.hashMapToLinkedList

                    if (childs.size == 0) {
                    	container.addGridElement("(empty)", leftColumnAlignment)
                    } else {
						// create a new invisible rectangle containing the key and value rectangles
                        val hashContainer = container.addInvisibleRectangleGrid(2) 

		                // add all child elements
                        for (child : childs) {
                        	hashContainer.addGridElement(child.getVariable("key").keyString, leftColumnAlignment)
                        	hashContainer.addValueElement(child.getVariable("value"))
                        }
                    }
                 } else {
                	// hashTable is null
                	container.addGridElement("(null)", rightColumnAlignment)
                }
            }
            case "RegularEnumSet<E>" : 
            	container.addEnumSet(element)
			case "ArrayList<E>" : 
				container.addArrayList(element)
			case "LinkedList<E>" :
                container.addLinkedList(element)
            case "Pair<F,S>" :
                container.addPair(element)
            case "KNodeImpl" :
                container.addGridElement("KNode" + element.getValueString, rightColumnAlignment)
            case "KPortImpl" :  
                container.addGridElement("KPort" + element.getValueString, rightColumnAlignment)
            case "PNode" :
                container.addGridElement("PNode" + element.getValueString, rightColumnAlignment)
            case "PEdge" :
                container.addGridElement("PEdge" + element.getValueString, rightColumnAlignment)
            case "KNodeImpl" :
            	container.addGridElement("KNode " + element.getValueString, rightColumnAlignment)
            case "KPortImpl" :
            	container.addGridElement("KPort " + element.getValueString, rightColumnAlignment)
            case "KLabelImpl" :
            	container.addGridElement("KLabel " + element.getValueString, rightColumnAlignment)
            case "KEdgeImpl" :
            	container.addGridElement("KEdge " + element.getValueString, rightColumnAlignment)
            case "LGraph" :
                container.addGridElement("LGraph " + element.getValue("id") + element.getValueString, 
                    rightColumnAlignment
                )
            case "LNode" :
                container.addGridElement("LNode " + element.getValue("id") + element.getValueString, 
                    rightColumnAlignment
                )
            case "LPort" :
            	container.addGridElement("LPort " + element.getValue("id") + element.getValueString, 
            		rightColumnAlignment
            	)
            case "LEdge" :
            	container.addGridElement("LEdge " + element.getValue("id") + element.getValueString, 
            		rightColumnAlignment
            	)
            case "Random" :
            	container.addGridElement("seed " + element.getValue("seed.value"), rightColumnAlignment)
            case "String" :
            	container.addGridElement(element.getValueString, rightColumnAlignment)
            case "OrthogonalRepresentation" : {
                val hashContainer = container.addInvisibleRectangleGrid(2)
                element.getValue.getVariables.forEach [ elem |
                    hashContainer.addGridElement(elem.name, leftColumnAlignment) 
                    hashContainer.addValueElement(elem)
                ]
        	}
        	case "NodeGroup" :
        	   container.addValueElement(element.getVariable("nodes"))
            // element is a primitive data type
            case (!(element.getValue instanceof IJavaObject)) : {
                container.addGridElement(element.getValue("value"), rightColumnAlignment)
            }
            // two more general cases, if element has got a name or value field, display it's value
            // name is used e.g. by all enumeration types
            // value is used e.g. by Integer, Boolean ...
            case (element.getVariable("name") != null) : {
                container.addGridElement(element.getValue("name"), rightColumnAlignment)
            }
            case (element.getVariable("value") != null) : {
                container.addGridElement(element.getValue("value"), rightColumnAlignment)
            }
            default : {
            	container.addGridElement("<?? " + element.getType + element.getValueString + "??>",
            		rightColumnAlignment
            	)
            }
        }
    }
    
    /**
     * Adds an invisible KRendering rectangle to the KNode. 
     * 
     * @param node
     *            The KNode the rectangle will be added to.
     * @return The new created KRectangle.
     */
    def addInvisibleRendering(KNode node) {
        return renderingFactory.createKRectangle => [
    		node.data += it 
            it.invisible = true
        ]
    }
    
    
    /**
     * Adds all elements of an IVariable, representing a linkedList, to a given KContainerRendering.
     * If more than one value is in the list, a invisible KRegtangle will be created, containing all
     * Values in vertical order.
     * 
     * @param container
     *            The KContainerRendering the representation will be added to.
     * @param list
     *            The IVariable representing the list.
     * @return The new created KRendering.
     */
    def addPair(KContainerRendering container, IVariable pair) {
        val pairContainer = container.addInvisibleRectangleGrid(3)
        pairContainer.addGridElement("Pair:", leftColumnAlignment)
        pairContainer.addGridElement("first:", leftColumnAlignment)
        pairContainer.addValueElement(pair.getVariable("first"))
        pairContainer.addBlankGridElement
        pairContainer.addGridElement("second:", leftColumnAlignment)
        pairContainer.addValueElement(pair.getVariable("second"))
    }

    
    /**
     * Adds all elements of an IVariable, representing a linkedList, to a given KContainerRendering.
     * If more than one value is in the list, a invisible KRegtangle will be created, containing all
     * Values in vertical order.
     * 
     * @param container
     *            The KContainerRendering the representation will be added to.
     * @param list
     *            The IVariable representing the list.
     * @return The new created KRendering.
     */
    def addLinkedList(KContainerRendering container, IVariable list) {
        return(container.addArrayList(list))
    }


    /**
     * Adds all elements of an IVariable, representing an arrayList, to a given KContainerRendering.
     * If more than one value is in the list, a invisible KRegtangle will be created, containing all
     * Values in vertical order.
     * 
     * @param container
     *            The KContainerRendering the representation will be added to.
     * @param list
     *            The IVariable representing the list.
     * @return The new created KRendering.
     */
    def addArrayList(KContainerRendering container, IVariable list) {
        var llist = list.toLinkedList 
        if (llist.size == 0) {
            return container.addGridElement("(none)", rightColumnAlignment)
        } else {
            val arrayContainer = container.addInvisibleRectangleGrid(1)
            
            llist.forEach[arrayContainer.addValueElement(it)]
            return arrayContainer
        }
    }

    /**
     * Adds all elements of an IVariable, representing an enumSet, to a given KContainerRendering.
     * If more than one value is in the set, a invisible KRegtangle will be created, containing all
     * Values in vertical order.
     * 
     * @param container
     *            The KContainerRendering the representation will be added to.
     * @param list
     *            The IVariable representing the set.
     * @return The new created KRendering.
     * 
     * @author tit
     */
    def addEnumSet(KContainerRendering container, IVariable set) {
        // the mask representing the elements that are set
        val elemMask = Integer::parseInt(set.getValue("elements"))
        
        if (elemMask == 0) {
            return container.addGridElement("(none)", rightColumnAlignment)
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
                    hashContainer.addValueElement(elements.get(i))
                }
                i = i +1
            }
            return hashContainer
        }
    }

    /** 
     * Adds a invisible KRegtangle to the given KContainerRendering. Can be used as a blank field in an
     * gridLayout.
     * 
     * @param container
     *            The KContainerRendering the rectangle will be added to.
     * @return The new created KRectangle.
     * 
     * @author tit
     */
    def addBlankGridElement(KContainerRendering container) {
        return renderingFactory.createKRectangle => [
    		container.children += it 
            it.invisible = true
        ]
    }
    
    /**
     * Adds a KText to a KContainerRendering, formatted according to the parameters.
     * 
     * @param container
     *            The KContainerRendering the rectangle will be added to.
     * @param text
     *            The text of the KText.
     * @param align
     *            The horizontal alignment of the KText.
     * @return The new created KText.
     * 
     * @author tit
     */
    def addGridElement(KContainerRendering container, String text, HorizontalAlignment align) {
        return renderingFactory.createKText => [
            container.children += it
            it.text = text
        	it.setVerticalAlignment(VerticalAlignment::TOP)
    		it.setHorizontalAlignment(align)
    		it.setGridPlacementData(0f, 0f,
    			createKPosition(LEFT, leftGap, 0f, TOP, topGap, 0f),
    			createKPosition(RIGHT, rightGap, 0f, BOTTOM, bottomGap, 0f)
    		)
		]
    }
    
    /**
     * Adds a invisible KRectangle containing a GridLayout with the specified numbers of columns to 
     * a given KContainerRendering. 
     * 
     * @param container
     *            The KContainerRendering the rectangle will be added to.
     * @param columns
     *            The number of columns of the created grid. 
     * @return The new created KRectangle.
     * 
     * @author tit
     */
    def addInvisibleRectangleGrid(KContainerRendering container, int columns) {
		return renderingFactory.createKRectangle => [
        	container.children += it
            it.setInvisible(true)
            it.ChildPlacement = renderingFactory.createKGridPlacement => [
                it.numColumns = columns
            ]

            it.setVerticalAlignment(VerticalAlignment::TOP)    	
            it.setHorizontalAlignment(rightColumnAlignment)    	
    	]
    }
    
    /**
     * Returns 2^j 
     * 
     * @param j
     *            The exponent
     * @return
     *            The result of 2^j
     * 
     * @author tit
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
     * 
     * @author tit
     */
    def shortType(IVariable variable) {
        return renderingFactory.createKText => [
            it.setForegroundColor(120,120,120)
            it.text = variable.getType
        ]    
    }
    
    /**
     * Returns the valueString of the IValue of an IVariable.
     * Hint: if variable is a non base type this will return the debug-id. 
     * 
     * @param variable
     *            The IVariable those valueString will be returned.
     * @return The valueString.
     * 
     * @author tit
     */
    def getValueString(IVariable variable) {
        return variable.getValue.getValueString
    }
    
    /**
     * Adds basic formating to a header node. Also adds a two column gridLayout and fills it with 
     * the (represented) type and name of the IVariable. 
     * 
     * @param container
     *            The KContainerRendering that is representing the header node and will be modified.
     * @param detailedView
     *            If true, the border will be bold and the (represented) type of the IVariable will be added. 
     * @param variable
     *            The variable linked to the containerRendering.
     * @return A invisible KRectangle added to the container which contains a two column gridLayout.
     * 
     * @author tit
     */
    def headerNodeBasics(KContainerRendering container, Boolean detailedView, IVariable variable) {
        
        container.ChildPlacement = renderingFactory.createKGridPlacement => [
            it.numColumns = 1
        ]
        container.setVerticalAlignment(VerticalAlignment::TOP)    	
        container.setHorizontalAlignment(rightColumnAlignment)

        // type of the variable, centered
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
        table.addGridElement("Variable:", leftColumnAlignment) => [
    		it.setFontBold(true)
        ] 
        table.addGridElement(variable.name + variable.getValueString, rightColumnAlignment) => [ 
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
     * deprecated : please use headerNodeBasics(KContainerRendering, Boolean, IVariable) instead.
     * 
     * @author tit
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
    
    /**
     * Convenient method to add a KText element to the KContainerRendering.
     * 
     * @param container
     *            The KContainerRendering the KText will be added to.
     * @param text
     *            The text of the KText. 
     * @return the new created KText
     * 
     * @author tit
     */
    def addKText(KContainerRendering container, String text) {
        return renderingFactory.createKText => [
            container.children += it
            it.text = text
        ]        
    }
    

    /**
     * Convenient method for nullOrTypeAndID(IVariable, String) with an empty String.
     * Returns a string representation of type and debug-id of the given IVariable.
     * 
     * @param variable
     *            The IVariable to display.
     * @return Either "'Type' ('debug-id')" of variable, or String "(null)". 
     * 
     * @author tit
     */
    def nullOrTypeAndID(IVariable variable) {
    	return nullOrTypeAndID(variable, "")
    }
    
    /**
     * Returns a string representation of type and debug-id of the IVariable on specified path.
     * 
     * @param variable
     *            The root IVariable element.
     * @param fieldPath
     *            The relative path from the root IVariable to the IVariable to inspect.  
     * @return Either "'Type' ('debug-id')" of variable, or String "(null)".
     * 
     * @author tit
     */
    def nullOrTypeAndID(IVariable variable, String fieldPath) {
        if (variable.valueIsNotNull) {
        	val v = if(fieldPath.equals("")) variable else variable.getVariable(fieldPath)
        	if (v.valueIsNotNull) {
	    		return v.type + " " + v.getValueString
        	}
    	}
    	return "(null)"
    }

    /**
     * Returns either the value of the IValue on path or "(null)".
     * 
     * @param variable
     *            The root IVariable element.
     * @param fieldPath
     *            The relative path from the root IVariable to the IValue to inspect.  
     * @return Either the value of the IValue, or String "(null)".
     * 
     * @author tit
     */
    def nullOrValue(IVariable variable, String fieldPath) {
        if (variable.valueIsNotNull) {
            return variable.getValue(fieldPath)
        } else {
            return "(null)"
        }
    }
    
    /**
     * Returns either the value of the IVariable on path or "(null)".
     * IVariable must represent a KVektor and the format will be "('x', 'y')".
     * 
     * @param variable
     *            The root IVariable element.
     * @param fieldPath
     *            The relative path from the root IVariable to the IValue to inspect.  
     * @return Either the value of the IValue representing a KVektor, or String "(null)".
     * 
     * @author tit
     */
    def nullOrKVektor(IVariable variable, String fieldPath) {
        if (variable.valueIsNotNull) {
            return "(" + variable.getValue(fieldPath + ".x").round(1) + ", " 
                       + variable.getValue(fieldPath + ".y").round(1) + ")"
        } else {
            return "(null)"
        }
    }
    
    /**
     * Returns either the value of the IVariable on path or "(null)".
     * IVariable must represent a LInsets and the format will be "('top', 'right', 'bottom', 'left')".
     * 
     * @param variable
     *            The root IVariable element.
     * @param fieldPath
     *            The relative path from the root IVariable to the IValue to inspect.  
     * @return Either the value of the IValue representing a LInsets, or String "(null)".
     * 
     * @author tit
     */
    def nullOrLInsets(IVariable variable, String fieldPath) {
        if (variable.valueIsNotNull) {
            return "(" + variable.getValue(fieldPath + ".top").round(1) + ", " 
                       + variable.getValue(fieldPath + ".right").round(1) + ", "
                       + variable.getValue(fieldPath + ".bottom").round(1) + ", "
                       + variable.getValue(fieldPath + ".left").round(1) + ")"
        } else {
            return "(null)"
        }
    }

    /**
     * Returns either the value of the IValue on the '.name' path of the given IVariable on path or "(null)".
     * Is usable for all enumeration types where the '.name' path in the debug view represents it's value.
     * 
     * @param variable
     *            The root IVariable element.
     * @param fieldPath
     *            The relative path from the root IVariable to the IValue to inspect.  
     * @return Either the value of the IVariable representing an enumeration element, or String "(null)".
     * 
     * @author tit
     */
    def nullOrName(IVariable variable, String fieldPath) {
        if (variable.valueIsNotNull) {
            return variable.getValue(fieldPath + ".name")
        } else {
            return "(null)"
        }
    }
    
    /**
     * Returns either the size of the structure represented by the IValue on path or "(null)".
     * Is usable for all structures containing a "size()" method, for example:
     * LinkedList, hashMap, LinkedHashMap, ArrayList ...
     * 
     * @param variable
     *            The root IVariable element.
     * @param fieldPath
     *            The relative path from the root IVariable to the IValue to inspect.  
     * @return Either the size of the IVariable representing an type with size() method, or String "(null)".
     * 
     * @author tit
     */
    def nullOrSize(IVariable variable, String fieldPath) {
        if (variable.valueIsNotNull) {
            return variable.getValue(fieldPath + ".size")
        } else {
            return "(null)"
        }
    }

    /**
     * Checks if a given IVariable contains an IVariable with the specified debug-ID as it's child.
     * Debug-ID must be given in the form "('id')" as it also is returned by getValueString(IVariable).
     * 
     * @param list
     *            The IVariable those children will be inspected.
     * @param id
     *            The debug-ID to search in the form "('id')"  
     * @return True is there is a child with the given debug-ID, false otherwise.
     */
    def containsValWithID(IVariable list, String id) {
    	for(elem : list.linkedList) {
    		if (id.equals(elem.getValueString)) return true
    	}
    	return false
    }

    
    /**
     * A convenience method to add a new label to a given KEdge.
     * 
     * @param edge
     *            The Edge the label should be added to. 
     * @param text
     *            The text of the label.  
     * @param placement
     *            The position of the label on the edge.  
     * @return The new created label.
     */
    def addLabel(KEdge edge, String text, EdgeLabelPlacement placement) {
        edge.createLabel => [
            it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, placement)
            it.text = text
             it.setLabelSize(
                PlacementUtil::estimateTextSize(it).getWidth + 2,
                PlacementUtil::estimateTextSize(it).getHeight + 2
            )
        ]
    }
    

}
