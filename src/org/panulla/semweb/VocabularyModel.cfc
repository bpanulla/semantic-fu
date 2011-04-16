<cfcomponent>
	
	<cfscript>
		variables.loader = CreateObject("component", "org.panulla.util.DefaultClassLoader");
				
		function $( classname ) { return variables.loader.create( arguments.classname ); };
	</cfscript>

	<cffunction name="init" access="public" hint="Constructor" returntype="VocabularyModel" output="false">
		<cfargument name="loader" type="JavaLoaderFacade" required="false">
		
		<cfscript>
			if (isDefined("arguments.loader") and isObject(arguments.loader))
			{
				variables.loader = arguments.loader;
			}

			// General Ontologies
			this.rdf = $("com.hp.hpl.jena.vocabulary.RDF");
			this.rdfs = $("com.hp.hpl.jena.vocabulary.RDFS");
			this.owl = $("com.hp.hpl.jena.vocabulary.OWL");
			this.owl2 = $("com.hp.hpl.jena.vocabulary.OWL2");
			this.rss = $("com.hp.hpl.jena.vocabulary.RSS");
			this.vcard = $("com.hp.hpl.jena.vocabulary.VCARD");
			this.xsd = $("com.hp.hpl.jena.vocabulary.XSD");
			this.dc = $("com.hp.hpl.jena.vocabulary.DC");
			this.dcterms = $("com.hp.hpl.jena.vocabulary.DCTerms");
			this.dctypes = $("com.hp.hpl.jena.vocabulary.DCTypes");
			this.foaf = $("com.hp.hpl.jena.sparql.vocabulary.FOAF");
			
			return this;
		</cfscript>
	</cffunction>

</cfcomponent>