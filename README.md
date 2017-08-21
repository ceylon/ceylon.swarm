Ceylon Swarm CLI plugin
=======================

Let's you write [WildFly Swarm][] applications in [Ceylon][].

This plugin for the Ceylon command line toolset adds the command 
`ceylon swarm` which repackages a Ceylon module as a Wildfly Swarm
"fat" `.jar` containing all needed dependencies, and allowing you
to execute the Swarm service using `java -jar`.

[WildFly Swarm]: http://wildfly-swarm.io/
[Ceylon]: https://ceylon-lang.org/

Installation
------------

To install the latest production release of the plugin on a machine
which already has Ceylon 1.3.0 or above installed, just type:

```bash
ceylon plugin install ceylon.swarm/1.3.4-SNAPSHOT
```

If you need to install Ceylon, you can get it here:

<https://ceylon-lang.org/download/>

Alternatively, you can build and install the plugin from source.

Building from source
--------------------

### With `ant`

```bash
git clone https://github.com/ceylon/ceylon.swarm
cd ceylon.swarm
ant install
```

The buildfile assumes that `ceylon-dist` (including the Ceylon ant 
files) is a sibling folder; otherwise, you might have to adjust the 
paths in `build.properties`.

Then, inside this folder, install the plugin using:

```bash
ceylon plugin install
```

Usage
-----

Create a WildFly Swarm module by importing the needed Java EE API 
modules in `module.ceylon`:

```ceylon
native("jvm")
module my.module "1.0" {
  import maven:"javax:javaee-api" "7.0";
}
```

Then write your application, and run the `swarm` plugin from the command 
line:

```bash
ceylon swarm --provided-module javax:javaee-api my.module/1.0
```

This creates a fat `.jar` named `my.module-1.0-swarm.jar`.

Finally, run the service using `java -jar`:

```bash
java -jar my.module-1.0-swarm.jar
```

You'll find a _much_ more complete example here:

<https://github.com/DiegoCoronel/ceylon-jboss-swarm/>

Contact
-------

If you've found a bug or want to suggest a feature, 
[report an issue](https://github.com/ceylon/ceylon.swarm/issues/new).

License
-------

The content of this repository is released under the ASL v2.0
as provided in the LICENSE file that accompanied this code.

By submitting a "pull request" or otherwise contributing to 
this repository, you agree to license your contribution under 
the license mentioned above.
