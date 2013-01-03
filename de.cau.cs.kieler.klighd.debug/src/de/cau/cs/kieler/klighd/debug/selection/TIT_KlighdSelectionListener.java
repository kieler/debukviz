package de.cau.cs.kieler.klighd.debug.selection;

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

public class TIT_KlighdSelectionListener implements ISelectionListener {

	// Singleton implementation of selection listener
	private final static TIT_KlighdSelectionListener INSTANCE = new TIT_KlighdSelectionListener();

	private TIT_KlighdSelectionListener() {
	}

	public static TIT_KlighdSelectionListener getInstance() {
		return INSTANCE;
	}

	/**
	 * Register selection to selection service
	 */
	public void register() {
		final TIT_KlighdSelectionListener sl = this;
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
				try {
					System.out.println("----------------");
					System.out.println("----------------");
					System.out.println("IVariable:" + var);
					System.out.println("Name: " + var.getName());
					System.out.println("RefType: " + var.getReferenceTypeName());
				} catch (DebugException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
				
				try {
					IValue value = var.getValue();
					System.out.println("----------------");
					System.out.println("IValue:");
//					System.out.println("getClass: " + value.getClass());
//					System.out.println("getDebugTarget: " + value.getDebugTarget());
//					System.out.println("getLaunch: " + value.getLaunch());
					System.out.println("Object: " + System.identityHashCode(value));
					System.out.println("RefType: " + value.getReferenceTypeName());
					System.out.println("ValueString: " + value.getValueString());

					IVariable[] vars = value.getVariables();
					int i = 0;
					for (IVariable item : vars) {
						System.out.println();
						System.out.println("Variable " + i);
						System.out.println("IVariable name: " + item.getName());
						System.out.println("IVariable RefType: " + item.getReferenceTypeName());
						IValue value2 = item.getValue();
						System.out.println("IValue valueString: " + value2.getValueString());
						System.out.println("IValue RefType: " + value2.getReferenceTypeName());
						i++;
					}
				} catch (DebugException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
			}
		}
	}

}
