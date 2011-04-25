<cfsilent>
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

<cfparam name="attributes.name" type="variablename" />
<cfparam name="attributes.model" type="any" />
<cfparam name="attributes.returnformat" type="string" default="" />
<cfparam name="attributes.debug" type="boolean" default="false" />
<cfparam name="attributes.returnMetadata" type="variablename" default="CFSPARQL" />

<cfset newline = chr(13) & chr(10) />

<!--- Validate parameters --->
<cfif NOT IsDefined("thisTag.executionMode")>
	<cfthrow type="CF_SPARQL" message="Must be called as custom tag.">

<cfelseif NOT isInstanceOf(attributes.model, "org.panulla.semweb.Model")>
	<cfthrow type="CF_SPARQL" message="Model reference is not a known model type.">
</cfif>

<cfif thisTag.executionMode IS "end">
	<!--- Grab the query source --->
	<cfset q = thisTag.GeneratedContent />

	<cfif attributes.debug>
		<cfset thisTag.GeneratedContent = "<pre>" & newline & HTMLEditFormat(thisTag.GeneratedContent) & newline & "</pre>" />
	<cfelse>
		<!--- Reset the generated content; no output from this tag --->
		<cfset thisTag.GeneratedContent = "" />
	</cfif>
	
	<!--- Run the query --->
	<cfset caller["#attributes.name#"] = attributes.model.query( q, attributes.returnFormat ) />
	
	<cfset caller[attributes.returnMetadata] = request.sparql />
</cfif>

</cfsilent>