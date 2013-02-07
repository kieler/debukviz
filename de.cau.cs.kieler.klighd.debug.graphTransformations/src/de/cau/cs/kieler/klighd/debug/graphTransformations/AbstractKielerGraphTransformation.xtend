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

	def equals(boolean isDetailed, ShowTextIf enum) {
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
                if (v.getVariable("next").valueIsNotNull) {
                    retVal.add(v.getVariable("next"))
                }
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
        }
        // a default statement in the switch results in a missing return statement in generated 
        // java code, so I added the default return value here
        return "<? " + key.getType +" ?> : "
    }

    def addPropertyMapAndEdge(KNode rootNode, IVariable propertyMap, IVariable headerNode) {
        if(rootNode != null && propertyMap.valueIsNotNull && headerNode.valueIsNotNull) {

            // create propertyMap node
            rootNode.addNodeById(propertyMap) => [
                it.data += renderingFactory.createKRectangle => [
                    it.lineWidth = 4

 					it.addHashValueElement(propertyMap)
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
            	container.addGridElement("KNodeImpl " + element.getValueString, HorizontalAlignment::LEFT)
            case "KLabelImpl" :
            	container.addGridElement("KLabelImpl " + element.getValueString, HorizontalAlignment::LEFT)
            case "KEdgeImpl" :
            	container.addGridElement("KEdgeImpl " + element.getValueString, HorizontalAlignment::LEFT)
            case "LNode" :
            	container.addGridElement("LNodeImpl " + element.getValue("id") + element.getValueString, 
            		HorizontalAlignment::LEFT
            	)
            case "Random" :
            	container.addGridElement("seed " + element.getValue("seed.value"), HorizontalAlignment::LEFT)
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
    
    def headerNodeBasics(KContainerRendering container, KTextIterableField field, Boolean detailedView, 
    			IVariable variable, KTextIterableField$TextAlignment leftColumn, 
    								KTextIterableField$TextAlignment rightColumn) {
        if(detailedView) {
            // bold line in detailed view
            container.lineWidth = 4
            
            // type of the variable
            field.setHeader(variable.shortType)

            // name of the variable
            field.set("Variable:", field.rowCount, 0, leftColumn) 
            field.set(variable.name + variable.getValueString, field.rowCount - 1, 1, rightColumn) 

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
        val v = iVar.getVariable(variable)
        if (v.valueIsNotNull) {
            return v.type + " " + v.getValueString
        } else {
            return v.type + ": null"
        }
    }

    def nullOrValue(IVariable variable, String valueName) {
            if (variable.valueIsNotNull) {
                return variable.getValue(valueName)
            } else {
                return "null"
            }
    }
    

}
