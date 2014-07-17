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

import org.eclipse.core.runtime.preferences.AbstractPreferenceInitializer;
import org.eclipse.jface.preference.IPreferenceStore;

import de.cau.cs.kieler.debukviz.DebuKVizPlugin;

/**
 * Initializes preferences used by this plug-in.
 */
public final class PreferenceInitializer extends AbstractPreferenceInitializer {

    /**
     * {@inheritDoc}
     */
    @Override
    public void initializeDefaultPreferences() {
        IPreferenceStore preferenceStore = DebuKVizPlugin.getDefault().getPreferenceStore();

        preferenceStore.setDefault(DebuKVizPlugin.LAYOUT, DebuKVizPlugin.STANDARD_LAYOUT);
        preferenceStore.setDefault(DebuKVizPlugin.HIERARCHY_DEPTH, 10);
        preferenceStore.setDefault(DebuKVizPlugin.MAX_NODE_COUNT, 100);
    }

}
