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
package org.eclipse.mita.program.scoping

import com.google.common.base.Predicate
import com.google.inject.Inject
import java.util.Collections
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.mita.base.expressions.Argument
import org.eclipse.mita.base.expressions.ElementReferenceExpression
import org.eclipse.mita.base.expressions.Expression
import org.eclipse.mita.base.expressions.ExpressionsPackage
import org.eclipse.mita.base.expressions.FeatureCall
import org.eclipse.mita.base.scoping.TypesGlobalScopeProvider
import org.eclipse.mita.base.types.AnonymousProductType
import org.eclipse.mita.base.types.ComplexType
import org.eclipse.mita.base.types.EnumerationType
import org.eclipse.mita.base.types.NamedProductType
import org.eclipse.mita.base.types.Operation
import org.eclipse.mita.base.types.PresentTypeSpecifier
import org.eclipse.mita.base.types.StructureType
import org.eclipse.mita.base.types.SumAlternative
import org.eclipse.mita.base.types.SumType
import org.eclipse.mita.base.types.Type
import org.eclipse.mita.base.types.TypesPackage
import org.eclipse.mita.base.types.typesystem.ITypeSystem
import org.eclipse.mita.base.typesystem.types.AbstractType
import org.eclipse.mita.base.util.BaseUtils
import org.eclipse.mita.platform.AbstractSystemResource
import org.eclipse.mita.platform.PlatformPackage
import org.eclipse.mita.platform.Sensor
import org.eclipse.mita.platform.SystemResourceAlias
import org.eclipse.mita.program.ConfigurationItemValue
import org.eclipse.mita.program.IsDeconstructionCase
import org.eclipse.mita.program.IsDeconstructor
import org.eclipse.mita.program.Program
import org.eclipse.mita.program.ProgramPackage
import org.eclipse.mita.program.SignalInstance
import org.eclipse.mita.program.SystemEventSource
import org.eclipse.mita.program.SystemResourceSetup
import org.eclipse.mita.program.VariableDeclaration
import org.eclipse.mita.program.impl.VariableDeclarationImpl
import org.eclipse.mita.program.model.ModelUtils
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.naming.IQualifiedNameConverter
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.Scopes
import org.eclipse.xtext.scoping.impl.FilteringScope
import org.eclipse.xtext.scoping.impl.ImportNormalizer
import org.eclipse.xtext.scoping.impl.ImportScope
import org.eclipse.xtext.util.OnChangeEvictingCache

class ProgramDslScopeProvider extends AbstractProgramDslScopeProvider {

	@Inject
	IQualifiedNameConverter fqnConverter

	@Inject
	IQualifiedNameProvider qualifiedNameProvider
	
	@Inject
	ITypeSystem typeSystem
	

	override scope_Argument_parameter(Argument argument, EReference ref) {
		if (EcoreUtil2.getContainerOfType(argument, SystemResourceSetup) !== null) {
			return scopeInSetupBlock(argument, ref);
		} else {
			val ec = argument.eContainer;
			if (ec instanceof ElementReferenceExpression) {
				return scope_Argument_parameter(ec as ElementReferenceExpression, ref)
			} 
		}
		return IScope.NULLSCOPE;
	}

	override scope_Argument_parameter(ElementReferenceExpression exp, EReference _ref) {
		if (EcoreUtil2.getContainerOfType(exp, SystemResourceSetup) !== null) {
			scopeInSetupBlock(exp, _ref);
		} else {
			val nodes = NodeModelUtils.findNodesForFeature(exp,
				ExpressionsPackage.Literals.ELEMENT_REFERENCE_EXPRESSION__REFERENCE)
			if (nodes.isEmpty) {
				return super.scope_Argument_parameter(exp, _ref);
			} else {
				return exp.getCandidateParameterScope(nodes.head.text)
			}
		}
	}

