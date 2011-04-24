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

<cfcomponent name="Application" output="false">

	<!--- ========================================================================================================== \
	|	Constructor
	\ =========================================================================================================== --->

	<!--- Application settings --->
	<cfset this.name = "BeerBrowser" />
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
		
		<cfreturn true />
	</cffunction>	
</cfcomponent>
