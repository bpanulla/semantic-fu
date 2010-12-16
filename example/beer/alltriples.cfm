<cfsetting showdebugoutput="false">
<html>
<head>
	<title>SPARQL Examples</title>
</head>
<body>

<cfscript>
	// Read in Beer Ontology
	variables.beerOntology = fileRead(application.properties.ontologyLibraryFolder & "/beer.owl");
	variables.ontoByteStream = createObject("java", "java.io.ByteArrayInputStream")
																		.init(variables.beerOntology.getBytes());			
	
	variables.defaultModel = application.util.modelFactory.getModel();
	variables.defaultModel.read(variables.ontoByteStream, "http://www.purl.org/net/ontology/beer##");
</cfscript>

<cf_sparql name="qAllTriples" model="#variables.defaultModel#">
				
		<cf_sparqlns prefix="rdf" uri="#application.util.vocab.RDF.uri#" />
		<cf_sparqlns prefix="rdfs" uri="#application.util.vocab.RDFS.uri#" />
		<cf_sparqlns prefix="owl" uri="#application.util.vocab.OWL.uri#" />
		<cf_sparqlns prefix="beer" uri="http://www.purl.org/net/ontology/beer##" />
								
		SELECT ?subj ?pred ?obj
		WHERE {
			?subj ?pred ?obj.
		}
</cf_sparql>

<cfdump var="#qAllTriples#">

<a href=".">Back</a>
</body>
</html>