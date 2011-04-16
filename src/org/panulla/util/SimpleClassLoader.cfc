<cfcomponent output="false" hint="A simple Java class loader. Wraps native ColdFusion class loading functionality">
	
	<cffunction name="create" access="public" output="false" returntype="any">
		<cfargument name="classname" type="string" required="true" />
		
		<cfreturn createObject("java", arguments.classname) />
	</cffunction>

</cfcomponent>