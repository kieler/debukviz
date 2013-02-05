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

import static de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation.*
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions

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

    val topGap = 4
    val rightGap = 7
    val bottomGap = 5
    val leftGap = 4
    val vGap = 3
    val hGap = 5
    
//    protected GraphTransformationInfo gtInfo = new GraphTransformationInfo
    protected Boolean detailedView = true
    
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
                return "KNode" + key.getValue.getValueString + " -> "
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

                    val kTextField = new KTextIterableField(topGap, rightGap, bottomGap, leftGap, vGap, hGap)

                    val kText = renderingFactory.createKText => [
                        it.setForegroundColor(120,120,120)
                        it.text = propertyMap.getType
                    ]
                    kTextField.setHeader(kText)
                    
                    kTextField.addValue(propertyMap, 0, 0)
                    kTextField.forEach [ text |
                        it.children += text
                    ]
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
    
    def addValue(KTextIterableField field, IVariable element, int oldRow, int oldColumn) {
        var int row = oldRow
        var int column = oldColumn

        switch element.getType {
            case "HashMap<K,V>" : {
                //TODO: this is a bit ugly, but I don't know a better solution:
                // the very first header element is the name of the table and we don't want it here
                // add the header element
                if(oldRow != 0 || column != 0) {
                    field.set(element.name + ": ", row, column, KTextIterableField$TextAlignment::RIGHT)
                    column = column + 1
                }
                
                // create all child elements
                if(element.valueIsNotNull) {
                    val childs = element.hashMapToLinkedList
                    
                    if (childs.size == 0) {
                        field.set("(empty)", row, column)
                    } else {
                        for (child : childs) {
                            field.set(child.getVariable("key").keyString, row, column, KTextIterableField$TextAlignment::RIGHT)
                            row = field.addValue(child.getVariable("value"), row, column + 1)
                            row = row + 1
                        }
                        row = row - 1
                    }
                } else {
                    field.set("(null)", row, column)
                }
            }
            
            case "RegularEnumSet<E>" : {
                // create the enumSet elements
                row = field.addEnumSet(element, row, column)
            } 
            
            case "NodeGroup" : {
                // create all child elements
                val childs = element.getVariables("nodes")
                if(childs.nullOrEmpty) {
                    field.set("(empty)", row, column)
                    row = row + 1
                } else {
                    // add all elements
                    for (child : childs) {
                        row = field.addValue(child, row, column)
                        row = row + 1
                    }
                    row = row - 1
                }
            } 
            case "KNodeImpl" : {
                field.set("KNodeImpl " + element.getValue.getValueString, row, column)
            }
            case "KLabelImpl" : {
                field.set("KLabelImpl " + element.getValue.getValueString, row, column)
            }
            case "KEdgeImpl" : {
                field.set("KEdgeImpl " + element.getValue.getValueString, row, column)
            }
            case "LNode" : {
                field.set("LNodeImpl " + element.getValue("id") + element.getValue.getValueString, row, column)
            }
            case "Random" : {
                field.set("seed " + element.getValue("seed.value"), row, column)
            }
            case "String" : {
                field.set(element.getValue.getValueString, row, column)
            }
            case "Direction" : {
                field.set(element.getValue("name"), row, column)
            }
            case "Boolean" : {
                field.set(element.getValue("value"), row, column)
            }
            case "Float" : {
                field.set(element.getValue("value"), row, column)
            }
            case "PortConstraints" : {
                field.set(element.getValue("name"), row, column)
            }
            case "EdgeLabelPlacement" : {
                field.set(element.getValue("name"), row, column)
            }
            default : {
                field.set("<? " + element.getType + element.getValue.getValueString + "?>", row, column)
            }
        }
        return row
    }

    def addEnumSet(KTextIterableField container, IVariable set, int oldRow, int column) {
        var row = oldRow
        // the mask representing the elements that are set
        val elemMask = Integer::parseInt(set.getValue("elements"))
        if (elemMask == 0) {
            // no elements are set at all
            container.set("(none)", row, column)
        } else {
            // the elements available
            val elements = set.getVariables("universe")
            var i = 0
            // go through all elements and check if corresponding bit is set in elemMask
            while(i < elements.size) {
                var mask = Integer::parseInt(elements.get(i).getValue("ordinal")).pow2
                if(elemMask.bitwiseAnd(mask) > 0) {
                    // bit is set 
                    container.set(elements.get(i).getValue("name"), row, column)
                    row = row + 1
                }
                i = i + 1
            }
            row = row - 1
        }
        return row
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
    
    def debugID(IVariable variable) {
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
            field.set(variable.name + variable.getValue.getValueString, field.rowCount - 1, 1, rightColumn) 

            // coloring of main element
            container.setBackgroundColor("lemon".color);
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
    
    def nullOrValue(IVariable variable, String valueName) {
            if (variable.valueIsNotNull) {
                return variable.getValue(valueName)
            } else {
                return "null"
            }
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
            return variable + ": " + v.type + " " + v.debugID
        } else {
            return variable + ": null"
        }
    }
}
