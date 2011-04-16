<cfsetting showdebugoutput="false">
<html>
<head>
	<title>SPARQL Examples</title>
</head>
<body>

<cfscript>
	variables.modelFactory = CreateObject("component", "org.panulla.semweb.ModelFactory").init();	
	variables.vocab = CreateObject("component", "org.panulla.semweb.VocabularyModel").init();

	// Get a model with inferencing
	variables.infModel = variables.modelFactory.getReasoningModel( application.properties.infLevel );
							
	// Read in Beer Ontology
	variables.beerOntology = application.properties.ontologyLibraryFolder & "/beer.owl";
	variables.infModel.read( variables.beerOntology, "http://www.purl.org/net/ontology/beer##" );	
</cfscript>

<cf_sparql name="qInstances" model="#variables.infModel#" debug="true">
				
		<cf_sparqlns prefix="rdf" uri="#variables.vocab.RDF.uri#" />
		<cf_sparqlns prefix="rdfs" uri="#variables.vocab.RDFS.uri#" />
		<cf_sparqlns prefix="owl" uri="#variables.vocab.OWL.uri#" />
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

Records: <cfoutput>#qInstances.recordcount#</cfoutput><br>
Execution Time: <cfoutput>#CFSPARQL.executionTime#ms</cfoutput><br>

<cfdump var="#qInstances#">

<a href=".">Back</a>
</body>
</html>