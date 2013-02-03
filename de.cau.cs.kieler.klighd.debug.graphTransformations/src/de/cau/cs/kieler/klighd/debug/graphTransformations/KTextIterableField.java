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

import java.util.ArrayList;
import java.util.Iterator;
import java.util.NoSuchElementException;

import javax.inject.Inject;

import de.cau.cs.kieler.core.krendering.HorizontalAlignment;
import de.cau.cs.kieler.core.krendering.KDirectPlacementData;
import de.cau.cs.kieler.core.krendering.KPosition;
import de.cau.cs.kieler.core.krendering.KRenderingFactory;
import de.cau.cs.kieler.core.krendering.KText;
import de.cau.cs.kieler.core.krendering.VerticalAlignment;
import de.cau.cs.kieler.core.krendering.extensions.KRenderingExtensions;
import de.cau.cs.kieler.core.krendering.extensions.PositionReferenceX;
import de.cau.cs.kieler.core.krendering.extensions.PositionReferenceY;
import de.cau.cs.kieler.klighd.krendering.PlacementUtil;
import de.cau.cs.kieler.klighd.debug.graphTransformations.TableElement;

/**
 * @author Privat
 * 
 */
public class KTextIterableField implements Iterable<KText>, Iterator<KText> {

    @Inject
    private KRenderingExtensions kRenderingExtensions = new KRenderingExtensions();
    
//    public TextAlignment LEFT_ALIGN = TextAlignment.LEFT;
//    public TextAlignment RIGHT_ALIGN = TextAlignment.RIGHT;    
    
    // the field holding the KTexts
    private ArrayList<ArrayList<TableElement>> a = new ArrayList<ArrayList<TableElement>>();

    // a field to hold the maximum width/height of each KText in the current column/row
    private ArrayList<Float> maxWidth = new ArrayList<Float>();
    private ArrayList<Float> maxHeight = new ArrayList<Float>();

    // margings to place around the table of KTexts
    private float leftMargin = 0;
    private float topMargin = 0;
    private float rightMargin = 0;
    private float bottomMargin = 0;

    // the gap between each KText
    private float vGap = 0;
    private float hGap = 0;

    // the distance to the outer bounds of table
    private float[] toLeft;
    private float[] toTop;

    // the number of rows/columns in the table, just for performance and convenience
    private int totalRows = 0;
    private int totalColumns = 0;

    // counter for the Iterator
    private int countRow = -1;
    private int countColumn = 0;

    private TableElement header = new TableElement();

    public enum TextAlignment {
        LEFT, RIGHT, CENTER
    }

    protected static final KRenderingFactory renderingFactory = KRenderingFactory.eINSTANCE;

    /*
     * column ----> 
     * r 0.0 0.1 0.2 0.3 
     * o 1.0 1.1 1.2 1.3 
     * w 2.0 2.1 2.2 2.3 
     * | 3.0 3.1 3.2 3.3
     * | 4.0 4.1 4.2 4.3 
     * V
     */
    
    /**
     * @param header the header to set
     */
    public void setHeader(KText header) {
        this.header = new TableElement(header);
    }
    
    /**
     * @param header the header to set
     */
    public void setHeader(String header) {
        this.header = new TableElement(header);
    }

    public void set(KText kText, int row, int column) {
        ensureSize(row, column);
        a.get(row).set(column, new TableElement(kText));

        updateHorizontalAlign(row, column);
        updateVerticalAlign(row, column);
    }

    public void set(String text, int row, int column) {
        ensureSize(row, column);
        a.get(row).set(column, new TableElement(text));

        updateHorizontalAlign(row, column);
        updateVerticalAlign(row, column);
    }
    
    public void set(String text, int row, int column, TextAlignment align) {
        this.set(text, row, column);
        a.get(row).get(column).setAlign(align);
    }
    
    public void set(KText kText, int row, int column, TextAlignment align) {
        this.set(kText, row, column);
        a.get(row).get(column).setAlign(align);
    }

    /**
     * @param row
     */
    private void updateVerticalAlign(int row, int column) {
        // update maxHeight table
        float max = 0;
        ArrayList<TableElement> currentRow = a.get(row);
        for (int i = 0; i < totalColumns; i++) {
            max = Math.max(max, currentRow.get(i).getHeight());
        }
        maxHeight.set(row, max);

        // update toTop table
        float topGap;
        topGap = topMargin + ((header.getKtext() == null) ? 0 :  (header.getHeight() + vGap));
        for (int i = 0; i < totalRows; i++) {
            toTop[i] = topGap;
            topGap += toFloat(maxHeight.get(i)) + vGap;
        }
    }

