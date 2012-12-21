package de.cau.cs.kieler.klighd.debug.visualization;

import java.util.LinkedList;

import de.cau.cs.kieler.core.krendering.KContainerRendering;
import de.cau.cs.kieler.core.util.Pair;

public class KlighdDebugRenderingInfo {
	
	private KlighdDebugField field;
	private Pair<KlighdDebugField,KlighdDebugField> edge;
	private LinkedList<KlighdDebugField> next;
	private Pair<KlighdDebugField,KContainerRendering> fieldVisualization;
	private Pair<Pair<KlighdDebugField,KlighdDebugField>,KContainerRendering> edgeVisualization;
	
	public KlighdDebugField getField() {
		return field;
	}
	public void setField(KlighdDebugField field) {
		this.field = field;
	}
	public Pair<KlighdDebugField, KlighdDebugField> getEdge() {
		return edge;
	}
	public void setEdge(Pair<KlighdDebugField, KlighdDebugField> edge) {
		this.edge = edge;
	}
	public LinkedList<KlighdDebugField> getNext() {
		return next;
	}
	public void setNext(LinkedList<KlighdDebugField> next) {
		this.next = next;
	}
	public Pair<KlighdDebugField, KContainerRendering> getFieldVisualization() {
		return fieldVisualization;
	}
	public void setFieldVisualization(
			Pair<KlighdDebugField, KContainerRendering> fieldVisualization) {
		this.fieldVisualization = fieldVisualization;
	}
	public Pair<Pair<KlighdDebugField, KlighdDebugField>, KContainerRendering> getEdgeVisualization() {
		return edgeVisualization;
	}
	public void setEdgeVisualization(
			Pair<Pair<KlighdDebugField, KlighdDebugField>, KContainerRendering> edgeVisualization) {
		this.edgeVisualization = edgeVisualization;
	}
	
	public KlighdDebugRenderingInfo(
			KlighdDebugField field,
			Pair<KlighdDebugField, KlighdDebugField> edge,
			LinkedList<KlighdDebugField> next,
			Pair<KlighdDebugField, KContainerRendering> fieldVisualization,
			Pair<Pair<KlighdDebugField, KlighdDebugField>, KContainerRendering> edgeVisualization) {
		this.field = field;
		this.edge = edge;
		this.next = next;
		this.fieldVisualization = fieldVisualization;
		this.edgeVisualization = edgeVisualization;
	}
	
	
	
}
