Download Pellet from http://clarkparsia.com/pellet/. Version as of this writing is 2.2.2.

Unpack the Pellet distribution (which includes Jena) somewhere your ColdFusion
server can see it. This directory will be PELLET_HOME.

In your ColdFusion Administrator, under Server Settings > Java and JVM: Add these directories to the ColdFusion class path:

PELLET_HOME/lib
PELLET_HOME/lib/jena
PELLET_HOME/lib/jgrapht