    /**
     * @param column
     */
    private void updateHorizontalAlign(int row, int column) {
        // update maxWidth table
        float max = 0;
        for (int i = 0; i < totalRows; i++) {
            max = Math.max(max, a.get(i).get(column).getWidth());
        }
        maxWidth.set(column, max);

        // update toLeft table
        float leftGap = leftMargin;
        for (int i = 0; i < totalColumns; i++) {
            toLeft[i] = leftGap;
            leftGap += toFloat(maxWidth.get(i)) + hGap;
        }
    }

    private void ensureSize(int inRow, int inColumn) {
        int row = inRow + 1;
        int column = inColumn + 1;

        if (totalRows < row) {
            for (int i = totalRows; i < row; i++) {
                // add a new ArrayList<TableElement>
                ArrayList<TableElement> newRow = new ArrayList<TableElement>(totalColumns);
                // fill it with null values
                for (int j = 0; j < totalColumns; j++) {
                    newRow.add(new TableElement());
                }
                a.add(newRow); 
                maxHeight.add(null);
            }
            totalRows = row;
            toTop = new float[row];
        }
        
        if (totalColumns < column) {
            for (int i = totalColumns; i < column; i++) {
                for (int j = 0; j < totalRows; j++) {
                    a.get(j).add(new TableElement());
                }
                maxWidth.add(null);
            }
            totalColumns = column;
            toLeft = new float[column];
        }
    }

    /**
     * @param topMargin
     *            the topMargin to set
     */
    public void setTopMargin(float topMargin) {
        this.topMargin = topMargin;
    }

    /**
     * @param rightMargin
     *            the rightMargin to set
     */
    public void setRightMargin(float rightMargin) {
        this.rightMargin = rightMargin;
    }

    /**
     * @param bottomMargin
     *            the bottomMargin to set
     */
    public void setBottomMargin(float bottomMargin) {
        this.bottomMargin = bottomMargin;
    }

    /**
     * @param leftMargin
     *            the leftMargin to set
     */
    public void setLeftMargin(float leftMargin) {
        this.leftMargin = leftMargin;
    }

    /**
     * @param vGap
     *            the vGap (vertical gap between elements) to set
     */
    public void setvGap(float vGap) {
        this.vGap = vGap;
    }

    /**
     * @param hGap
     *            the hGap (horizontal gap between elements) to set
     */
    public void sethGap(float hGap) {
        this.hGap = hGap;
    }

    /**
     * @param totalRows
     *            the totalRows to set
     */
    public void setTotalRows(int totalRows) {
        ensureSize(totalRows, totalColumns);
    }

    /**
     * @param totalColumns
     *            the totalColumns to set
     */
    public void setTotalColumns(int totalColumns) {
        ensureSize(totalRows, totalColumns);
    }

    /**
     * @param topMargin
     * @param rightMargin
     * @param bottomMargin
     * @param leftMargin
     * @param vGap
     * @param hGap
     * @param totalRows
     * @param totalColumns
     */
    public KTextIterableField(int rows, int columns, float topMargin, float rightMargin,
            float bottomMargin, float leftMargin, float vGap, float hGap) {
        super();
        this.topMargin = topMargin;
        this.rightMargin = rightMargin;
        this.bottomMargin = bottomMargin;
        this.leftMargin = leftMargin;
        this.vGap = vGap;
        this.hGap = hGap;

        ensureSize(rows, columns);
    }

    /**
     * @param topMargin
     * @param rightMargin
     * @param bottomMargin
     * @param leftMargin
     * @param vGap
     * @param hGap
     */
    public KTextIterableField(float topMargin, float rightMargin, float bottomMargin,
            float leftMargin, float vGap, float hGap) {
        super();
        this.topMargin = topMargin;
        this.rightMargin = rightMargin;
        this.bottomMargin = bottomMargin;
        this.leftMargin = leftMargin;
        this.vGap = vGap;
        this.hGap = hGap;
    }

    /**
     * Empty constructor
     */
    public KTextIterableField() {
        super();
    }

    /**
     * {@inheritDoc}
     */
    public Iterator<KText> iterator() {
        return this;
    }

    /**
     * {@inheritDoc}
     */
    public boolean hasNext() {
        int j = countColumn;
        
        if (countRow == -1) {
            if (header.getkText() != null) {
                return true;
            }
            countRow = 0;
            countColumn = 0;
        }

        for (int i = countRow; i < totalRows; i++) {
            while (j < totalColumns) {
                if (a.get(i).get(j) != null) {
                    return true;
                }
                j++;
            }
            j = 0;
        }
        return false;
    }

