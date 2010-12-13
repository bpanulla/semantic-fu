<cfsilent>
	<cfparam name="attributes.value" type="string" />
	<cfparam name="attributes.type" type="string" default="string" />
	<cfparam name="attributes.lang" type="string" default="" />
	
	<cfset validTypes = ["xsd:integer","xsd:decimal","xsd:float","xsd:double","xsd:string","xsd:string","xsd:boolean","xsd:dateTime"] />

	<cfset output = "" />
	
	<cfif thisTag.executionMode IS "start">
		<cfswitch expression="#attributes.type#">
			<cfcase value="iri">
				<cfif isValid("URL", attributes.value)>
					<cfset output = "<#attributes.value#>" />
				<cfelse>
					<cfthrow type="SPARQLParam" message="Value is not a valid IRI." />
				</cfif>
			</cfcase>
	
			<cfdefaultcase>
				<cfif isSimpleValue(attributes.value) AND (arrayContains(validTypes,attributes.type) OR NOT len(attributes.type))>
					<cfset output = '"#attributes.value#"^^#attributes.type#' />
				<cfelse>
					<cfthrow type="SPARQLParam" message="Value is not simple, or type not recognized." />
				</cfif>
			</cfdefaultcase>	
		</cfswitch>
	</cfif>
</cfsilent>
<cfoutput>#output#</cfoutput>