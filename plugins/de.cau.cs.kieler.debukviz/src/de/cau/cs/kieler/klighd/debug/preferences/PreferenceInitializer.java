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
package de.cau.cs.kieler.klighd.debug.preferences;

import org.eclipse.core.runtime.preferences.AbstractPreferenceInitializer;
import org.eclipse.jface.preference.IPreferenceStore;

import de.cau.cs.kieler.klighd.debug.KlighdDebugPlugin;

/**
 * Preference initializer for the KlighdDebug plugin.
 * 
 * @author hwi
 */
public class PreferenceInitializer extends AbstractPreferenceInitializer {

    /**
     * {@inheritDoc}
     */
    @Override
    public void initializeDefaultPreferences() {
        IPreferenceStore preferenceStore = KlighdDebugPlugin.getDefault().getPreferenceStore();

        preferenceStore.setDefault(KlighdDebugPlugin.LAYOUT, KlighdDebugPlugin.STANDARD_LAYOUT);
        preferenceStore.setDefault(KlighdDebugPlugin.HIERARCHY_DEPTH, 10);
        preferenceStore.setDefault(KlighdDebugPlugin.MAX_NODE_COUNT, 100);
    }

}
