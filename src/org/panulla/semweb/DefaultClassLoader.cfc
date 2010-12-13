<cfcomponent>

	<cffunction name="create" access="public" output="false" returntype="Any">
		<cfargument name="classname" type="string" required="true">
		<cfreturn CreateObject("java", arguments.classname)>
	</cffunction>


</cfcomponent>