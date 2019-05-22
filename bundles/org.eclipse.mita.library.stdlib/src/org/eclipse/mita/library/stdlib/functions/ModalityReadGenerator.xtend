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

package org.eclipse.mita.library.stdlib.functions

import com.google.common.base.Optional
import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.mita.base.expressions.ElementReferenceExpression
import org.eclipse.mita.program.generator.AbstractFunctionGenerator
import org.eclipse.mita.program.generator.CodeFragment
import org.eclipse.mita.program.generator.StatementGenerator

class ModalityReadGenerator extends AbstractFunctionGenerator {
	
	@Inject
	protected StatementGenerator statementGenerator
	
	override callShouldBeUnraveled(ElementReferenceExpression expression) {
		return false;
	}
	
	override generate(Optional<EObject> target, CodeFragment resultVariableName, ElementReferenceExpression functionCall) {
		if(resultVariableName === null) {
			CodeFragment.EMPTY
		} else {
			codeFragmentProvider.create('''«resultVariableName» = «statementGenerator.code(functionCall.arguments.get(0).value)»;''');			
		}
	}
	
}