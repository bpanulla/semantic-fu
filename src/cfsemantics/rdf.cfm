<!---
PARAMETERs

String name (required) : name of returned model
String uri (optional) : uri of rdf graph - this should be used if you are not using the tag as a wrapper
Model rules (optional) : OWL rules for reasoning as a model
String contenttype (optional) : contenttype of RDF. Currently supported values are RDF/XML and TURTLE.
String reasoning (optional) : mode of reasoning. Full reasoning includes OWL model
--->

<cfparam name="attributes.name">
<cfparam name="attributes.uri" default="">
<cfparam name="attributes.contenttype" default="RDF/XML">
<cfparam name="request.cf_rdf_lib" default="">
<cfparam name="attributes.reasoning" default="data">

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
	
	<cfset attributes.model = createObject("component", "#request.cf_rdf_lib#Model").init()>
	
	<!--- load file if specified --->
	<cfif len(attributes.uri)>
		<cfset attributes.model.asJava().read(attributes.uri)>
		<cfif isDefined("attributes.rules")>
			<cfset attributes.reasoner = createObject("java","com.hp.hpl.jena.reasoner.ReasonerRegistry").getOWLReasoner()> 
			<!--- reasoning over data only --->
			<cfif attributes.reasoning eq "data">
				<cfset attributes.inferredOWLModel = createObject("java", "com.hp.hpl.jena.rdf.model.ModelFactory").createInfModel(attributes.reasoner, attributes.rules.asJava(),attributes.rules.asJava())>
				<cfset attributes.inferredModel = createObject("java", "com.hp.hpl.jena.rdf.model.ModelFactory").createInfModel(attributes.reasoner, attributes.rules.asJava(),attributes.model.asJava())>
				<cfset iterator = attributes.inferredModel.listStatements()>
				<cfset tmp = attributes.model.asJava()>
				<cfloop condition="iterator.hasNext()">
					<cfset statement = iterator.nextStatement()>
					<cfif not attributes.inferredOWLModel.contains(statement) and not tmp.contains(statement)>
						<cfset attributes.model.asJava().add(statement)>
					</cfif>
				</cfloop>
			<cfelse>
			<!--- full reasoning --->
				<cfset attributes.reasoner = createObject("java","com.hp.hpl.jena.reasoner.ReasonerRegistry").getOWLReasoner()> 
				<cfset attributes.inferredModel = createObject("java", "com.hp.hpl.jena.rdf.model.ModelFactory").createInfModel(attributes.reasoner, attributes.rules.asJava(),attributes.model.asJava())>
				<cfset attributes.model.toJava(attributes.inferredModel)>
			</cfif>
			<cfset "caller.#attributes.name#" = attributes.model>
		<cfelse>
			<cfset "caller.#attributes.name#" = attributes.model>
		</cfif>
	</cfif>
	
</cfif>

<cfif thistag.executionmode eq "end">

	<!--- load RDF if specified --->
	<cfif not len(attributes.uri)>
		<cfset javaString = createObject("java", "java.lang.String").init(toString(thisTag.generatedContent))>
		<cfset stream = createObject("java", "java.io.ByteArrayInputStream").init(javaString.getBytes())>
		<cfif isXML(thisTag.generatedContent)>
			<cfset attributes.model.asJava().read(stream, "")>
		<cfelse>
			<cfset attributes.model.asJava().read(stream, javaCast("null",""), "TURTLE")>	
		</cfif>
		
		
		<cfif isDefined("attributes.rules")>
			<cfset attributes.reasoner = createObject("java","com.hp.hpl.jena.reasoner.ReasonerRegistry").getOWLReasoner()> 
			<!--- reasoning over data only --->
			<cfif attributes.reasoning eq "data">
				<cfset attributes.inferredOWLModel = createObject("java", "com.hp.hpl.jena.rdf.model.ModelFactory").createInfModel(attributes.reasoner, attributes.rules.asJava(),attributes.rules.asJava())>
				<cfset attributes.inferredModel = createObject("java", "com.hp.hpl.jena.rdf.model.ModelFactory").createInfModel(attributes.reasoner, attributes.rules.asJava(),attributes.model.asJava())>
				<cfset iterator = attributes.inferredModel.listStatements()>
				<cfset tmp = attributes.model.asJava()>
				<cfloop condition="iterator.hasNext()">
					<cfset statement = iterator.nextStatement()>
					<cfif not attributes.inferredOWLModel.contains(statement) and not tmp.contains(statement)>
						<cfset attributes.model.asJava().add(statement)>
					</cfif>
				</cfloop>
			<cfelse>
			<!--- full reasoning --->
				<cfset attributes.reasoner = createObject("java","com.hp.hpl.jena.reasoner.ReasonerRegistry").getOWLReasoner()> 
				<cfset attributes.inferredModel = createObject("java", "com.hp.hpl.jena.rdf.model.ModelFactory").createInfModel(attributes.reasoner, attributes.rules.asJava(),attributes.model.asJava())>
				<cfset attributes.model.toJava(attributes.inferredModel)>
			</cfif>
			<cfset "caller.#attributes.name#" = attributes.model>
		<cfelse>
			<cfset "caller.#attributes.name#" = attributes.model>
		</cfif>	
		
	</cfif>
	

	<!--- remove tag content and reset cfsetting --->
	<cfset thistag.GeneratedContent = "">
	<cfif request.enablecfoutputonly>
		<cfsetting enablecfoutputonly="true">
	</cfif>

</cfif>