	override scope_Argument_parameter(FeatureCall fc, EReference ref) {
		if (EcoreUtil2.getContainerOfType(fc, SystemResourceSetup) !== null) {
			scopeInSetupBlock(fc, ref);
		} else {
			val nodes = NodeModelUtils.findNodesForFeature(fc, ExpressionsPackage.Literals.ELEMENT_REFERENCE_EXPRESSION__REFERENCE)
			if (nodes.isEmpty) {
				return IScope.NULLSCOPE
			}
			fc.getCandidateParameterScope(nodes.head.text)
		}
	}

	static class CombiningScope implements IScope {
		var Iterable<IScope> scopes;

		public new(IScope s1, IScope s2) {
			scopes = #[s1, s2];
			if (s1 === null || s2 === null) {
				throw new NullPointerException;
			}
		}

		public new(Iterable<IScope> scopes) {
			this.scopes = scopes.filterNull;
		}

		override getAllElements() {
			return scopes.flatMap[it.allElements];
		}

		override getElements(QualifiedName name) {
			return scopes.flatMap[it.getElements(name)];
		}

		override getElements(EObject object) {
			return scopes.flatMap[it.getElements(object)];
		}

		override getSingleElement(QualifiedName name) {
			// try s1 first, then s2
			val els = getElements(name);
			if (els.empty) {
				return null;
			}
			return els.head;
		}

		override getSingleElement(EObject object) {
			// try s1 first, then s2
			val els = getElements(object);
			if (els.empty) {
				return null;
			}
			return els.head;
		}

	}

	def protected IScope getCandidateParameterScope(EObject context, String crossRefString) {
		return getCandidateParameterScope(context, crossRefString, delegate.getScope(context, ExpressionsPackage.Literals.ELEMENT_REFERENCE_EXPRESSION__REFERENCE));
	}
	
	def protected IScope getCandidateParameterScope(IScope globalScope, SumType superType, SumAlternative subType, String constructor) {
		return doGetCandidateParameterScope(subType, createConstructorScope(globalScope, superType, constructor));
	}
	
	def protected dispatch doGetCandidateParameterScope(SumAlternative type, IScope constructorScope) {
		// fall-back
		return IScope.NULLSCOPE;
	}
	
	def protected dispatch doGetCandidateParameterScope(NamedProductType subType, IScope constructorScope) {
		if (!subType.eIsProxy) {
			return Scopes.scopeFor(subType.parameters);
		} else {
			return constructorScope;
		}
	}
	
	def protected dispatch doGetCandidateParameterScope(AnonymousProductType subType, IScope constructorScope) {
		if (!subType.eIsProxy) {
			if (subType.typeSpecifiers.length == 1) {
				val maybeSType = subType.typeSpecifiers.head;
				if (!maybeSType.eIsProxy && maybeSType.type instanceof StructureType) {
					val sType = maybeSType.type as StructureType;
					return Scopes.scopeFor(sType.parameters);
				}
			}
		} 
		return constructorScope;
		
	}
	
	def protected createConstructorScope(IScope globalScope, Type type, String constructor) {
		val name = type.name + "." + constructor
		val qName = fqnConverter.toQualifiedName(name)
		return new ImportScope(#[new ImportNormalizer(qName, true, false)], globalScope, null,
			ExpressionsPackage.Literals.ELEMENT_REFERENCE_EXPRESSION__REFERENCE.EReferenceType, false) as IScope;
	}
	
	def protected IScope getCandidateParameterScope(EObject context, String crossRefString, IScope globalScope) {
		if (context instanceof FeatureCall) {
			if (context.arguments.head.value instanceof ElementReferenceExpression) {
				val owner = context.arguments.head.value as ElementReferenceExpression;
				val reference = owner.reference;
				if (reference instanceof SumType) {
					val feature = context.reference;
					if(feature instanceof SumAlternative) {
						return getCandidateParameterScope(globalScope, reference, feature, crossRefString);
					}
					
				}
			}
		}
		// import by name, for named parameters of structs and functions
		val ref = ExpressionsPackage.Literals.ELEMENT_REFERENCE_EXPRESSION__REFERENCE;
		val qualifiedLinkName = fqnConverter.toQualifiedName(crossRefString)
		val scopeDequalified = new ImportScope(
			#[new ImportNormalizer(qualifiedLinkName, true, false)],
			new FilteringScope(globalScope, [it.name.startsWith(qualifiedLinkName)]),
			null,
			ref.EReferenceType,
			false
		);
		return scopeDequalified
	}

