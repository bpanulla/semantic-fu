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
	
	variables.infModel = application.util.modelFactory.getReasoningModel(
							application.properties.infLevel,
							variables.defaultModel);
							
	variables.infModel.read(variables.ontoByteStream, "http://www.purl.org/net/ontology/beer##");

</cfscript>

<cf_sparql name="qInstances" model="#variables.infModel#">
				
		<cf_sparqlns prefix="rdf" uri="#application.util.vocab.RDF.uri#" />
		<cf_sparqlns prefix="rdfs" uri="#application.util.vocab.RDFS.uri#" />
		<cf_sparqlns prefix="owl" uri="#application.util.vocab.OWL.uri#" />
		<cf_sparqlns prefix="beer" uri="http://www.purl.org/net/ontology/beer##" />
								
		SELECT ?beer ?type
		WHERE {
			?beer rdf:type beer:Beer.
			OPTIONAL {
				?beer rdf:type ?type.
			}
			FILTER (?type != owl:Thing && ?type != beer:Beer)
		}
</cf_sparql>

<cfdump var="#qInstances#">

<a href=".">Back</a>
</body>
</html>