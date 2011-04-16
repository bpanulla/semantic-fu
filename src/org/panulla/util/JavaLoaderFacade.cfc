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