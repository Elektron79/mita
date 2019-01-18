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
package org.eclipse.mita.program.generator

import com.google.inject.Guice
import com.google.inject.Inject
import com.google.inject.Injector
import com.google.inject.Module
import com.google.inject.Provider
import com.google.inject.name.Named
import java.util.LinkedList
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.IWorkspaceRoot
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.mita.base.scoping.ILibraryProvider
import org.eclipse.mita.platform.AbstractSystemResource
import org.eclipse.mita.platform.Platform
import org.eclipse.mita.platform.PlatformPackage
import org.eclipse.mita.program.Program
import org.eclipse.mita.program.SystemResourceSetup
import org.eclipse.mita.program.generator.internal.EntryPointGenerator
import org.eclipse.mita.program.generator.internal.ExceptionGenerator
import org.eclipse.mita.program.generator.internal.GeneratedTypeGenerator
import org.eclipse.mita.program.generator.internal.IGeneratorOnResourceSet
import org.eclipse.mita.program.generator.internal.ProgramCopier
import org.eclipse.mita.program.generator.internal.SystemResourceHandlingGenerator
import org.eclipse.mita.program.generator.internal.TimeEventGenerator
import org.eclipse.mita.program.generator.internal.UserCodeFileGenerator
import org.eclipse.mita.program.generator.transformation.ProgramGenerationTransformationPipeline
import org.eclipse.mita.program.model.ModelUtils
import org.eclipse.mita.program.resource.PluginResourceLoader
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import org.eclipse.xtext.generator.trace.node.CompositeGeneratorNode
import org.eclipse.xtext.mwe.ResourceDescriptionsProvider
import org.eclipse.xtext.resource.IContainer.Manager
import org.eclipse.xtext.service.DefaultRuntimeModule
import org.eclipse.xtext.xbase.lib.Functions.Function1

