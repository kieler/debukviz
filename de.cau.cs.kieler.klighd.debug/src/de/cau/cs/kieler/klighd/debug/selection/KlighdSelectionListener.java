/*
 * KIELER - Kiel Integrated Environment for Layout Eclipse RichClient
 *
 * http://www.informatik.uni-kiel.de/rtsys/kieler/
 * 
 * Copyright 2013 by
 * + Christian-Albrechts-University of Kiel
 *   + Department of Computer Science
 *     + Real-Time and Embedded Systems Group
 * 
 * This code is provided under the terms of the Eclipse Public License (EPL).
 * See the file epl-v10.html for the license text.
 */
package de.cau.cs.kieler.klighd.debug.selection;

import org.eclipse.debug.core.model.IVariable;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.ui.ISelectionListener;
import org.eclipse.ui.ISelectionService;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.PlatformUI;

import de.cau.cs.kieler.klighd.ui.DiagramViewManager;
import de.cau.cs.kieler.klighd.ui.parts.DiagramViewPart;

/**
 * A listener that listens to selections being done.
 * 
 * @author hwi
 */
public class KlighdSelectionListener implements ISelectionListener {

    /** The singleton instance of the {@code KlighdSelectionListener} class */
    public final static KlighdSelectionListener INSTANCE = new KlighdSelectionListener();

    /** last selected variable */
    private static IVariable lastSelectedVariable = null;

    /**
     * Hidden default constructor
     */
    private KlighdSelectionListener() {
    }

    /**
     * Register selection listener to selection service
     */
    public void register() {
        final KlighdSelectionListener sl = this;
        PlatformUI.getWorkbench().getDisplay().asyncExec(new Runnable() {
            public void run() {
                ISelectionService selectionService =
                        PlatformUI.getWorkbench().getActiveWorkbenchWindow().getSelectionService();
                selectionService.addSelectionListener(sl);
            }
        });
    }

    /**
     * {@inheritDoc}
     * 
     * if selection is an instance of {@link StructuredSelection} and the first element is an
     * instance of {@link IVariable} a new KlighD view will be created or if the selection has
     * changed the KlighD view will be updated
     */
    public void selectionChanged(IWorkbenchPart part, ISelection selection) {
        if (selection instanceof StructuredSelection) {
            Object firstElement = ((StructuredSelection) selection).getFirstElement();
            if (firstElement instanceof IVariable) {
                IVariable var = (IVariable) firstElement;
                DiagramViewPart view = null;

                // Create a new view if none exists
                if (DiagramViewManager.getInstance().getView("Variable") == null) {
                    view =
                            DiagramViewManager.getInstance().createView("Variable", "Variable",
                                    var, null);
                }

                // Only update the view if selection has changed
                else if (!var.equals(lastSelectedVariable)) {
                    lastSelectedVariable = var;
                    view = (DiagramViewPart) DiagramViewManager.getInstance().updateView(
                            "Variable", "Variable", var, null);

                    if (view != null && view.getViewer() != null) {
                        view.getViewer().getViewContext().setSourceWorkbenchPart(part);
                    }
                }
            }
        }
    }
}
