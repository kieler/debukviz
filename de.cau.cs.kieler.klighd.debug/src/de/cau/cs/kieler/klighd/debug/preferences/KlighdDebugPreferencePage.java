package de.cau.cs.kieler.klighd.debug.preferences;

import org.eclipse.jface.preference.FieldEditorPreferencePage;
import org.eclipse.jface.preference.IntegerFieldEditor;
import org.eclipse.jface.preference.RadioGroupFieldEditor;
import org.eclipse.jface.preference.ScaleFieldEditor;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPreferencePage;

import de.cau.cs.kieler.core.kivi.CombinationDescriptor;
import de.cau.cs.kieler.core.kivi.KiVi;
import de.cau.cs.kieler.klighd.debug.KlighdDebugPlugin;

public class KlighdDebugPreferencePage extends FieldEditorPreferencePage implements IWorkbenchPreferencePage {

	@Override
	protected void createFieldEditors() {
		String[][] labelAndValues = new String[3][2];
		labelAndValues[0][0] = "Standard &layout";
		labelAndValues[0][1] = KlighdDebugPlugin.STANDARD_LAYOUT;
		labelAndValues[1][0] = "Flat l&ayout";
		labelAndValues[1][1] = KlighdDebugPlugin.FLAT_LAYOUT;
		labelAndValues[2][0] = "Hierarchy lay&out";
		labelAndValues[2][1] = KlighdDebugPlugin.HIERARCHY_LAYOUT;
		
		addField(new RadioGroupFieldEditor(
		        KlighdDebugPlugin.LAYOUT,
		        "Layout options", 
		        1,
		        labelAndValues,
		        getFieldEditorParent()));
		
		
	        addField(new IntegerFieldEditor(
	                KlighdDebugPlugin.MAX_NODE_COUNT, 
	                "Maximal number of nodes", 
	                getFieldEditorParent()));
	        addField(new IntegerFieldEditor(
                        KlighdDebugPlugin.HIERARCHY_DEPTH, 
                        "Maximal hierarchy depth", 
                        getFieldEditorParent()));
	}

    public void init(IWorkbench workbench) {
        setPreferenceStore(KlighdDebugPlugin.getDefault().getPreferenceStore());
        setDescription("Options for the KIELER debug visualization");   
    }

}
