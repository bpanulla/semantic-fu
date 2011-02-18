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

<cf_sparql name="qInferences" model="#variables.infModel#" debug="true">
				
		<cf_sparqlns prefix="rdf" uri="#application.util.vocab.RDF.uri#" />
		<cf_sparqlns prefix="rdfs" uri="#application.util.vocab.RDFS.uri#" />
		<cf_sparqlns prefix="owl" uri="#application.util.vocab.OWL.uri#" />
		<cf_sparqlns prefix="beer" uri="http://www.purl.org/net/ontology/beer##" />
								
		SELECT ?subj ?label
		WHERE {
			?subj rdfs:subClassOf beer:Beer.
			?subj rdf:type ?type.
			OPTIONAL {
				?subj rdfs:label ?label
			}
			FILTER (?subj != owl:Nothing)
		}
</cf_sparql>

Records: <cfoutput>#qInferences.recordcount#</cfoutput><br>
Execution Time: <cfoutput>#CFSPARQL.executionTime#ms</cfoutput><br>

<cfdump var="#qInferences#">

<a href=".">Back</a>
</body>
</html>