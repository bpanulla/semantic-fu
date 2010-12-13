<cfsilent>

<cfparam name="attributes.prefix" type="string" />
<cfparam name="attributes.uri" type="string" />

<cfset newline = chr(13) & chr(10) />

<cfif thisTag.executionMode IS "end">
	<cfif isSimpleValue(attributes.prefix) AND isValid("URL", attributes.uri)>
		<cfset thisTag.generatedContent = "PREFIX #attributes.prefix#: <#attributes.uri#>" & newline />
	<cfelse>
		<cfthrow type="SPARQLNS" message="Could not construct namespace from parameters." />
	</cfif>
</cfif>
</cfsilent>