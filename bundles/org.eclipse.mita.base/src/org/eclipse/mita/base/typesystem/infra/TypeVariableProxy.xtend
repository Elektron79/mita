package org.eclipse.mita.base.typesystem.infra

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.mita.base.typesystem.types.TypeVariable
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.EqualsHashCode
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.scoping.IScopeProvider

@EqualsHashCode
@Accessors
class TypeVariableProxy extends TypeVariable {
	static Integer instanceCount = 0;
	// name of the origin member we want to resolve
	protected final QualifiedName targetQID;	
	protected final EReference reference;
	
	new(EObject origin, EReference reference) {
		this(origin, '''p_«instanceCount++»''', reference, QualifiedName.create(NodeModelUtils.findNodesForFeature(origin, reference)?.head?.text?.trim?.split("\\.")));
	}
	
	new(EObject origin, EReference reference, QualifiedName qualifiedName) {
		this(origin, '''p_«instanceCount++»''', reference, qualifiedName);
	}
	
	new(EObject origin, String name, EReference reference, QualifiedName qualifiedName) {
		super(origin, name);
		this.reference = reference;
		this.targetQID = qualifiedName;
	}
	
	override replaceProxies(IScopeProvider scopeProvider) {
		val scope = scopeProvider.getScope(origin, reference);
		TypeVariableAdapter.get(scope.getSingleElement(targetQID).EObjectOrProxy);
	}
}