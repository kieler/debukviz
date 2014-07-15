/*
 * DebuKViz - Kieler Debug Visualization
 * 
 * A part of OpenKieler
 * https://github.com/OpenKieler
 * 
 * Copyright 2014 by
 * + Christian-Albrechts-University of Kiel
 *   + Department of Computer Science
 *     + Real-Time and Embedded Systems Group
 * 
 * This code is provided under the terms of the Eclipse Public License (EPL).
 * See the file epl-v10.html for the license text.
 */
package de.cau.cs.kieler.debukviz.dialog;

import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.MessageBox;
import org.eclipse.ui.PlatformUI;

/**
 * A dialog helper class that opens a concrete dialog only if that dialog hasn't been opened yet.
 */
public class KlighdDebugDialog {
    
    /** Whether the dialog has already been shown or not. */
    private static boolean shown = false;
    
    /**
     * Call to allow the dialog to be shown again.
     */
    public static void resetShown() {
        shown = false;
    }
    
    /**
     * Shows the dialog if it hasn't been shown already.
     */
    public static void open() {
        if (!shown) {
            MessageBox messageBox = new MessageBox(
                    PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell(),
                    SWT.ICON_ERROR | SWT.OK);
            messageBox.setText("Maximal number of nodes exceeded");
            messageBox.setMessage("Maybe the visualization is incomplete and the layout algorithm fails!");
            messageBox.open();
            
            shown = true;
        }
    }
    
}