	def IScope scope_VariableDeclarationImpl_feature(VariableDeclarationImpl context, EReference reference) {
		val typeSpecifier = context.getTypeSpecifier();
		val type = if(typeSpecifier instanceof PresentTypeSpecifier) {
			typeSpecifier.type;
		}
		if(!(type instanceof ComplexType)) return IScope.NULLSCOPE;

		return Scopes.scopeFor((type as ComplexType).allFeatures)
	}

	def IScope scope_FeatureValue_feature(VariableDeclaration context, EReference reference) {
		val typeSpecifier = context.getTypeSpecifier();
		val type = if(typeSpecifier instanceof PresentTypeSpecifier) {
			typeSpecifier.type;
		}
		if(!(type instanceof ComplexType)) return IScope.NULLSCOPE;

		return Scopes.scopeFor((type as ComplexType).allFeatures)
	}

	protected final OnChangeEvictingCache scope_FeatureCall_feature_cache = new OnChangeEvictingCache();

	def IScope scope_FeatureCall_feature(FeatureCall context, EReference reference) {
		scope_FeatureCall_feature_cache.get(context, context.eResource, [
			val owner = context.arguments.head.value

			var scope = IScope.NULLSCOPE;
			val ownerType = BaseUtils.getType(owner);

			if (owner instanceof ElementReferenceExpression) {
				if (owner.reference instanceof AbstractSystemResource ||
					owner.reference instanceof SystemResourceSetup) {
					/* Special case: the type inferrer delivers a valid type for system resources and their setup.
					 * 				 However, we musn't use that type to provide the scope but rather the direct rules (addFeatureScope).
					 */
					return addFeatureScope(owner.reference, scope);
				}
			}

			if (ownerType !== null) {
				scope = getExtensionMethodScope(context, reference, ownerType);
				return addFeatureScope(ownerType, scope)
			} else if (owner instanceof ElementReferenceExpression) {
				return addFeatureScope(owner.reference, scope)
			} else {
				return getDelegate().getScope(context, reference);
			}
		])
	}

	protected def getExtensionMethodScope(Expression context, EReference reference, AbstractType type) {
		return new FilteringScope(delegate.getScope(context, reference), [ x |
			(x.EClass == ProgramPackage.Literals.FUNCTION_DEFINITION ||
				x.EClass == ProgramPackage.Literals.GENERATED_FUNCTION_DEFINITION) && x.isApplicableOn(type)
		]);
	}

	protected def isApplicableOn(IEObjectDescription operationDesc, AbstractType contextType) {
		var params = operationDesc.getUserData(ProgramDslResourceDescriptionStrategy.OPERATION_PARAM_TYPES);
		val paramArray = if (params === null) {
				if (operationDesc.EObjectOrProxy instanceof Operation) {
					/* Workaround for when we did not get a proper object description, i.e. the object description was not produced
					 * by a ProgramDslResourceDescriptionStrategy. In that case, if the description object is already resolved, we'll
					 * compute the parameter types ourselves.
					 */
					ProgramDslResourceDescriptionStrategy.getOperationParameterTypes(
						operationDesc.EObjectOrProxy as Operation);
				} else {
					#[] as String[]
				}
			} else {
				params.toArray
			}

		if (paramArray.size == 0) {
			return false
		}
		val paramTypeName = paramArray.get(0)
		return contextType.isSubtypeOf(paramTypeName)
	}

	protected def isSubtypeOf(AbstractType subType, String superTypeName) {
		return subType.name == superTypeName;
//		if (subType.name == superTypeName) {
//			return true
//		}
//		return typeSystem.getSuperTypes(subType).exists[name == superTypeName]
	}

