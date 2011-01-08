<cfcomponent output="false" hint="Encapsulates an instance of JavaLoader, providing a constructor to populate the classpath from a list.">

	<cfscript>
		variables.classloader = "";
	</cfscript>


	<cffunction name="init" output="false" access="public" returntype="JavaLoaderFacade"
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
		</cfscript>
	
		<cfreturn this />
	</cffunction>
	

	<cffunction name="create" output="false" access="public" returntype="any"
							hint="Creates and returns an instance of the requested class.">
		<cfargument name="classname" required="true" type="string" hint="Fully-qualified name of class to instantiate." />
	
		<cfreturn variables.classloader.create(arguments.classname) />
	</cffunction>


</cfcomponent>