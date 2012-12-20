package de.cau.cs.kieler.klighd.debug.transformation;

import javax.inject.Inject;

import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.IVariable;

import de.cau.cs.kieler.core.kgraph.KNode;
import de.cau.cs.kieler.core.krendering.KRectangle;
import de.cau.cs.kieler.core.krendering.KRenderingFactory;
import de.cau.cs.kieler.core.krendering.KText;
import de.cau.cs.kieler.core.krendering.extensions.KNodeExtensions;
import de.cau.cs.kieler.kiml.options.Direction;
import de.cau.cs.kieler.kiml.options.LayoutOptions;
import de.cau.cs.kieler.kiml.util.KimlUtil;
import de.cau.cs.kieler.klighd.TransformationContext;
import de.cau.cs.kieler.klighd.transformations.AbstractTransformation;

public class KlighdDebugTransformation1 extends AbstractTransformation<IVariable, KNode> {
	
	@Inject
	private KNodeExtensions kNodeExtensions;
	
	private static KRenderingFactory renderingFactory = KRenderingFactory.eINSTANCE;
	
	public KNode transform(IVariable model,
			TransformationContext<IVariable, KNode> transformationContext) {
		use(transformationContext);
		KNode initNode = KimlUtil.createInitializedNode();
		//kNodeExtensions.addLayoutParam(initNode, LayoutOptions.ALGORITHM, "de.cau.cs.kieler.kiml.ogdf.planarization");
		kNodeExtensions.addLayoutParam(initNode, LayoutOptions.SPACING, 75f);
		kNodeExtensions.addLayoutParam(initNode, LayoutOptions.DIRECTION, Direction.UP);
		
		try {
			if (!model.getValue().hasVariables()) {
				// Primitive datatypes (char, byte, short, int, long, float, double, boolean)
				KNode node = KimlUtil.createInitializedNode();
				kNodeExtensions.setNodeSize(node, 80, 80);
				
				KRectangle rec = renderingFactory.createKRectangle();
				rec.setChildPlacement(renderingFactory.createKGridPlacement());
				rec.getChildren().add(getPrimitiveText(model));
				
				node.getData().add(rec);
				initNode.getChildren().add(node);
			}
			else {
				IVariable[] vars = model.getValue().getVariables();
			}
		} catch (DebugException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}
	
	private KText getPrimitiveText(IVariable primitive) throws DebugException {
		KText text = renderingFactory.createKText();
			text.setText(primitive.getReferenceTypeName() + " " +
						 primitive.getName() + " = " +
						 primitive.getValue());
		return text;
	}

}
