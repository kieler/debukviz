package de.cau.cs.kieler.klighd.debug.transformations

import de.cau.cs.kieler.core.kgraph.KNode
import de.cau.cs.kieler.core.krendering.KRenderingFactory
import de.cau.cs.kieler.core.krendering.extensions.KColorExtensions
import de.cau.cs.kieler.core.krendering.extensions.KEdgeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions
import de.cau.cs.kieler.core.krendering.extensions.KPolylineExtensions
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions
import de.cau.cs.kieler.core.util.Pair
import de.cau.cs.kieler.kiml.util.KimlUtil
import de.cau.cs.kieler.klighd.TransformationContext
import de.cau.cs.kieler.klighd.transformations.AbstractTransformation
import java.util.LinkedList
import javax.inject.Inject

import static de.cau.cs.kieler.klighd.debug.transformations.LinkedListDiagramSynthesis.*
import de.cau.cs.kieler.kiml.options.LayoutOptions
import org.eclipse.debug.core.model.IVariable
import org.eclipse.debug.core.DebugException
import org.eclipse.debug.core.model.IValue

class TIT_LinkedList_IVarToKNode extends AbstractTransformation<IVariable, KNode> {
        
    @Inject
    extension KNodeExtensions
    
    @Inject
    extension KEdgeExtensions
    
    @Inject
    extension KRenderingExtensions
    
    @Inject
    extension KPolylineExtensions
    
    @Inject
    extension KColorExtensions
    
 
    private static val KRenderingFactory renderingFactory = KRenderingFactory::eINSTANCE

    /**
     * {@inheritDoc}
     */
    override KNode transform(IVariable choice, TransformationContext<IVariable, KNode> transformationContext) {
        use(transformationContext)
        
        return KimlUtil::createInitializedNode => [
            setOuterLayout(it)
            
        	if (isCorrectType(choice)) {
        		it.createHeaderNode(choice)
        		var i = getVariableByName(choice, "size").getValue.valueString
                it.createChildNode(getVariableByName(choice, "header"), Integer::parseInt(i))
       	}
        ]
    }
 
  	def createHeaderNode(KNode rootNode, IVariable iVar) {
    	var IVariable header = getVariableByName(iVar, "header")
    	rootNode.children += header.createNode().putToLookUpWith(header) => [
    		it.setNodeSize(120,80)
    		it.data += renderingFactory.createKRectangle() => [
    			it.setLineWidth(4)
    			it.setBackgroundColor("lemon".color)
    			it.ChildPlacement = renderingFactory.createKGridPlacement()
    			it.children += renderingFactory.createKText() => [
                	it.setText(iVar.name)
            	]
    			it.children += renderingFactory.createKText() => [
                	it.setText("Type: " + iVar.getReferenceTypeName)
            	]
    			it.children += renderingFactory.createKText() => [
                	it.setText("size: " + getVariableByName(iVar, "size").getValue.valueString)
            	]
    		]
    	]
    }
        
    /**
     * Sets the base layout for the generated node containing the visualization for the given element
     * 
     * @param outerNode the KNode containing the visualization of the given element 
     */
    def setOuterLayout(KNode outerNode) {
    	outerNode.addLayoutParam(LayoutOptions::ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization")
        outerNode.addLayoutParam(LayoutOptions::SPACING, 75f)
    }
    
    /**
     * Checks if the given IVariable is the representation of an element of the correct type
     * 
     * @param choice The IVariable to check
     * @return the boolean result of the check
     */
    def isCorrectType(IVariable choice) {
    	return choice.referenceTypeName.matches("java.util.LinkedList<.+>")
    }
            
    /**
     * Creates a 
     */
    def createChildNode(KNode rootNode, IVariable parent, int recursions){
        if (recursions > 0) {
        	var node0 = getVariableByName(parent, "next")
//        	var node =  getVariableByName(node0, "element")
            rootNode.createInternalNode(node0)
            createEdge(parent, node0)
            createChildNode(rootNode, node0, recursions -1)
        }
    }
    
    def createInternalNode(KNode rootNode, IVariable element) {
        rootNode.children += element.createNode().putToLookUpWith(element) => [
            it.setNodeSize(120,80)
            it.data += renderingFactory.createKRectangle() => [
                it.setLineWidth(2)
                it.setBackgroundColor("lemon".color)
    			it.ChildPlacement = renderingFactory.createKGridPlacement()
    			it.children += renderingFactory.createKText() => [
                	it.setText(element.getVariableByName("element").getVariableByName("value").getValue.valueString)
            	]
            ]
        ]
    }
    
    def createEdge(IVariable child, IVariable parent) {
        new Pair(child, parent).createEdge() => [
            it.source = parent.node
            it.target = child.node
            it.data += renderingFactory.createKPolyline() => [
                it.setLineWidth(2)
            ]
        ]
    }
   
    
	def getLinkedList(LinkedList<Integer> list, IVariable header) throws DebugException {
		var next = getValue(header, "next");
		println(next.getReferenceTypeName());
		// Get element field
		var elements = getValue(next, "element").getValue().getVariables();
		if (elements.size != 0) {
			// Get element value
			var elementValue = elements.get(11).getValue();

			list.add(Integer::parseInt(elementValue.getValueString()));
			getLinkedList(list, next);
		}
	}

	def getValue(IVariable variable, String field) throws DebugException {
		for (vari : variable.getValue().getVariables())
			if (vari.getName().equals(field))
				return vari;
		return null;
	}
	
	def getVariableByName(IVariable iVariable, String field) {
		for (iVar : iVariable.getValue.getVariables()) {
//			println(iVariable.getName() + " :" +  iVar.getName())
			if (iVar.getName().equals(field))
				return iVar;
		}
		return null;
	}
}