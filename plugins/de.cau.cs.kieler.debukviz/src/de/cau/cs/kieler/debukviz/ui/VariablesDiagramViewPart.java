/*
 * KIELER - Kiel Integrated Environment for Layout Eclipse RichClient
 *
 * http://rtsys.informatik.uni-kiel.de/kieler
 * 
 * Copyright 2015 by
 * + Kiel University
 *   + Department of Computer Science
 *     + Real-Time and Embedded Systems Group
 * 
 * This code is provided under the terms of the Eclipse Public License (EPL).
 */
package de.cau.cs.kieler.debukviz.ui;

import org.eclipse.debug.core.model.IVariable;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.ISelectionListener;
import org.eclipse.ui.ISelectionService;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.PlatformUI;

import de.cau.cs.kieler.klighd.ui.DiagramViewManager;
import de.cau.cs.kieler.klighd.ui.parts.DiagramViewPart;

/**
 * The view part that displays a graphical view of the currently selected variable.
 * 
 * @author cds
 */
public class VariablesDiagramViewPart extends DiagramViewPart {
    
    /** The view part's ID as registered with Eclipse. */
    public static final String VIEW_ID = "de.cau.cs.kieler.debukviz.variablesView";
    
    /** The selection listener that updates our view as new variables are selected. */
    private final DebukvizSelectionListener selectionListener = new DebukvizSelectionListener();

    
    @Override
    public void createPartControl(Composite parent) {
        super.createPartControl(parent);
        
        selectionListener.register();
    }

    @Override
    public void dispose() {
        super.dispose();
        
        selectionListener.unregister();
    }
    
    
    /**
     * A listener that listens to variable selections.
     */
    private final class DebukvizSelectionListener implements ISelectionListener {

        /**
         * Register selection listener to selection service.
         */
        public void register() {
            final DebukvizSelectionListener sl = this;
            
            PlatformUI.getWorkbench().getDisplay().asyncExec(new Runnable() {
                public void run() {
                    ISelectionService selectionService =
                            PlatformUI.getWorkbench().getActiveWorkbenchWindow().getSelectionService();
                    selectionService.addSelectionListener(sl);
                }
            });
        }
        
        /**
         * Unregister selection listener from selection service.
         */
        public void unregister() {
            final DebukvizSelectionListener sl = this;
            
            PlatformUI.getWorkbench().getDisplay().asyncExec(new Runnable() {
                public void run() {
                    ISelectionService selectionService =
                            PlatformUI.getWorkbench().getActiveWorkbenchWindow().getSelectionService();
                    selectionService.removeSelectionListener(sl);
                }
            });
        }

        /**
         * {@inheritDoc}
         * 
         * If selection is an instance of {@link StructuredSelection} and the first element is an
         * instance of {@link IVariable}, update our variables diagram view.
         */
        public void selectionChanged(IWorkbenchPart part, ISelection selection) {
            if (selection instanceof StructuredSelection) {
                Object firstElement = ((StructuredSelection) selection).getFirstElement();
                if (firstElement instanceof IVariable) {
                    IVariable var = (IVariable) firstElement;
                    
                    if (getViewContext() == null) {
                        initialize(var, null, null);
                    } else {
                        DiagramViewManager.updateView(getViewContext(), var);
                    }
                }
            }
        }
    }
}
