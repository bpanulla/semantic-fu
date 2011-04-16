<cfsetting showdebugoutput="false">
<html>
<head>
	<title>SPARQL Examples</title>
</head>
<body>

<cfscript>
	variables.modelFactory = CreateObject("component", "org.panulla.semweb.ModelFactory").init();	
	variables.vocab = CreateObject("component", "org.panulla.semweb.VocabularyModel").init();

	// Get a standard model
	variables.defaultModel = variables.modelFactory.getModel();
		
	// Read in Beer Ontology
	variables.beerOntology = application.properties.ontologyLibraryFolder & "/beer.owl";
	variables.defaultModel.read( variables.beerOntology, "http://www.purl.org/net/ontology/beer##" );
</cfscript>

<cf_sparql name="qAllTriples" model="#variables.defaultModel#" debug="true">
				
		<cf_sparqlns prefix="rdf" uri="#variables.vocab.RDF.uri#" />
		<cf_sparqlns prefix="rdfs" uri="#variables.vocab.RDFS.uri#" />
		<cf_sparqlns prefix="owl" uri="#variables.vocab.OWL.uri#" />
		<cf_sparqlns prefix="beer" uri="http://www.purl.org/net/ontology/beer##" />
								
		SELECT ?subj ?pred ?obj
		WHERE {
			?subj ?pred ?obj.
		}
</cf_sparql>

Records: <cfoutput>#qAllTriples.recordcount#</cfoutput><br>
Execution Time: <cfoutput>#CFSPARQL.executionTime#ms</cfoutput><br>

<cfdump var="#qAllTriples#" expand="false">

<a href=".">Back</a>
</body>
</html>