import static extension org.eclipse.mita.base.util.BaseUtils.force
import org.eclipse.mita.base.util.BaseUtils
import org.eclipse.mita.base.typesystem.infra.MitaBaseResource

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class ProgramDslGenerator extends AbstractGenerator implements IGeneratorOnResourceSet {

	@Inject 
	protected extension ProgramDslTraceExtensions
	
	@Inject
	protected extension ProgramCopier
	
	@Inject
	protected Provider<ProgramGenerationTransformationPipeline> transformer
	
	@Inject
	protected extension GeneratorUtils
	
	@Inject(optional=true)
	protected IPlatformMakefileGenerator makefileGenerator

	@Inject
	protected EntryPointGenerator entryPointGenerator
	
	@Inject
	protected ExceptionGenerator exceptionGenerator
	
	@Inject
	protected GeneratedTypeGenerator generatedTypeGenerator
	
	@Inject
	protected TimeEventGenerator timeEventGenerator
	
	@Inject
	protected SystemResourceHandlingGenerator systemResourceGenerator
	
	@Inject
	protected UserCodeFileGenerator userCodeGenerator
	
	@Inject 
	protected Injector injector
	
	@Inject 
	protected ILibraryProvider libraryProvider
	
	@Inject @Named("injectingModule")
	protected DefaultRuntimeModule injectingModule
	
	@Inject
	protected CompilationContextProvider compilationContextProvider;
	
	@Inject
	protected ModelUtils modelUtils
	
	@Inject
	protected PluginResourceLoader resourceLoader
	

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		resource.resourceSet.doGenerate(fsa);
	}
	
	protected def isMainApplicationFile(Resource resource) {
		return resource.URI.segments.last.startsWith('application.')
	}
	
	protected def injectPlatformDependencies(Module libraryModule) {
		injector = Guice.createInjector(injectingModule, libraryModule);
		injector.injectMembers(this)
	}

	private def produceFile(IFileSystemAccess2 fsa, String path, EObject ctx, CompositeGeneratorNode content) {
		var root = CodeFragment.cleanNullChildren(content);
		fsa.generateTracedFile(path, root);
		return path
	}
	
	override doGenerate(ResourceSet input, IFileSystemAccess2 fsa) {
		doGenerate(input, fsa, [ it.URI?.segment(0) == 'resource' ]);
	}
	
	override doGenerate(ResourceSet input, IFileSystemAccess2 fsa, Function1<Resource, Boolean> includeInBuildPredicate) {
		if(false) {
			return;
		}
		val resourcesToCompile = input
			.resources
			.filter(includeInBuildPredicate)
			.toList();
		
		if(resourcesToCompile.empty) {
			return;
		}
		
		// Include libraries such as the stdlib in the compilation context
		val libs = libraryProvider.standardLibraries;
		val stdlibUri = libs.filter[it.toString.endsWith(".mita")]
		val stdlib = stdlibUri.map[input.getResource(it, false)].filterNull.map[it.contents.filter(Program).head].force;
	
		/*
		 * Steps:
		 *  1. Copy all programs
		 *  2. Run all programs through pipeline
		 *  3. Collect all sensors, connectivity, exceptions, types
		 *  4. Generate shared files
		 *  5. Generate user code per input model file
		 */
		val compilationUnits = (resourcesToCompile)
			.map[x | x.contents.filter(Program).head ]
			.filterNull
			.map[x | 
				val copy = x.copy;
				BaseUtils.ignoreChange(copy, [transformer.get.transform(copy)]);
				return copy;
			]
			.toList();
		
		val someProgram = compilationUnits.head;
		
		doType(someProgram);
		
		val platform = modelUtils.getPlatform(input, someProgram);
		injectPlatformDependencies(resourceLoader.loadFromPlugin(platform.eResource, platform.module) as Module);
		
		val context = compilationContextProvider.get(compilationUnits, stdlib);
		
		val files = new LinkedList<String>();
		val userTypeFiles = new LinkedList<String>();
		
		
		// generate all the infrastructure bits
		files += fsa.produceFile('main.c', someProgram, entryPointGenerator.generateMain(context));
		files += fsa.produceFile('base/MitaEvents.h', someProgram, entryPointGenerator.generateEventHeader(context));
		files += fsa.produceFile('base/MitaExceptions.h', someProgram, exceptionGenerator.generateHeader(context));
		
		if (context.hasTimeEvents) {
			files += fsa.produceFile('base/MitaTime.h', someProgram, timeEventGenerator.generateHeader(context));
			files += fsa.produceFile('base/MitaTime.c', someProgram, timeEventGenerator.generateImplementation(context));
		}
		
		for (resourceOrSetup : context.getResourceGraph().nodes.filter(EObject)) {
			if(resourceOrSetup instanceof AbstractSystemResource
			|| resourceOrSetup instanceof SystemResourceSetup) { 
				files += fsa.produceFile('''base/«resourceOrSetup.fileBasename».h''', resourceOrSetup as EObject, systemResourceGenerator.generateHeader(context, resourceOrSetup));
				files += fsa.produceFile('''base/«resourceOrSetup.fileBasename».c''', resourceOrSetup as EObject, systemResourceGenerator.generateImplementation(context, resourceOrSetup));
			}
		}
	
		for (program : compilationUnits.filter[containsCodeRelevantContent]) {
			// generate the actual content for this resource
			files += fsa.produceFile(userCodeGenerator.getResourceBaseName(program) + '.c', program, stdlib.head.trace.append(userCodeGenerator.generateImplementation(context, program)));
			files += fsa.produceFile(userCodeGenerator.getResourceBaseName(program) + '.h', program, stdlib.head.trace.append(userCodeGenerator.generateHeader(context, program)));
			val compilationUnitTypesFilename = userCodeGenerator.getResourceTypesName(program) + '.h';
			files += fsa.produceFile(compilationUnitTypesFilename, program, stdlib.head.trace.append(userCodeGenerator.generateTypes(context, program)));
			userTypeFiles += compilationUnitTypesFilename;
		}
		
		files += fsa.produceFile('base/MitaGeneratedTypes.h', someProgram, generatedTypeGenerator.generateHeader(context, userTypeFiles));
		
		files += getUserFiles(input);
		
		val codefragment = makefileGenerator?.generateMakefile(compilationUnits, files)
		if(codefragment !== null && codefragment != CodeFragment.EMPTY)
			fsa.produceFile('Makefile', someProgram, codefragment);
	}
		
	def doType(Program program) {
		val resource = program.eResource;
		if(resource instanceof MitaBaseResource) {
			resource.collectAndSolveTypes(program);
		}
	}
		
	def Iterable<String> getUserFiles(ResourceSet set) {
        val resource = set.resources.head;   
        val URI uri = resource.URI;
        val projectName = new Path(uri.toPlatformString(true)).segment(0);
        
        val IWorkspaceRoot workspaceRoot = ResourcesPlugin.getWorkspace().getRoot();
        val IProject project = workspaceRoot.getProject(projectName);
        return project
            .members()
            .filter(IFile)
            .map[ it.fullPath.lastSegment ]
            .filter[ it.endsWith(".c") ]
            .map[ "../" + it ];
    }
	
}
