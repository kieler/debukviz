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
package de.cau.cs.kieler.klighd.debug.preferences;

import org.eclipse.jface.preference.FieldEditorPreferencePage;
import org.eclipse.jface.preference.IntegerFieldEditor;
import org.eclipse.jface.preference.RadioGroupFieldEditor;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPreferencePage;

import de.cau.cs.kieler.klighd.debug.KlighdDebugPlugin;

/**
 * Preference page of the KLighD Debug plug-in.
 * 
 * @author hwi
 */
public class KlighdDebugPreferencePage extends FieldEditorPreferencePage implements
        IWorkbenchPreferencePage {

    @Override
    protected void createFieldEditors() {
        String[][] labelAndValues = new String[3][2];
        labelAndValues[0][0] = "Standard";
        labelAndValues[0][1] = KlighdDebugPlugin.STANDARD_LAYOUT;
        labelAndValues[1][0] = "Flat";
        labelAndValues[1][1] = KlighdDebugPlugin.FLAT_LAYOUT;
        labelAndValues[2][0] = "Hierarchical";
        labelAndValues[2][1] = KlighdDebugPlugin.HIERARCHY_LAYOUT;

        addField(new RadioGroupFieldEditor(KlighdDebugPlugin.LAYOUT, "Layout type:", 1,
                labelAndValues, getFieldEditorParent()));
        addField(new IntegerFieldEditor(KlighdDebugPlugin.MAX_NODE_COUNT,
                "Maximal number of nodes:", getFieldEditorParent()));
        addField(new IntegerFieldEditor(KlighdDebugPlugin.HIERARCHY_DEPTH,
                "Maximal hierarchy depth:", getFieldEditorParent()));
    }

    public void init(IWorkbench workbench) {
        setPreferenceStore(KlighdDebugPlugin.getDefault().getPreferenceStore());
    }

}
