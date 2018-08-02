/********************************************************************************
 * Copyright (c) 2017, 2018 Bosch Connected Devices and Solutions GmbH.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0.
 *
 * Contributors:
 *    Bosch Connected Devices and Solutions GmbH - initial contribution
 *
 * SPDX-License-Identifier: EPL-2.0
 ********************************************************************************/

/*
 * generated by Xtext 2.10.0
 */
package org.eclipse.mita.base.scoping

import org.eclipse.emf.ecore.EReference
import org.eclipse.mita.base.expressions.Argument
import org.eclipse.mita.base.expressions.ElementReferenceExpression
import org.eclipse.mita.base.expressions.FeatureCall
import org.eclipse.mita.base.types.Operation
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.Scopes
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider

/**
 * This class contains custom scoping description.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#scoping
 * on how and when to use it.
 */
class TypeDslScopeProvider extends AbstractDeclarativeScopeProvider {
	
	
	def scope_Argument_parameter(Argument object, EReference ref) {
		var parameters = object?.eContainer?.operation?.parameters
		return if(parameters !== null) Scopes.scopeFor(parameters.parameters) else IScope.NULLSCOPE;
	}

	def scope_Argument_parameter(ElementReferenceExpression exp, EReference ref) {
		var parameters = exp?.operation?.parameters
		return if(parameters !== null) Scopes.scopeFor(parameters.parameters) else IScope.NULLSCOPE;
	}

	def scope_Argument_parameter(FeatureCall fc, EReference ref) {
		var parameters = fc?.operation?.parameters
		return if(parameters !== null) Scopes.scopeFor(parameters.parameters) else IScope.NULLSCOPE;
	}

	def dispatch getOperation(ElementReferenceExpression it) {
		return if (reference instanceof Operation)
			reference as Operation
		else
			null
	}
	
	def dispatch getOperation(EObject object) {
	}
	
}
