package org.eclipse.mita.base.typesystem.solver

import com.google.inject.Inject
import java.util.Collections
import java.util.HashMap
import java.util.Map
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.naming.QualifiedName

class SymbolTable { 
	
	protected final Map<QualifiedName, EObject> content = new HashMap;
	
	@Inject
	protected IQualifiedNameProvider nameProvider;
	
	public def put(EObject obj) {
		val fqn = nameProvider.getFullyQualifiedName(obj);
		if(content.containsKey(fqn)) {
			throw new IllegalArgumentException('''fqn already known: «fqn»''');
		}
		this.content.put(fqn, obj);
	}
	
	public def getContent() {
		return Collections.unmodifiableMap(this.content);
	}

	public def get(EObject obj) {
		return content.get(nameProvider.getFullyQualifiedName(obj));
	}
	
	override toString() {
		val res = new StringBuilder()
		
		content.forEach[p1, p2|
			res.append("\t")
			res.append(p1)
			res.append(": ")
			res.append(p2)
			res.append("\n")
		]
		
		return res.toString
	}

}
