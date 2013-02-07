package de.cau.cs.kieler.klighd.debug.dialog;

import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.MessageBox;
import org.eclipse.ui.PlatformUI;

public class KlighdDebugDialog {

    private static final MessageBox messageBox = 
            new MessageBox(PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell(),
                    SWT.ICON_ERROR | SWT.OK);
    
    private static boolean shown = false;
      
    public static void resetShown() {
        shown = false;
    }
    
    public static void open() {
        // Only show once per main transformation
        if (!shown) {
            messageBox.setText("Maximal number of nodes exceeded");
            messageBox.setMessage("Maybe the visualization is incomplete and the layout algorithm fails!");
            messageBox.open();
            shown = true;
        }
    } 
}
