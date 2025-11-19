#!/usr/bin/env nextflow

/*
 * Test script to explore WorkflowMetadata, Session, and related objects
 * to understand what revision/git information is available
 */

nextflow.enable.dsl = 2

workflow {
    println "\n" + "="*80
    println "WORKFLOW METADATA"
    println "="*80
    
    // Manually print specific properties to avoid circular references
    def safeProps = [
        'runName', 'scriptId', 'scriptFile', 'scriptName',
        'repository', 'commitId', 'revision',
        'start', 'projectDir', 'projectName', 'launchDir',
        'workDir', 'commandLine', 'profile', 'sessionId'
    ]
    
    safeProps.each { propName ->
        try {
            println "${propName}: ${workflow[propName]}"
        } catch (Exception e) {
            println "${propName}: <error: ${e.message}>"
        }
    }
    
    println "\n" + "="*80
    println "SESSION INFO"
    println "="*80
    
    // Access session through workflow
    def session = workflow.session
    if (session) {
        // Manually check specific properties to avoid circular references
        def sessionProps = [
            'uniqueId', 'runName', 'configFiles', 'profile', 
            'commandLine', 'workDir', 'projectDir', 'script'
        ]
        
        sessionProps.each { propName ->
            try {
                def value = session[propName]
                println "${propName}: ${value}"
            } catch (Exception e) {
                println "${propName}: <error: ${e.message}>"
            }
        }
        
        // Try to access binding
        println "\n--- Session Binding ---"
        try {
            def binding = session.binding
            if (binding) {
                println "binding exists: true"
                println "binding class: ${binding.class.name}"
                println "binding.entryName: ${binding.getEntryName()}"
                
                // Check if binding has any other useful methods
                println "\n--- Binding methods containing 'entry', 'script', or 'revision' ---"
                binding.metaClass.methods.each { method ->
                    def name = method.name.toLowerCase()
                    if (name.contains('entry') || name.contains('script') || name.contains('revision')) {
                        println "  ${method.name}()"
                    }
                }
            }
        } catch (Exception e) {
            println "Could not access binding: ${e.message}"
        }
    }
    
    println "\n" + "="*80
    println "GIT/REVISION SPECIFIC INFO"
    println "="*80
    
    println "repository: ${workflow.repository}"
    println "commitId: ${workflow.commitId}"
    println "revision: ${workflow.revision}"
    println "projectDir: ${workflow.projectDir}"
    println "projectName: ${workflow.projectName}"
    println "scriptFile: ${workflow.scriptFile}"
    println "scriptId: ${workflow.scriptId}"
    println "scriptName: ${workflow.scriptName}"
    
    println "\n" + "="*80
    println "COMMAND LINE INFO"
    println "="*80
    
    println "commandLine: ${workflow.commandLine}"
    
    println "\n" + "="*80
    println "CONFIG INFO"
    println "="*80
    
    println "profile: ${workflow.profile}"
    println "configFiles: ${workflow.configFiles}"
    
    println "\n" + "="*80
    println "CHECKING FOR SCRIPTFILE OBJECT"
    println "="*80
    
    // Try to see if we can access ScriptFile somehow
    try {
        if (session) {
            // Check if there's a script property
            def script = session.script
            if (script) {
                println "session.script exists: true"
                println "session.script class: ${script.class.name}"
                
                // Try to access scriptFile from the script
                try {
                    println "script.scriptFile: ${script.scriptFile}"
                } catch (Exception e) {
                    println "Could not access script.scriptFile: ${e.message}"
                }
                
                // Check for revision-related methods
                println "\n--- Script object methods ---"
                script.metaClass.methods.findAll { method ->
                    def name = method.name.toLowerCase()
                    name.contains('revision') || name.contains('git') || name.contains('repo')
                }.each { method ->
                    println "  ${method.name}()"
                }
            } else {
                println "session.script: null"
            }
        }
    } catch (Exception e) {
        println "Could not access script objects: ${e.message}"
        e.printStackTrace()
    }
    
    println "\n" + "="*80
    println "PARAMS"
    println "="*80
    
    params.each { key, value ->
        println "${key}: ${value}"
    }
    
    println "\n" + "="*80
    println "END OF METADATA DUMP"
    println "="*80 + "\n"
}
