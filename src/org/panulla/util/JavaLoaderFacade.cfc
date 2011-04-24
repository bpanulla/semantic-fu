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

<cfcomponent output="false" hint="Encapsulates an instance of a Java class loader.">

	<cfscript>
		variables.classloader = createObject("component", "org.panulla.util.SimpleClassLoader");
	</cfscript>


	<cffunction name="init" output="false" access="public" returntype="org.panulla.util.JavaLoaderFacade" hint="Instantiates and configures the Java class loader">
		<cfargument name="dynamicLoader" type="org.panulla.util.DynamicClassLoader" required="false" hint="Use dynamic loader in place of standard loader" />
	
		<cfscript>
			if (isDefined("arguments.dynamicLoader"))
			{
				variables.classloader = arguments.dynamicLoader;
			}
			
			return this;
		</cfscript>
	</cffunction>
	

	<cffunction name="create" output="false" access="public" returntype="any"
							hint="Creates and returns an instance of the requested class.">
		<cfargument name="classname" required="true" type="string" hint="Fully-qualified name of class to instantiate." />
	
		<cfreturn variables.classloader.create(arguments.classname) />
	</cffunction>

</cfcomponent>