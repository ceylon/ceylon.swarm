import com.redhat.ceylon.common.tool { option, description }

import com.redhat.ceylon.tools.war { CeylonWarTool }
import org.wildfly.swarm.swarmtool { Main { main }}
import java.lang { ObjectArray, JString = String }

description("Generates a `.war` file and an executable WildFly Swarm `.jar` file
             which executes this jar in a minimal embedded WildFly runtime.

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

  // different default
  super.setStaticMetamodel(true);

  option{ longName="static-metamodel"; }
  description("Generate a static metamodel, skip the WarInitializer (default: true).")
  shared actual void setStaticMetamodel(Boolean staticMetamodel) {
      super.setStaticMetamodel(staticMetamodel);
  }

  shared actual void run(){
    super.run();
    main(ObjectArray<JString>(1, JString(jarFile.absolutePath)));
  }
}
