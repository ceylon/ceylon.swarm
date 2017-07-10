import ceylon.interop.java {
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
    optionArgument__SETTER,
    description__SETTER
}
import com.redhat.ceylon.tools.war {
    CeylonWarTool
}

import java.lang {
    JString=String,
    Process,
    ProcessBuilder {
        Redirect
    }
}
import java.util {
    ArrayList
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

  // Default is not 2016.11.0 since it's not yet on Maven Central (only JBoss repo)
  optionArgument__SETTER{ longName="swarm-version";  }
  description__SETTER("Specifies the version of org.wildfly.swarm:swarmtool (default: 2016.11.0).")
  shared variable String swarmVersion = "2016.11.0";

  shared actual default void run(){
    super.run();

    // OK this is super lame, but is the only way to not depend on 1.3.1 since 1.3.0
    // does not support setting Overrides once the repo is created and we don't want
    // to hijack the user overrides flag for that. I guess we could create another
    // RepositoryManager with our custom Overrides file, but this works:
    value swarmContext = ArtifactContext("maven", "org.wildfly.swarm:swarmtool", null);
    value ao = ArtifactOverrides(swarmContext);
    value klass = javaClass<ArtifactOverrides>();
    // This is definitly fixed in 1.3.1
    value field = klass.getDeclaredField("classifier");
    field.accessible = true;
    field.set(ao, JString("standalone"));

    // Stupid Maven doesn't know that standalone jars don't need their source project deps
    ao.addOverride(DependencyOverride(ArtifactContext("maven", "org.wildfly.swarm:fraction-list", null), 
        Type.remove, false, false));
    ao.addOverride(DependencyOverride(ArtifactContext("maven", "org.wildfly.swarm:tools", null), 
        Type.remove, false, false));
    ao.addOverride(DependencyOverride(ArtifactContext("maven", "org.wildfly.swarm:arquillian-resolver", null), 
        Type.remove, false, false));
    ao.addOverride(DependencyOverride(ArtifactContext("maven", "net.sf.jopt-simple:jopt-simple", null), 
        Type.remove, false, false));
    // This should modify either the user overrides or the dist overrides
    repositoryManager.overrides.addArtifactOverride(ao);

    // Now get the swarmtool standalone
    value artifactContext = ArtifactContext("maven", "org.wildfly.swarm:swarmtool", swarmVersion);
    "Failed to download swarmtool"
    assert(exists artifact = repositoryManager.getArtifact(artifactContext));
    // And just run it
    executeJar(artifact.absolutePath, jarFile.absolutePath);
  }
  
  suppressWarnings("expressionTypeNothing")
  shared void executeJar(String jar, String* args){
      assert(exists javaHome = process.propertyValue("java.home"));
      value javaExec = javaHome+"/bin/java";
      value a = ArrayList<JString>();
      a.add(JString(javaExec));
      a.add(JString("-jar"));
      a.add(JString(jar));
      for(arg in args){
          a.add(JString(arg));
      }
      print(a);
      ProcessBuilder pb = ProcessBuilder(a);
      pb.redirectError(Redirect.inherit);
      pb.redirectOutput(Redirect.inherit);
      Process p = pb.start();
      value exit = p.waitFor();
      if(exit != 0){
          process.exit(exit);
      }
  }
}
