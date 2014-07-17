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
package de.cau.cs.kieler.debukviz.preferences;

import org.eclipse.jface.preference.FieldEditorPreferencePage;
import org.eclipse.jface.preference.IntegerFieldEditor;
import org.eclipse.jface.preference.RadioGroupFieldEditor;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPreferencePage;

import de.cau.cs.kieler.debukviz.DebuKVizPlugin;

/**
 * Preference page of this plug-in.
 */
public final class DebuKVizPreferencePage extends FieldEditorPreferencePage
    implements IWorkbenchPreferencePage {

    @Override
    protected void createFieldEditors() {
        String[][] labelAndValues = new String[3][2];
        labelAndValues[0][0] = "Standard";
        labelAndValues[0][1] = DebuKVizPlugin.STANDARD_LAYOUT;
        labelAndValues[1][0] = "Flat";
        labelAndValues[1][1] = DebuKVizPlugin.FLAT_LAYOUT;
        labelAndValues[2][0] = "Hierarchical";
        labelAndValues[2][1] = DebuKVizPlugin.HIERARCHY_LAYOUT;

        addField(new RadioGroupFieldEditor(DebuKVizPlugin.LAYOUT, "Layout type:", 1,
                labelAndValues, getFieldEditorParent()));
        addField(new IntegerFieldEditor(DebuKVizPlugin.MAX_NODE_COUNT,
                "Maximal number of nodes:", getFieldEditorParent()));
        addField(new IntegerFieldEditor(DebuKVizPlugin.HIERARCHY_DEPTH,
                "Maximal hierarchy depth:", getFieldEditorParent()));
    }

    public void init(IWorkbench workbench) {
        setPreferenceStore(DebuKVizPlugin.getDefault().getPreferenceStore());
    }

}
