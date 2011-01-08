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
			this.vocab = structNew();
			this.vocab.rdf = variables.loader.create("com.hp.hpl.jena.vocabulary.RDF");
			this.vocab.rdfs = variables.loader.create("com.hp.hpl.jena.vocabulary.RDFS");
			this.vocab.owl = variables.loader.create("com.hp.hpl.jena.vocabulary.OWL");
			this.vocab.owl2 = variables.loader.create("com.hp.hpl.jena.vocabulary.OWL2");
			this.vocab.rss = variables.loader.create("com.hp.hpl.jena.vocabulary.RSS");
			this.vocab.vcard = variables.loader.create("com.hp.hpl.jena.vocabulary.VCARD");
			this.vocab.xsd = variables.loader.create("com.hp.hpl.jena.vocabulary.XSD");
			this.vocab.dc = variables.loader.create("com.hp.hpl.jena.vocabulary.DC");
			this.vocab.dcterms = variables.loader.create("com.hp.hpl.jena.vocabulary.DCTerms");
			this.vocab.dctypes = variables.loader.create("com.hp.hpl.jena.vocabulary.DCTypes");
			this.vocab.foaf = variables.loader.create("com.hp.hpl.jena.sparql.vocabulary.FOAF");
		</cfscript>
	
		<cfreturn this>
	</cffunction>

</cfcomponent>