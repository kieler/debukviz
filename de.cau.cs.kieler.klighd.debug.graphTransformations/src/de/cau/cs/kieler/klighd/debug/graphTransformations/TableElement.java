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
package de.cau.cs.kieler.klighd.debug.graphTransformations;

import javax.inject.Inject;

import de.cau.cs.kieler.core.krendering.HorizontalAlignment;
import de.cau.cs.kieler.core.krendering.KRenderingFactory;
import de.cau.cs.kieler.core.krendering.KText;
import de.cau.cs.kieler.core.krendering.VerticalAlignment;
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions;
import de.cau.cs.kieler.klighd.debug.graphTransformations.KTextIterableField.TextAlignment;
import de.cau.cs.kieler.klighd.krendering.PlacementUtil;

/**
 * @author tit
 *
 */
public class TableElement {
    
    @Inject
    private KRenderingExtensions kRenderingExtensions = new KRenderingExtensions();

    protected static final KRenderingFactory renderingFactory = KRenderingFactory.eINSTANCE;

    private KText kText;
    private float width;
    private float height;
    private TextAlignment align = TextAlignment.LEFT;

    /**
     * @return the text
     */
    public KText getKtext() {
        return getkText();
    }

    /**
     * @param text
     *            the text to set
     */
    public void setKtext(KText kText) {
        this.setkText(kText);
    }

    /**
     * @return the align
     */
    public TextAlignment getAlign() {
        return align;
    }

    /**
     * @param align
     *            the align to set
     */
    public void setAlign(TextAlignment align) {
        this.align = align;
    }

    /**
     * @return the width
     */
    public float getWidth() {
        return width;
    }

    /**
     * @return the height
     */
    public float getHeight() {
        return height;
    }

    /**
     * 
     */
    public TableElement() {
        this.setkText((KText) null);
    }

    /**
     * @param kText
     */
    public TableElement(KText kText) {
        this(kText, TextAlignment.LEFT);
    }

    /**
     * @param kText
     * @param align
     */
    public TableElement(KText kText, TextAlignment align) {
        super();
        setkText(kText);
        this.align = align;
    }

    /**
     * @param kText
     */
    public TableElement(String text) {
        this(text, TextAlignment.LEFT);
    }

    /**
     * @param kText
     * @param align
     */
    public TableElement(String text, TextAlignment align) {
        super();
        setkText(text);
        this.align = align;
    }

    /**
     * @param kText the kText to set
     */
    public void setkText(String text) {
        KText kText = renderingFactory.createKText();
        kText.setText(text);
        setkText(kText);
    }
    
    /**
     * @param kText the kText to set
     */
    public void setkText(KText kText) {
        if (kText == null) {
            height = 0;
            width = 0;
        } else {
            kRenderingExtensions.setHorizontalAlignment(kText, HorizontalAlignment.LEFT);
            kRenderingExtensions.setVerticalAlignment(kText, VerticalAlignment.TOP);
            width = PlacementUtil.estimateTextSize(kText).getWidth();
            height = PlacementUtil.estimateTextSize(kText).getHeight();
        }
        this.kText = kText;
    }

    /**
     * @return the kText
     */
    public KText getkText() {
        return kText;
    }
}        
