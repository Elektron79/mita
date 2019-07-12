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

package org.eclipse.mita.platform.xdk110.io

import org.eclipse.mita.library.stdlib.GenericPlatformSizeInferrer
import org.eclipse.mita.program.SignalInstance

class SDCardSizeInferrer extends GenericPlatformSizeInferrer {
		
	override getLengthParameterName(SignalInstance sigInst) {
		return SDCardGenerator.getSizeName(sigInst);
	}
	
}