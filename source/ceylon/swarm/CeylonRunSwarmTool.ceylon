import com.redhat.ceylon.common.tool { option, description }

import com.redhat.ceylon.tools.war { CeylonWarTool }
import org.wildfly.swarm.swarmtool { Main { main }}
import java.lang { 
    ObjectArray, 
    JString = String,
    ProcessBuilder { Redirect },
    Process 
}
import java.util {
    ArrayList
}

"The Ceylon Swarm runner tool"
description("Generates a `.war` file and an executable WildFly Swarm `.jar` file
             which executes this jar in a minimal embedded WildFly runtime, and then
             executes this `.jar` file.

             ## Java EE modules

             You can use any Java EE API module, or the `javax:javaee-api/7.0`
             module from Maven which has every Java EE API.

             ## Provided modules

             Make sure you use the `--provided-module` argument to mark every
             imported module which is provided by WildFly Swarm, such as any
             Java EE module. For example, if you imported the `javax:javaee-api/7.0
             module described above, you should use `--provided-module javax:javaee-api`
             to generate the WildFly Swarm jar for you application.")
shared class CeylonRunSwarmTool() extends CeylonWarTool() {

  // different default
  super.setStaticMetamodel(true);

  option{ longName="static-metamodel"; }
  description("Generate a static metamodel, skip the WarInitializer (default: true).")
  shared actual void setStaticMetamodel(Boolean staticMetamodel) {
      super.setStaticMetamodel(staticMetamodel);
  }

  suppressWarnings("expressionTypeNothing")
  shared actual void run(){
    super.run();
    main(ObjectArray<JString>(1, JString(jarFile.absolutePath)));

    value generatedJarFile = jarFile.absolutePath.substring(0, jarFile.absolutePath.size - 4) + "-swarm.jar";
    assert(exists javaHome = process.propertyValue("java.home"));
    value javaExec = javaHome+"/bin/java";
    value a = ArrayList<JString>();
    a.add(JString(javaExec));
    a.add(JString("-jar"));
    a.add(JString(generatedJarFile));
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
