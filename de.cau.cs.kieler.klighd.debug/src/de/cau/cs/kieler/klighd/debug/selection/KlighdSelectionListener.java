package de.cau.cs.kieler.klighd.debug.selection;

import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.IVariable;
import org.eclipse.jdt.debug.core.IJavaObject;
import org.eclipse.jdt.debug.core.IJavaValue;
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
        if (selection instanceof StructuredSelection) {
            StructuredSelection treeSelection = (StructuredSelection) selection;
            if (treeSelection.getFirstElement() instanceof IVariable) {
                IVariable var = (IVariable) treeSelection.getFirstElement();
                DiagramViewPart view = null;
                if (DiagramViewManager.getInstance().getView("Variable") == null)
                    view = DiagramViewManager.getInstance().createView("Variable", "Variable", var,
                            null);
                else
                    view = DiagramViewManager.getInstance().updateView("Variable", "Variable", var,
                            null);
                
                if (view != null && view.getContextViewer() != null) {
                    view.getContextViewer().getCurrentViewContext().setSourceWorkbenchPart(part);
                }
            }
        }
    }

}
