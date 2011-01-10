<cfcomponent>
	
	<cfscript>
			variables.loader = CreateObject("component", "org.panulla.util.DefaultClassLoader");
	</cfscript>

	<cffunction name="init" access="public" hint="Constructor" returntype="VocabularyModel" output="false">
		<cfargument name="loader" type="JavaLoaderFacade" required="false">
		
		<cfscript>
			if (isDefined("arguments.loader") and isObject(arguments.loader))
			{
				variables.loader = arguments.loader;
			}

			// General Ontologies
			this.rdf = variables.loader.create("com.hp.hpl.jena.vocabulary.RDF");
			this.rdfs = variables.loader.create("com.hp.hpl.jena.vocabulary.RDFS");
			this.owl = variables.loader.create("com.hp.hpl.jena.vocabulary.OWL");
			this.owl2 = variables.loader.create("com.hp.hpl.jena.vocabulary.OWL2");
			this.rss = variables.loader.create("com.hp.hpl.jena.vocabulary.RSS");
			this.vcard = variables.loader.create("com.hp.hpl.jena.vocabulary.VCARD");
			this.xsd = variables.loader.create("com.hp.hpl.jena.vocabulary.XSD");
			this.dc = variables.loader.create("com.hp.hpl.jena.vocabulary.DC");
			this.dcterms = variables.loader.create("com.hp.hpl.jena.vocabulary.DCTerms");
			this.dctypes = variables.loader.create("com.hp.hpl.jena.vocabulary.DCTypes");
			this.foaf = variables.loader.create("com.hp.hpl.jena.sparql.vocabulary.FOAF");
		</cfscript>
		
		<cfreturn this />
	</cffunction>

</cfcomponent>