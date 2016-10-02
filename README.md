Ceylon Swarm CLI plugin
=======================

Build WildFly Swarm applications written in Ceylon.

Building
--------

### With `ant`

```bash
git clone https://github.com/ceylon/ceylon.swarm
cd ceylon.swarm
ant install
```

The buildfile assumes that `ceylon-dist` (including the Ceylon ant files) is a sibling folder; otherwise, you might have to adjust the paths in `build.properties`.

Usage
-----

Inside this folder to install the plugin:

```bash
ceylon plugin install
```

Write your application for WildFly Swarm by importing the Java EE API module in your Ceylon `module.ceylon`:

```ceylon
native("jvm")
module my.module "1" {
  import maven:"javax:javaee-api" "7.0";
}
```

Then write your application, and run the swarm plugin from the command line:

```bash
ceylon swarm --provided-module javax:javaee-api my.module/1
```

Contact
-------

If you have found a bug or want to suggest a feature, [create an issue](https://github.com/ceylon/ceylon.swarm/issues/new).

License
-------

The content of this repository is released under the ASL v2.0
as provided in the LICENSE file that accompanied this code.

By submitting a "pull request" or otherwise contributing to 
this repository, you agree to license your contribution under 
the license mentioned above.
