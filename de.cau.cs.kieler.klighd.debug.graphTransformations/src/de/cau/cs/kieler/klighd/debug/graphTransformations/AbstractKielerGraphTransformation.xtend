package de.cau.cs.kieler.klighd.debug.graphTransformations

import de.cau.cs.kieler.core.kgraph.KNode
import org.eclipse.debug.core.model.IVariable
import javax.inject.Inject
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.core.krendering.KContainerRendering
import java.util.LinkedList
import org.eclipse.debug.core.DebugException
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.kiml.util.KimlUtil
import java.math.*
import de.cau.cs.kieler.core.krendering.KText
import de.cau.cs.kieler.klighd.debug.visualization.AbstractDebugTransformation
import de.cau.cs.kieler.core.kgraph.KLabel
import de.cau.cs.kieler.core.kgraph.KLabeledGraphElement
import de.cau.cs.kieler.core.krendering.extensions.KLabelExtensions
import de.cau.cs.kieler.kiml.options.EdgeLabelPlacement
import de.cau.cs.kieler.kiml.options.Direction
import de.cau.cs.kieler.kiml.options.LayoutOptions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.klighd.krendering.PlacementUtil
import de.cau.cs.kieler.core.krendering.HorizontalAlignment

abstract class AbstractKielerGraphTransformation extends AbstractDebugTransformation {
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
                return key.getValue("id") + ": "
            case "LayoutOptionData<T>" : 
                return key.getValue("name") + ": "
            case "KNodeImpl" :
                return "KNode" + key.getValue.getValueString + " -> "
        }
        // a default statement in the switch results in a missing return statement in generated 
        // java code, so I added the default return value here
        return "<? " + key.getType +" ?> : "
    }

    def flattenStruct(KContainerRendering container, IVariable element, String remainder, String prefix) {
        switch element.getType {
            case "HashMap<K,V>" : {
                container.addRemainer(prefix, remainder)
                // create all child elements
                element.hashMapToLinkedList.forEach [
                    container.flattenStruct(it.getVariable("value"), it.getVariable("key").keyString, prefix + "- ")
                ]
            }
            case "RegularEnumSet<E>" : {
                container.addRemainer(prefix, remainder)
                // create the enumSet elements
                container.enumSetToKText(element, prefix + "- ")
            } 
            case "NodeGroup" : {
                container.addRemainer(prefix, remainder)
                // create all child elements
                element.getVariables("nodes").forEach [
                    container.flattenStruct(it, "", prefix + "- ")
                ]
            } 
            case "KNodeImpl" :
                container.children += renderingFactory.createKText =>[
                    it.text = prefix + remainder + "KNodeImpl " + element.getValue.getValueString
                ]
            case "KLabelImpl" :
                container.children += renderingFactory.createKText =>[
                    it.text = prefix + remainder + "KLabelImpl " + element.getValue.getValueString
                ]
            case "KEdgeImpl" :
                container.children += renderingFactory.createKText =>[
                    it.text = prefix + remainder + "KEdgeImpl " + element.getValue.getValueString
                ]
            case "LNode" : 
                container.children += renderingFactory.createKText =>[
                    it.text = prefix + remainder + "LNodeImpl " + element.getValue("id") + element.getValue.getValueString
                ]
            case "Random" :
                container.children += renderingFactory.createKText => [
                    it.text = prefix + remainder + "seed " + element.getValue("seed.value") 
                ]
            case "String" :
                container.children += renderingFactory.createKText => [
                    it.text = prefix + remainder + element.getValue.getValueString 
                ]
            case "Direction" :
                container.children += renderingFactory.createKText =>[
                    it.text = prefix + remainder + element.getValue("name")
                ]
            case "Boolean" :
                container.children += renderingFactory.createKText => [
                    it.text = prefix + remainder + element.getValue("value")
                ]
            case "Float" :
                container.children += renderingFactory.createKText => [
                    it.text = prefix + remainder + element.getValue("value")
                ]
            case "PortConstraints" : 
                container.children += renderingFactory.createKText => [
                    it.text = prefix + remainder + element.getValue("name")
                ]
            case "EdgeLabelPlacement" :
                container.children += renderingFactory.createKText => [
                    it.text = prefix + remainder + element.getValue("name")
                ]
            default : 
                container.children += renderingFactory.createKText =>[
                    it.text = prefix + remainder + "<? " + element.getType + element.getValue.getValueString + "?>"
                ]
        }
    }
    
    def addRemainer(KContainerRendering container, String prefix, String remainder) {
        if(remainder.length > 0)
            container.children += renderingFactory.createKText =>[
                it.text = prefix + remainder
            ]
    }

    def addPropertyMapAndEdge(KNode rootNode, IVariable propertyMap, IVariable headerNode) {
        if(rootNode != null && propertyMap.valueIsNotNull && headerNode.valueIsNotNull) {

            // create propertyMap node
            rootNode.addNodeById(propertyMap) => [
                it.data += renderingFactory.createKRectangle => [
                    it.lineWidth = 4
                    it.ChildPlacement = renderingFactory.createKGridPlacement

//TODO: warum geht das hier nicht?
                    it.setHorizontalAlignment( HorizontalAlignment::LEFT) 
                    it.placementData = renderingFactory.createKGridPlacementData => [
                        it.setInsetRight(20)
                        it.setInsetLeft(20)
                        it.setInsetTop(20)
                        it.setInsetBottom(20)
                    ]
                    
                    // add type of the propertyMap
                    it.children += renderingFactory.createKText => [
                        it.setForegroundColor(120,120,120)
                        it.text = propertyMap.getType
                    ]
            
                    // add all properties
                    it.flattenStruct(propertyMap, "", "")
                ]
            ]
                            
            //create edge from header to propertyMap node
            headerNode.createEdgeById(propertyMap) => [
                it.data += renderingFactory.createKPolyline => [
                    it.setLineWidth(2)
                    it.addArrowDecorator
                ]
                
                // add label
                propertyMap.createLabel(it) => [
                    it.addLayoutParam(LayoutOptions::EDGE_LABEL_PLACEMENT, EdgeLabelPlacement::CENTER)
                    it.text = "Property Map"
                    val dim = PlacementUtil::estimateTextSize(it)
                    it.setLabelSize(dim.width,dim.height)
                ]
            ]
        }
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
    def addShortType(KContainerRendering container, IVariable variable) {
        container.children += renderingFactory.createKText => [
            it.setForegroundColor(120,120,120)
            it.text = variable.getType
        ]    
    }
    
    def debugID(IVariable variable) {
        return variable.getValue.getValueString
    }
    
    def headerNodeBasics(KContainerRendering container, Boolean detailedView, IVariable variable) {
        container.ChildPlacement = renderingFactory.createKGridPlacement

        if(detailedView) {
            // bold line in detailed view
            container.lineWidth = 4
            
            // type of the variable
            container.addShortType(variable)

            // name of the variable
            container.children += renderingFactory.createKText => [
                it.text = "Variable: " + variable.name + variable.getValue.getValueString 
            ]
            
            // coloring of main element
            container.setBackgroundColor("lemon".color);
        } else {
            // slim line in not detailed view
            container.lineWidth = 2
        }
    }
    
    
    def addKText(KContainerRendering container, IVariable variable, String valueText, String prefix, String delimiter) {
        container.children +=  renderingFactory.createKText => [
            if (variable.valueIsNotNull) {
                it.text = prefix + valueText + delimiter + variable.getValue(valueText)
            } else {
                it.text = prefix + valueText + delimiter + "null"
            }
        ]
    }
    
    def addTypeAndIdKText(KContainerRendering container, IVariable iVar, String variable) {
        val v = iVar.getVariable(variable)
        container.children += renderingFactory.createKText => [
            if (v.valueIsNotNull) {
                it.text = variable + ": " + v.type + " " + v.debugID
            } else {
                it.text = variable + ": null"
            }
        ]
    }
}
