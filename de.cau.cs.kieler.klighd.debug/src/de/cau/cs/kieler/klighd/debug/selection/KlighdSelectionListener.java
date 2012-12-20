package de.cau.cs.kieler.klighd.debug.selection;

import java.math.BigInteger;
import java.util.LinkedList;

import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.IValue;
import org.eclipse.debug.core.model.IVariable;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.ui.ISelectionListener;
import org.eclipse.ui.ISelectionService;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.PlatformUI;

import de.cau.cs.kieler.klighd.views.DiagramViewManager;
import de.cau.cs.kieler.klighd.views.DiagramViewPart;

public class KlighdSelectionListener implements ISelectionListener {

	// Singleton implementation of selection listener
	private final static KlighdSelectionListener INSTANCE = new KlighdSelectionListener();

	private KlighdSelectionListener() {
	}

	public static KlighdSelectionListener getInstance() {
		return INSTANCE;
	}

	/**
	 * Register selection to selection service
	 */
	public void register() {
		final KlighdSelectionListener sl = this;
		PlatformUI.getWorkbench().getDisplay().asyncExec(new Runnable() {
			public void run() {
				ISelectionService selectionService = PlatformUI.getWorkbench()
						.getActiveWorkbenchWindow().getSelectionService();
				selectionService.addSelectionListener(sl);
			}
		});
	}

	public void selectionChanged(IWorkbenchPart part, ISelection selection) {
		// TODO Open light diagram viewS
		if (selection instanceof StructuredSelection) {
			StructuredSelection treeSelection = (StructuredSelection) selection;
			if (treeSelection.getFirstElement() instanceof IVariable) {
				IVariable var = (IVariable) treeSelection.getFirstElement();
				
				// LinkedList<Integer> list = new LinkedList<Integer>(); try {
				// getLinkedList(list, getValue(var, "header"));
				// System.out.println(list); } catch (DebugException e) {
				// //TODO Auto-generated catch block
				// e.printStackTrace(); }
				 
				try {
					System.out.println(var.getReferenceTypeName());
				} catch (DebugException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				DiagramViewPart view = null;
				if (DiagramViewManager.getInstance().getView("Variable") == null)
					view = DiagramViewManager.getInstance().createView(
							"Variable", "Variable", var, null);
				else
					view = DiagramViewManager.getInstance().updateView(
							"Variable", "Variable", var, null);

				if (view != null && view.getContextViewer() != null) {
					view.getContextViewer().getCurrentViewContext()
							.setSourceWorkbenchPart(part);
				}
			}

		}
	}

	public void getLinkedList(LinkedList<Integer> list, IVariable header)
			throws DebugException {
		IVariable next = getValue(header, "next");
		System.out.println(next.getReferenceTypeName());
		// Get element field
		IVariable[] elements = getValue(next, "element").getValue()
				.getVariables();
		if (elements.length != 0) {
			// Get element value
			IValue elementValue = elements[11].getValue();

			list.add(Integer.parseInt(elementValue.getValueString()));
			getLinkedList(list, next);
		}
	}

	public IVariable getValue(IVariable variable, String field)
			throws DebugException {
		for (IVariable var : variable.getValue().getVariables())
			if (var.getName().equals(field))
				return var;
		return null;
	}

}
