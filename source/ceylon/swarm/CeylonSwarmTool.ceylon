import ceylon.interop.java {
    javaString,
    javaClass
}

import com.redhat.ceylon.cmr.api {
    ArtifactContext,
    ArtifactOverrides,
    DependencyOverride {
        Type
    }
}
import com.redhat.ceylon.common.tool {
    description,
    optionArgument
}
import com.redhat.ceylon.tools.war {
    CeylonWarTool
}

import java.lang {
    ProcessBuilder {
        Redirect
    }
}
import java.util {
    Arrays {
        asList
    }
}

"The Ceylon Swarm tool"
description("Generates a `.war` file and an executable WildFly Swarm `.jar` file
             which embeds a minimal embedded WildFly runtime.

             ## Java EE modules

             You can use any Java EE API module, or the `javax:javaee-api/7.0`
             module from Maven which has every Java EE API.

             ## Provided modules

             Make sure you use the `--provided-module` argument to mark every
             imported module which is provided by WildFly Swarm, such as any
             Java EE module. For example, if you imported the `javax:javaee-api/7.0
             module described above, you should use `--provided-module javax:javaee-api`
             to generate the WildFly Swarm jar for you application.")
shared class CeylonSwarmTool() extends CeylonWarTool() {
    
    value swarmTool = "org.wildfly.swarm:swarmtool";
    variable value swarmToolVersion = "2016.11.0";
    
    shared String swarmVersion => swarmToolVersion;
    
    optionArgument { longName="swarm-version"; }
    description("Specifies the version of org.wildfly.swarm:swarmtool (default: 2016.11.0).")
    assign swarmVersion => swarmToolVersion = swarmVersion;
    
    shared actual default void run() {
        super.run();
        
        // OK this is super lame, but is the only way to not 
        // depend on 1.3.1 since 1.3.0 does not support setting 
        // Overrides once the repo is created and we don't want
        // to hijack the user overrides flag for that. I guess 
        // we could create another RepositoryManager with our 
        // custom Overrides file, but this works:
        value swarmContext 
            = ArtifactContext("maven", swarmTool, null);
        value overrides = ArtifactOverrides(swarmContext);
        // This is definitely fixed in 1.3.1
        //ao.classifier = "standalone";
        value field 
            = javaClass<ArtifactOverrides>()
                .getDeclaredField("classifier");
        field.accessible = true;
        field.set(overrides, javaString("standalone"));
        
        // Stupid Maven doesn't know that standalone jars 
        // don't need their source project deps
        ["org.wildfly.swarm:fraction-list",
         "org.wildfly.swarm:tools",
         "org.wildfly.swarm:arquillian-resolver",
         "net.sf.jopt-simple:jopt-simple"]
            .map((dep) 
                => DependencyOverride(
                    ArtifactContext("maven", dep, null), 
                    Type.remove, false, false))
            .each(overrides.addOverride);
        
        // This should modify either the user overrides or 
        // the dist overrides
        repositoryManager.overrides
            .addArtifactOverride(overrides);
        
        // Now get the swarmtool standalone
        value artifactContext 
            = ArtifactContext("maven", swarmTool, swarmVersion);
        "Failed to download ``swarmTool``:``swarmVersion``"
        assert (exists artifact 
            = repositoryManager.getArtifact(artifactContext));
        // And just run it
        executeJar(artifact.absolutePath, jarFile.absolutePath);
    }
    
    suppressWarnings("expressionTypeNothing")
    shared void executeJar(String jar, String* args) {
        "System property java.home is missing"
        assert (exists javaHome 
            = process.propertyValue("java.home"));
        value command 
            = [javaHome + "/bin/java", "-jar", jar, *args];
        print(" ".join(command));
        value exit 
            = ProcessBuilder(asList(*command.map(javaString)))
                .redirectError(Redirect.inherit)
                .redirectOutput(Redirect.inherit)
                .start()
                .waitFor();
        if (exit != 0) {
            process.exit(exit);
        }
    }
    
}
