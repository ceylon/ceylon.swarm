"""Ceylon CLI plugin for WildFly Swarm.

   # Usage

   Install the plugin from the command-line:

   ~~~sh
   $ ceylon plugin install ceylon.swarm/1.3.4-SNAPSHOT
   ~~~

   Write your application for WildFly Swarm by importing the Java EE API module in your Ceylon module.ceylon:

       native("jvm")
       module my.module "1" {
         import maven:"javax:javaee-api" "7.0";
       }

   Then write your application, and run the swarm plugin from the command line:

   ~~~sh
   ceylon swarm --provided-module javax:javaee-api my.module/1
   ~~~
"""
suppressWarnings("ceylonNamespace")
native("jvm")
module ceylon.swarm "1.3.4-SNAPSHOT" {
    import java.base "8";
    shared import com.redhat.ceylon.compiler.java "1.3.4-SNAPSHOT";
    shared import com.redhat.ceylon.tools "1.3.4-SNAPSHOT";
}
