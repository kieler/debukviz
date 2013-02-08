package de.cau.cs.kieler.klighd.debug.preferences;

import org.eclipse.jface.preference.FieldEditorPreferencePage;
import org.eclipse.jface.preference.RadioGroupFieldEditor;

import de.cau.cs.kieler.klighd.debug.KlighdDebugPlugin;

public class KlighdDebugPreferencePage extends FieldEditorPreferencePage{

	@Override
	protected void createFieldEditors() {
		String[][] labelAndValues = new String[3][3];
		labelAndValues[0][0] = "Standard layout";
		labelAndValues[0][1] = "true";
		labelAndValues[1][0] = "Flat layout";
		labelAndValues[1][1] = "false";
		labelAndValues[2][0] = "Hierarchy layout";
		labelAndValues[2][1] = "false";
		RadioGroupFieldEditor radioFE = new RadioGroupFieldEditor(
				KlighdDebugPlugin.LAYOUT, 
				"Layout options", 
				3, 
				labelAndValues, getFieldEditorParent());
	}

}
