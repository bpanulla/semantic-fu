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

<cfcomponent>
	
	<cfscript>
		// Instantiate a default loader
		variables.loader = CreateObject("component", "org.panulla.util.JavaLoaderFacade").init();
		
		// Helper function to clean up calls to the class loader
		function $( classname ) { return variables.loader.create( arguments.classname ); };
	</cfscript>
	
	<cffunction name="init" access="public" hint="Constructor" returntype="org.panulla.semweb.VocabularyModel" output="false">
		<cfargument name="loader" type="org.panulla.util.JavaLoaderFacade" required="false">
		
		<cfscript>
			if (isDefined("arguments.loader"))
			{
				// Use the loader passed as constructor argument
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