import com.redhat.ceylon.common.tool {
    description
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
shared class CeylonRunSwarmTool() extends CeylonSwarmTool() {

  shared actual void run(){
    super.run();
    value generatedJarFile = jarFile.absolutePath.substring(0, jarFile.absolutePath.size - 4) + "-swarm.jar";
    executeJar(generatedJarFile);
  }
}
