package de.cau.cs.kieler.klighd.debug;

import org.eclipse.debug.core.model.IVariable;

import de.cau.cs.kieler.core.kgraph.KNode;

public interface IKlighdDebug {

    public KNode transform(IVariable model);
}