	protected def toArray(String paramArrayAsString) {
		paramArrayAsString.replace("[", "").replace("]", "").split(", ")
	}

	dispatch protected def addFeatureScope(SumType owner, IScope scope) {
		Scopes.scopeFor(owner.alternatives, scope);
	}

	dispatch protected def addFeatureScope(StructureType owner, IScope scope) {
		Scopes.scopeFor(owner.parameters, scope);
	}

	dispatch protected def addFeatureScope(ComplexType owner, IScope scope) {
		Scopes.scopeFor(owner.getAllFeatures(), scope);
	}

	dispatch protected def addFeatureScope(EnumerationType owner, IScope scope) {
		Scopes.scopeFor(owner.getEnumerator(), scope);
	}

	dispatch protected def addFeatureScope(SystemResourceSetup owner, IScope scope) {
		Scopes.scopeFor(owner.signalInstances, scope)
	}

	dispatch protected def addFeatureScope(Sensor owner, IScope scope) {
		Scopes.scopeFor(owner.modalities, scope)
	}

	dispatch protected def IScope addFeatureScope(SystemResourceAlias owner, IScope scope) {
		return if(owner.delegate === null) scope else addFeatureScope(owner.delegate, scope)
	}

	dispatch protected def addFeatureScope(Object owner, IScope scope) {
		// fall-back
		scope
	}
	dispatch protected def addFeatureScope(Void owner, IScope scope) {
		// fall-back
		scope
	}

	def IScope scope_ConfigurationItemValue_item(SystemResourceSetup context, EReference reference) {
		val items = context.type.configurationItems
		return Scopes.scopeFor(items);
	}

