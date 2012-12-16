package de.cau.cs.kieler.klighd.debug.selection;

import org.eclipse.jface.viewers.ISelection;
import org.eclipse.ui.ISelectionListener;
import org.eclipse.ui.IWorkbenchPart;

public class SelectionListener implements ISelectionListener{

    private final static SelectionListener INSTANCE = new SelectionListener();
    
    @Override
    public void selectionChanged(IWorkbenchPart part, ISelection selection) {
        // TODO Auto-generated method stub
        
    }

}
