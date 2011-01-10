<cfcomponent name="Application" output="false">

	<!--- ========================================================================================================== \
	|	Constructor
	\ =========================================================================================================== --->

	<!--- Application settings --->
	<cfset this.name = "WineBrowser" />
	<cfset this.applicationTimeout = createTimespan(5,0,0,0) />
	<cfset this.loginStorage = "session" />

	<cfset this.sessionManagement = true />
	<cfset this.sessionTimeout = createTimespan(0,1,0,0) />
	
	<cfset this.rootFolder = GetDirectoryFromPath(GetCurrentTemplatePath()) />
	
	<cfset this.mappings = structNew() />
	<cfset this.mappings["/"] = this.rootFolder />
	
	<!--- ========================================================================================================== \
	|	Application
	\ =========================================================================================================== --->

	<cffunction name="onApplicationStart" returntype="boolean" output="false">

		<!--- Save timestamp of application initialization --->
		<cfset application.init = Now() />

		<!--- Initialize a property registry for the application --->
		<cfset application.properties = structNew() />
		<cfset application.properties.rootUri = "/" />
		<cfset application.properties.rootFolder = this.rootFolder />
		<cfset application.properties.ontologyLibraryFolder = ExpandPath("./owl") />		
		<cfset application.properties.infLevel = "OWL_DL_MEM" />
	
		<!--- Cache some key CFCs for speed --->
		<cfset application.util.modelFactory = CreateObject("component", "org.panulla.semweb.ModelFactory").init() />	
		
		<cfset application.util.vocab = CreateObject("component", "org.panulla.semweb.VocabularyModel").init() />

		<cfreturn true />
	</cffunction>

	<cffunction name="onApplicationEnd" returntype="boolean" output="false">
		<cfreturn true />
	</cffunction>


	<!--- ========================================================================================================== \
	|	Session
	\ =========================================================================================================== --->

	<cffunction name="onSessionStart" returntype="boolean" output="false">		
		<cfreturn true />
	</cffunction>

	<cffunction name="onSessionEnd" returntype="boolean" output="false">
		<cfreturn true />
	</cffunction>


	<!--- ========================================================================================================== \
	|	Request
	\ =========================================================================================================== --->

	<cffunction name="onRequestStart" returntype="boolean" output="false">
		<cfargument name="request" required="true" />
		<cfreturn true />
	</cffunction>

	<cffunction name="onRequestEnd" returntype="boolean" output="false">
		<cfreturn true />
	</cffunction>
	
</cfcomponent>