    /**
     * {@inheritDoc}
     */
    public KText next() {
        KDirectPlacementData placement;
        KPosition positionTL;
        KPosition positionBR;
        boolean hit = false;
        TableElement elem = null;
        float minniGap = 0;
        
        if (countRow == -1) {
            if (header.getkText() != null) {
                placement = renderingFactory.createKDirectPlacementData();
                float outerGap = (width() - header.getWidth() - leftMargin - rightMargin) / 2;
                positionTL = kRenderingExtensions.createKPosition(PositionReferenceX.LEFT,
                        outerGap + leftMargin, 0, PositionReferenceY.TOP, topMargin, 0);
                positionBR = kRenderingExtensions.createKPosition(PositionReferenceX.RIGHT,
                        outerGap + rightMargin, 0, PositionReferenceY.BOTTOM, bottomMargin, 0);
                placement.setTopLeft(positionTL);
                placement.setBottomRight(positionBR);
                header.getkText().setPlacementData(placement);
                
                countRow = 0;
                countColumn = 0;
                return header.getkText();
            }
        }
        
        while (countRow < totalRows && !hit) {
            while (countColumn < totalColumns && !hit) {
                elem = a.get(countRow).get(countColumn);
                if (elem.getKtext() != null) {
                    hit = true;
                    if(elem.getAlign() == TextAlignment.RIGHT) {
                        minniGap = maxWidth.get(countColumn) - elem.getWidth();
                    } else if(elem.getAlign() == TextAlignment.CENTER) {
                        minniGap = (maxWidth.get(countColumn) - elem.getWidth()) / 2;
                    } else {
                        minniGap = 0;
                    }
                    placement = renderingFactory.createKDirectPlacementData();
                    positionTL = kRenderingExtensions.createKPosition(PositionReferenceX.LEFT,
                            toLeft[countColumn] + minniGap, 0, PositionReferenceY.TOP, toTop[countRow], 0);
                    positionBR = kRenderingExtensions.createKPosition(PositionReferenceX.RIGHT,
                            rightMargin, 0, PositionReferenceY.BOTTOM, bottomMargin, 0);
                    placement.setTopLeft(positionTL);
                    placement.setBottomRight(positionBR);
                    elem.getKtext().setPlacementData(placement);
                }
                countColumn++;
            }
            if (countColumn == totalColumns) {
                countRow++;
                countColumn = 0;
            }
        }
        if (hit) {
            return elem.getKtext();
        } else {
            throw new NoSuchElementException();
        }
    }

    /**
     * {@inheritDoc}
     */
    public void remove() {
        throw new UnsupportedOperationException();
    }

    public float width() {
        float width = 0;
        for (int i = 0; i < totalColumns; i++) {
            width += vGap + toFloat(maxWidth.get(i));
        }
        width -= vGap;
        width = Math.max(width, header.getWidth());
        return leftMargin + width + rightMargin;
    }

    public float height() {
        float height = topMargin;
        
        if(header.getkText() != null) {
            height += header.getHeight() + vGap;
        }
        
        for (int i = 0; i < totalRows; i++) {
            height += hGap + toFloat(maxHeight.get(i));
        }
        
        return height + bottomMargin - hGap;
    }

    private float toFloat(Float i) {
       return (i == null) ? 0 : i;
    }

    public void printStats() {
        System.out.println("-----------");
        System.out.println("Stats");
        System.out.println("-----------");
        System.out.println("total width: " + width());
        System.out.println("total height: " + height());
        
        System.out.println("a rows     : " + a.size());
        for (int i = 0; i < a.size(); i++) {
            System.out.println("a columns " + i + " :" + a.get(0).size());
        }
        for (int j = 0; j < totalRows; j++) {
            for (int i = 0; i < totalColumns; i++) {
                System.out.println("---");
                /*
                 * System.out.println("Element: " + j + "/" + i); System.out.println("ToLeft: " +
                 * toFloat(toLeft[i])); System.out.println("Width: " +
                 * toFloat(width.get(j).get(i))); System.out.println("toRight: " +
                 * toFloat(toRight[i])); System.out.println("toTop: " + toFloat(toTop[j]));
                 * System.out.println("Height: " + toFloat(height.get(j).get(i)));
                 * System.out.println("toBottom: " + toFloat(toBottom[j]));
                 */
                System.out.println(j + "/" + i);
                System.out.println((toLeft[i]));
                System.out.println((a.get(j).get(i).getWidth()));
                System.out.println((toTop[j]));
                System.out.println((a.get(j).get(i).getHeight()));
            }
        }
        System.out.println("-");
        System.out.println("MaxHeight: " + maxHeight);
        System.out.println("MaxWidth: " + maxWidth);
    }
    
    public int columnCount() {
        if (a.size() == 0) {
            return 0;
        } else {
            return a.get(0).size();
        }
    }

    public int rowCount() {
        return a.size();
    }
}
