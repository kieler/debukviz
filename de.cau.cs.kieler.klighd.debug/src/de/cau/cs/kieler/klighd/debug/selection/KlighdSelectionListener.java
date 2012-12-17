package de.cau.cs.kieler.klighd.debug.selection;

import java.util.LinkedList;

import org.eclipse.debug.core.DebugException;
import org.eclipse.debug.core.model.IValue;
import org.eclipse.debug.core.model.IVariable;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.TreeSelection;
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

    @Override
    public void selectionChanged(IWorkbenchPart part, ISelection selection) {
        // TODO Open light diagram view
        if (part.getTitle().equals("Variables") && selection instanceof TreeSelection) {
            TreeSelection treeSelection = (TreeSelection) selection;
            if (treeSelection.getFirstElement() instanceof IVariable) {
                IVariable var = (IVariable) treeSelection.getFirstElement();
                try {
                    // Variable name
                    String name = var.getName();
                    // Variable value
                    IValue value = var.getValue();
                    DiagramViewPart view = null;
                    if (DiagramViewManager.getInstance().getView("Variable") == null)
                        view = DiagramViewManager.getInstance().createView("Variable", "Variable",
                                new Object(), null);
                    else
                        view = DiagramViewManager.getInstance().updateView("Variable", "Variable",
                                new Object(), null);

                    if (view != null && view.getContextViewer() != null) {
                        view.getContextViewer().getCurrentViewContext()
                                .setSourceWorkbenchPart(part);
                    }
                } catch (DebugException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            }

        }
    }

}
