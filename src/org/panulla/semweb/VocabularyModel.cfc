<cfcomponent>
	
	<cfscript>
			variables.loader = CreateObject("component", "org.panulla.semweb.DefaultClassLoader");
	</cfscript>

	<cffunction name="init" access="public" hint="Constructor" returntype="VocabularyModel" output="false">
		<cfargument name="loader" type="javaloader.JavaLoader">
		
		<cfscript>
			this.loader = variables.loader; //arguments.loader;

			// General Ontologies
			this.vocab = structNew();
			this.vocab.rdf = this.loader.create("com.hp.hpl.jena.vocabulary.RDF");
			this.vocab.rdfs = this.loader.create("com.hp.hpl.jena.vocabulary.RDFS");
			this.vocab.owl = this.loader.create("com.hp.hpl.jena.vocabulary.OWL");
			this.vocab.owl2 = this.loader.create("com.hp.hpl.jena.vocabulary.OWL2");
			this.vocab.rss = this.loader.create("com.hp.hpl.jena.vocabulary.RSS");
			this.vocab.vcard = this.loader.create("com.hp.hpl.jena.vocabulary.VCARD");
			this.vocab.xsd = this.loader.create("com.hp.hpl.jena.vocabulary.XSD");
			this.vocab.dc = this.loader.create("com.hp.hpl.jena.vocabulary.DC");
			this.vocab.dcterms = this.loader.create("com.hp.hpl.jena.vocabulary.DCTerms");
			this.vocab.dctypes = this.loader.create("com.hp.hpl.jena.vocabulary.DCTypes");
			this.vocab.foaf = this.loader.create("com.hp.hpl.jena.sparql.vocabulary.FOAF");
		</cfscript>
	
		<cfreturn this>
	</cffunction>

</cfcomponent>