	def IScope scope_SystemResourceSetup_type(SystemResourceSetup context, EReference reference) {
		val result = getDelegate().getScope(context, reference);

		/*
		 * filter the result scope for system resources which need to be set up (i.e. have configuration items
		 * or variable configuration items).
		 */
		val configurableResourceTypes = #[
			PlatformPackage.Literals.BUS,
			PlatformPackage.Literals.CONNECTIVITY,
			PlatformPackage.Literals.INPUT_OUTPUT,
			PlatformPackage.Literals.SENSOR,
			PlatformPackage.Literals.PLATFORM
		]
		return new FilteringScope(result, [ x |
			val xobj = x.EObjectOrProxy;
			if (xobj instanceof SystemResourceAlias) {
				configurableResourceTypes.contains(xobj.delegate?.eClass)
			} else {
				configurableResourceTypes.contains(x.EClass)
			}
		]);
	}

	val Predicate<IEObjectDescription> globalElementFilter = [ x |
		val inclusion = (ProgramPackage.Literals.SYSTEM_RESOURCE_SETUP.isSuperTypeOf(x.EClass)) ||
			(PlatformPackage.Literals.ABSTRACT_SYSTEM_RESOURCE.isSuperTypeOf(x.EClass)) ||
			(PlatformPackage.Literals.MODALITY.isSuperTypeOf(x.EClass)) ||
			(TypesPackage.Literals.PARAMETER.isSuperTypeOf(x.EClass)) ||
			(TypesPackage.Literals.OPERATION.isSuperTypeOf(x.EClass)) ||
			(TypesPackage.Literals.ENUMERATION_TYPE.isSuperTypeOf(x.EClass)) ||
			(TypesPackage.Literals.STRUCTURE_TYPE.isSuperTypeOf(x.EClass)) ||
			(TypesPackage.Literals.NAMED_PRODUCT_TYPE.isSuperTypeOf(x.EClass))  ||
			(TypesPackage.Literals.ANONYMOUS_PRODUCT_TYPE.isSuperTypeOf(x.EClass)) ||
			(TypesPackage.Literals.SINGLETON.isSuperTypeOf(x.EClass)) ||
			(TypesPackage.Literals.SUM_TYPE.isSuperTypeOf(x.EClass));

		val exclusion = (PlatformPackage.Literals.SIGNAL.isSuperTypeOf(x.EClass)) ||
			(ProgramPackage.Literals.SIGNAL_INSTANCE.isSuperTypeOf(x.EClass)) ||
			(PlatformPackage.Literals.SIGNAL_PARAMETER.isSuperTypeOf(x.EClass))

		inclusion && !exclusion;
	]

	val Predicate<IEObjectDescription> globalTypeFilter = [ x |
		val inclusion = TypesPackage.Literals.TYPE.isSuperTypeOf(x.EClass);

		val exclusion = PlatformPackage.Literals.SENSOR.isSuperTypeOf(x.EClass) ||
			PlatformPackage.Literals.CONNECTIVITY.isSuperTypeOf(x.EClass) ||
			TypesPackage.Literals.EXCEPTION_TYPE_DECLARATION.isSuperTypeOf(x.EClass) ||
			TypesPackage.Literals.TYPE_PARAMETER.isSuperTypeOf(x.EClass); // exclude gloabal type parameters, local ones are added in TypeReferenceScope
		inclusion && !exclusion;
	]

	def scope_TypeSpecifier_type(EObject context, EReference ref) {
		return new TypeReferenceScope(new FilteringScope(delegate.getScope(context, ref), globalTypeFilter), context);
	}

	def scope_ElementReferenceExpression_reference(EObject context, EReference ref) {
		val setup = EcoreUtil2.getContainerOfType(context, SystemResourceSetup)
		return if (setup !== null && BaseUtils.getType(setup) !== null) {
			// we're in a setup block which has different scoping rules. Let's use those
			scopeInSetupBlock(context, ref);
		} else {
			val superScope = new FilteringScope(delegate.getScope(context, ref), globalElementFilter);
			val scope = (if(context instanceof ElementReferenceExpression) {
				if(context.isOperationCall && context.arguments.size > 0) {
					val owner = context.arguments.head.value;
					val ownerType = BaseUtils.getType(owner);

					if (owner instanceof ElementReferenceExpression) {
						if (owner.reference instanceof AbstractSystemResource ||
							owner.reference instanceof SystemResourceSetup) {
							/* Special case: the type inferrer delivers a valid type for system resources and their setup.
							 * 				 However, we musn't use that type to provide the scope but rather the direct rules (addFeatureScope).
							 */
							addFeatureScope(owner.reference, superScope);
						}
					}
		
					if (ownerType !== null) {
						val s2 = getExtensionMethodScope(context, ref, ownerType);
						return addFeatureScope(ownerType, superScope)
					} else if (owner instanceof ElementReferenceExpression) {
						return addFeatureScope(owner.reference, superScope)
					}
				}
			}) ?: superScope;
			new ElementReferenceScope(scope, context);
		}
	}

	dispatch def IScope scopeInSetupBlock(SignalInstance context, EReference reference) {
		if (reference == ExpressionsPackage.Literals.ELEMENT_REFERENCE_EXPRESSION__REFERENCE) {
			val systemResource = (context.eContainer as SystemResourceSetup).type
			val result = Scopes.scopeFor(systemResource.signals)
			return result;
		} else if (reference == ExpressionsPackage.Literals.ARGUMENT__PARAMETER) {
			val globalScope = getDelegate().getScope(context, ExpressionsPackage.Literals.ELEMENT_REFERENCE_EXPRESSION__REFERENCE);
			val enumTypes = context.instanceOf.parameters.parameters.map[BaseUtils.getType(it)?.origin].filter(EnumerationType)
			val enumeratorScope = filteredEnumeratorScope(globalScope, enumTypes)
			val paramScope = Scopes.scopeFor(context.instanceOf.parameters.parameters)
			val scope = new CombiningScope(paramScope, enumeratorScope)
			return scope
		} else {
			return IScope.NULLSCOPE;
		}
	}

	dispatch def IScope scopeInSetupBlock(ConfigurationItemValue context, EReference reference) {
		// configuration item values and unqualified enumerator values
		val originalScope = getDelegate().getScope(context, reference);
		val itemType = BaseUtils.getType(context.item)?.origin;

		if (itemType instanceof EnumerationType) {
			return filteredEnumeratorScope(originalScope, itemType);
		} else if(itemType instanceof SumType) {
			return filteredSumTypeScope(originalScope, itemType);
		} else if(itemType instanceof SumAlternative) {
			return originalScope
		} else {
			return originalScope;
		}
	}
	
	def filteredSumTypeScope(IScope originalScope, SumType itemType) {
		val itemTypeName = qualifiedNameProvider.getFullyQualifiedName(itemType);
		val normalizer = new ImportNormalizer(itemTypeName, true, false);
		val delegate = new ImportScope(Collections.singletonList(normalizer), originalScope, null,
			TypesPackage.Literals.COMPLEX_TYPE, false);
		return new FilteringScope(delegate, [
			(
				   TypesPackage.Literals.ANONYMOUS_PRODUCT_TYPE.isSuperTypeOf(it.EClass) 
				|| TypesPackage.Literals.NAMED_PRODUCT_TYPE.isSuperTypeOf(it.EClass) 
				|| TypesPackage.Literals.SINGLETON.isSuperTypeOf(it.EClass) 
			) && it.name.segmentCount == 1
		])	
	}

	def filteredEnumeratorScope(IScope originalScope, EnumerationType itemType) {
		return filteredEnumeratorScope(originalScope, Collections.singletonList(itemType));
	}
	
	def filteredEnumeratorScope(IScope originalScope, Iterable<EnumerationType> itemTypes) {
		val normalizers = itemTypes.map[new ImportNormalizer(qualifiedNameProvider.getFullyQualifiedName(it), true, false)].toList
		val delegate = new ImportScope(normalizers, originalScope, null, TypesPackage.Literals.ENUMERATOR, false);
		return new FilteringScope(delegate, [
			TypesPackage.Literals.ENUMERATOR.isSuperTypeOf(it.EClass) && it.name.segmentCount == 1
		]);
	}

	dispatch def IScope scopeInSetupBlock(Argument context, EReference reference) {
			val originalScope = getDelegate().getScope(context, reference);

		if (reference == ExpressionsPackage.Literals.ELEMENT_REFERENCE_EXPRESSION__REFERENCE) {
			if (context.parameter !== null) {
				val itemType = BaseUtils.getType(context.parameter)?.origin;
				if (itemType instanceof EnumerationType) {
					// unqualified resolving of enumeration values
					return filteredEnumeratorScope(originalScope, itemType);
				}
			} else {
				val signal = (context.eContainer() as ElementReferenceExpression).reference
				if (signal instanceof Operation) {
					// unqualified resolving of enumeration values
					val enumTypes = signal.parameters.parameters.map[BaseUtils.getType(it)?.origin].filter(EnumerationType)
					return filteredEnumeratorScope(originalScope, enumTypes)
				}
			}
		} else if (reference == ExpressionsPackage.Literals.ARGUMENT__PARAMETER) {
			// unqualified resolving of parameter names
			val container = (context.eContainer as ElementReferenceExpression).reference;
			
			return ModelUtils.getAccessorParameters(container)
				.transform[parameters | Scopes.scopeFor(parameters)]
				.or(originalScope)		
		}
	}

	dispatch def IScope scopeInSetupBlock(ElementReferenceExpression context, EReference reference) {
		
		// Erefs should only be constructors or refs in arguments.
		val ref = context.eGet(ExpressionsPackage.Literals.ELEMENT_REFERENCE_EXPRESSION__REFERENCE, false) as EObject;
		if(ref.eIsProxy){
			val container = context.eContainer;
			if (container !== null && container != context) {
				if(container instanceof ConfigurationItemValue) {
					val confItem = container.item;
					val typ = confItem.type;
					if(typ instanceof SumType) {
						return Scopes.scopeFor(typ.alternatives);
					} else if(typ instanceof StructureType) {
						return Scopes.scopeFor(#[typ]);
					}
				}
				else if(container instanceof Argument) {
					// context is a named parameter
					val constr = EcoreUtil2.getContainerOfType(container, ElementReferenceExpression);
					val typ = constr.reference;
					val parms = ModelUtils.getAccessorParameters(typ);
					if(parms.present) {
						// you can reference both argument parameters and things you can otherwise reference here
						return new CombiningScope(Scopes.scopeFor(parms.get), scopeInSetupBlock(container, reference));
					}
				}
				return scopeInSetupBlock(container, reference);
			} else {
				return IScope.NULLSCOPE;
			}
		}
		else {
			if(ref instanceof SumAlternative) {
				if(reference == ExpressionsPackage.Literals.ARGUMENT__PARAMETER) {
					return doGetCandidateParameterScope(ref, IScope.NULLSCOPE);
				}
				return Scopes.scopeFor(#[ref]);
			}
			val container = context.eContainer;
			if (container !== null && container != context) {
				return scopeInSetupBlock(container, reference);
			} else {
				return IScope.NULLSCOPE;
			}
		}
	}

	dispatch def IScope scopeInSetupBlock(EObject context, EReference reference) {
		// we don't have a special in-setup block rule for this case. Let's see if we can get a scope for the container.
		val container = context.eContainer;
		if (container !== null && container != context) {
			return scopeInSetupBlock(container, reference);
		} else {
			return IScope.NULLSCOPE;
		}
	}

	def IScope scope_SystemEventSource_origin(Program context, EReference reference) {
		val originalScope = getDelegate().getScope(context, reference);

		return new FilteringScope(originalScope, [ x |
			val obj = x.EObjectOrProxy;

			val result = if (obj instanceof AbstractSystemResource) {
					!obj.events.empty
				} else {
					false;
				}
			return result;
		])
	}

	def IScope scope_SystemEventSource_source(SystemEventSource context, EReference reference) {
		return if (context === null || context.origin === null) {
			IScope.NULLSCOPE;
		} else {
			Scopes.scopeFor(context.origin.events);
		}
	}

	def IScope scope_IsDeconstructor_productMember(IsDeconstructor context, EReference reference) {
		val originalScope = getDelegate().getScope(context, reference);
		val deconstructorCase = context.eContainer as IsDeconstructionCase;
		val productType = deconstructorCase.productType;
		// structs can be here, they are anonymous (vec2d: v2d), and singular
		return ModelUtils.getAccessorParameters(productType)
			.transform[parameters | Scopes.scopeFor(parameters, [x|QualifiedName.create(productType.name, x.name)], originalScope)]
			.or(originalScope)
	}

	override IScope getScope(EObject context, EReference reference) {
		// Performance improvement: hard-code well traveled routes
		val scope = if (reference == TypesPackage.Literals.PRESENT_TYPE_SPECIFIER__TYPE) {
				scope_TypeSpecifier_type(context, reference);
			} else if (reference == ExpressionsPackage.Literals.ELEMENT_REFERENCE_EXPRESSION__REFERENCE &&
				context instanceof FeatureCall) {
				//scope_FeatureCall_feature(context as FeatureCall, reference);
				scope_ElementReferenceExpression_reference(context, reference);
			} else if (reference == ExpressionsPackage.Literals.ELEMENT_REFERENCE_EXPRESSION__REFERENCE) {
				scope_ElementReferenceExpression_reference(context, reference);
			} else if (reference == ProgramPackage.Literals.CONFIGURATION_ITEM_VALUE__ITEM &&
				context instanceof SystemResourceSetup) {
				scope_ConfigurationItemValue_item(context as SystemResourceSetup, reference);
			} else {
//				val methodName = "scope_" + reference.getEContainingClass().getName() + "_" + reference.getName();
//				println(methodName + ' -> ' + context.eClass.name);
				super.getScope(context, reference);
			}

		return TypesGlobalScopeProvider.filterExportable(context.eResource, reference, scope);
	}

}
