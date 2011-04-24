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

<cfsilent>
	<cfparam name="attributes.value" type="string" />
	<cfparam name="attributes.type" type="string" default="string" />
	<cfparam name="attributes.lang" type="string" default="" />
	
	<cfset validTypes = "xsd:integer,xsd:decimal,xsd:float,xsd:double,xsd:string,xsd:boolean,xsd:dateTime" />

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
				<cfif isSimpleValue(attributes.value) AND (listFind(validTypes,attributes.type) OR NOT len(attributes.type))>
					<cfset output = '"#attributes.value#"^^#attributes.type#' />
				<cfelse>
					<cfthrow type="SPARQLParam" message="Value is not simple, or type not recognized." />
				</cfif>
			</cfdefaultcase>	
		</cfswitch>
	</cfif>
</cfsilent>
<cfoutput>#output#</cfoutput>