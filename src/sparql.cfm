<cfsilent>

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