<!---
Copyright 2010 Brainpan Labs
http://BrainpanLabs.com

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
--->

<cfcomponent output="false" hint="Encapsulates an instance of JavaLoader, providing a constructor to populate the classpath from a list.">

	<cfscript>
		variables.classloader = "";
	</cfscript>


	<cffunction name="init" output="false" access="public" returntype="org.panulla.util.DynamicClassLoader"
							hint="Instantiates and configures the Java Class Loader">
		<cfargument name="classpath" required="true" type="string" hint="Semicolon-delimited list of folders/jars to use for class lookups." />
		<cfargument name="libraryRoot" required="false" default="" hint="Base path for relative classpath entries." />
		<cfargument name="delimiter" required="false" default=";" hint="Delimiter used in classpath. Default is semicolon (;)." />
		<cfargument name="loadServerClasspath" required="false" default="true" hint="Include ColdFusion classpath in loader's classpath" />
	
		<cfscript>
			var local = structNew();
			
			local.classpath = arrayNew(1);
			
			// Loop over classpath list, checking for relative path names
			for ( local.i = 1; local.i LTE listLen(arguments.classpath, arguments.delimiter); local.i = local.i + 1 )
			{
				local.entry = listGetAt(arguments.classpath, local.i, arguments.delimiter);
				
				// If the file specified by the path doesn't exist, try prepending the library root
				if (NOT fileExists(local.entry))
				{
					local.entry = arguments.libraryRoot & "/" & local.entry; 
				}
				
				arrayAppend(local.classpath,  local.entry);
			}
			
			variables.classloader = createObject("component", "javaloader.JavaLoader")
										.init(local.classpath, arguments.loadServerClasspath);
			
			return this;
		</cfscript>
	</cffunction>
	

	<cffunction name="create" output="false" access="public" returntype="any"
							hint="Creates and returns an instance of the requested class.">
		<cfargument name="classname" required="true" type="string" hint="Fully-qualified name of class to instantiate." />
	
		<cfreturn variables.classloader.create(arguments.classname) />
	</cffunction>


</cfcomponent>