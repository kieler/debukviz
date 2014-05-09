/*
 * KIELER - Kiel Integrated Environment for Layout Eclipse RichClient
 *
 * http://www.informatik.uni-kiel.de/rtsys/kieler/
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
