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
        return Math::round(Double::valueOf(number) 
                         * Math::pow(10, decimalPositions)) 
             / Math::pow(10, decimalPositions)
    }
    
    def KText createKText(IVariable variable, String valueText, String prefix, String delimiter) {
        val retVal = renderingFactory.createKText
        try {
            retVal.setText(prefix + valueText + delimiter + variable.getValue(valueText))
        } catch (DebugException e) {
            return null
        }
        return retVal
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
                return "KNode" + key.getValue.getValueString + ": "
        }
        // a default statement in the switch results in a missing return statement in generated 
        // java code, so I added the default return value here
        return "<? " + key.getType +" ?> : "
    }

    def flattenStruct(IVariable element, KContainerRendering container, String remainder, String prefix) {
        switch element.getType {
            case "HashMap<K,V>" : {
                // write the remainder to the container ("header" of following elements)
                if(remainder.length > 0) {
                    container.children += renderingFactory.createKText =>[
                        it.text = prefix + remainder
                    ]
                }
                // create all child elements
                element.hashMapToLinkedList.forEach [
                    it.getVariable("value").flattenStruct(container, it.getVariable("key").keyString, prefix + "- ")
                ]
            }
            case "RegularEnumSet<E>" : {
                // write the remainder to the container
                if(remainder.length > 0)
                    container.children += renderingFactory.createKText =>[
                        it.text = prefix + remainder
                    ]
                // create the enumSet elements
                container.enumSetToKText(element, prefix + "- ")
            } 
            case "KNodeImpl" :
                container.children += renderingFactory.createKText =>[
                    it.text = prefix + remainder + "KNode " + element.getValue.getValueString
                ]
            case "KLabelImpl" :
                container.children += renderingFactory.createKText =>[
                    it.text = prefix + remainder + "KLabel " + element.getValue.getValueString
                ]
            case "LNode" : 
                container.children += renderingFactory.createKText =>[
                    it.text = prefix + remainder + "LNode " + element.getValue("id") + element.getValue.getValueString
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
            default : 
                container.children += renderingFactory.createKText =>[
                    it.text = prefix + remainder + "<? " + element.getType + "?>"
                ]
        }
    }
    
    def addPropertyMapAndEdge(KNode rootNode, IVariable propertyMap, IVariable headerNode) {
        // create propertyMap node
        rootNode.addNewNodeById(propertyMap) => [
            it.data += renderingFactory.createKRectangle => [
                it.lineWidth = 4
                it.ChildPlacement = renderingFactory.createKGridPlacement 
//                it.ChildPlacement = renderingFactory.createKStackPlacement
//TODO: warum geht das hier nicht?
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
                propertyMap.flattenStruct(it, "PROPERTY MAP", "")
            ]
        ]
                        
        //create edge from header to propertyMap node
        headerNode.createEdgeById(propertyMap) => [
            it.data += renderingFactory.createKPolyline => [
                it.setLineWidth(2)
                it.addArrowDecorator
            ]
            KimlUtil::createInitializedLabel(it) => [
                it.setText("Property Map")
            ]
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
    def addShortType(KContainerRendering container, IVariable variable) {
        container.children += renderingFactory.createKText => [
            it.setForegroundColor(120,120,120)
            it.text = variable.getType
        ]    
    }
}