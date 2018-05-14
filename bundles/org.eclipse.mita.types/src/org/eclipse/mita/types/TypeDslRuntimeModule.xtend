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
package org.eclipse.mita.types

import org.eclipse.mita.types.scoping.TypesGlobalScopeProvider

import com.google.inject.Binder
import org.eclipse.xtext.conversion.IValueConverterService
import org.eclipse.xtext.scoping.IGlobalScopeProvider
import org.yakindu.base.expressions.inferrer.ExpressionsTypeInferrer
import org.yakindu.base.expressions.terminals.ExpressionsValueConverterService
import org.yakindu.base.types.inferrer.ITypeSystemInferrer
import org.yakindu.base.types.typesystem.ITypeSystem

class TypeDslRuntimeModule extends AbstractTypeDslRuntimeModule {

	override configure(Binder binder) {
		super.configure(binder)
		binder.bind(ITypeSystem).toInstance(MitaTypeSystem.getInstance())
	}

	override Class<? extends IGlobalScopeProvider> bindIGlobalScopeProvider() {
		return TypesGlobalScopeProvider
	}

	def Class<? extends ITypeSystemInferrer> bindITypeSystemInferrer() {
		return ExpressionsTypeInferrer
	}

	override Class<? extends IValueConverterService> bindIValueConverterService() {
		return ExpressionsValueConverterService
	}
	
}