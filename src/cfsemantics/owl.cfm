<!---
PARAMETERs

String name (required) : name of returned model
String uri (optional) : uri of rdf graph - this should be used if you are not using the tag as a wrapper
String type (optional) : OWL dialect type


Usage examples:

1. 

<CF_OWL name="wrappedModel">
	<Owl Syntax>...
</CF_OWL>

2.

<CF_OWL nam="remoteModel" uri="http://xlmns.org/foaf/0.1" />

--->

<cfparam name="attributes.name">
<cfparam name="attributes.uri" default="">
<cfparam name="attributes.type" default="OWL-DL">
<cfparam name="request.cf_rdf_lib" default="">

<cfif thistag.ExecutionMode eq "start">

	<!--- turn off cfsetting --->
	<cfsavecontent variable="test">
	HELLO WORLD
	</cfsavecontent>
	<cfif not len(trim(test))>
		<cfset request.enablecfoutputonly = true>
		<cfsetting enablecfoutputonly="false">
	<cfelse>
		<cfset request.enablecfoutputonly = false>
	</cfif>
	
	<!--- create ont model --->
	<cfswitch expression="#attributes.type#">
		<cfcase value="OWL-DL">
			<cfset attributes.ontologyModelType = createObject("java", "com.hp.hpl.jena.ontology.OntModelSpec").OWL_DL_MEM_RULE_INF>
		</cfcase>
		<cfcase value="OWL-LITE">
			<cfset attributes.ontologyModelType = createObject("java", "com.hp.hpl.jena.ontology.OntModelSpec").OWL_LITE_MEM_RULE_INF>
		</cfcase>
		<cfdefaultcase>
			<cfset attributes.ontologyModelType = createObject("java", "com.hp.hpl.jena.ontology.OntModelSpec").OWL_DL_MEM_RULE_INF>
		</cfdefaultcase>
	</cfswitch>
	<cfset attributes.ontologyModel = createObject("java", "com.hp.hpl.jena.rdf.model.ModelFactory").createOntologyModel(attributes.ontologyModelType)>
	<cfset attributes.model = createObject("component", "#request.cf_rdf_lib#Model").init()>
	
	<!--- load file if specified --->
	<cfif len(attributes.uri)>
		<cfset attributes.ontologyModel.read(attributes.uri)>
		<cfset attributes.model.toJava(attributes.ontologyModel)>
		<cfset "caller.#attributes.name#" = attributes.model>
	</cfif>
	
</cfif>

<cfif thistag.executionmode eq "end">

	<!--- load OWL if specified --->
	<cfif not len(attributes.uri)>
		<cfset javaString = createObject("java", "java.lang.String").init(thisTag.generatedContent)>
		<cfset stream = createObject("java", "java.io.ByteArrayInputStream").init(javaString.getBytes())>
		<cfif isXML(thisTag.generatedContent)>
			<cfset attributes.ontologyModel.read(stream, "")>
		<cfelse>
			<cfset attributes.ontologyModel.read(stream, javaCast("null",""), "TURTLE")>
		</cfif>
		<cfset attributes.model.toJava(attributes.ontologyModel)>
		<cfset "caller.#attributes.name#" = attributes.model>
	</cfif>

	<!--- remove tag content and reset cfsetting --->
	<cfset thistag.GeneratedContent = "">
	<cfif request.enablecfoutputonly>
		<cfsetting enablecfoutputonly="true">
	</cfif>

</cfif>