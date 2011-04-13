<cfsetting showdebugoutput="false">
<html>
<head>
	<title>SPARQL Examples</title>
</head>
<body>

<cfscript>
	// Get a standard model
	variables.defaultModel = application.util.modelFactory.getModel();
		
	// Read in Beer Ontology
	variables.beerOntology = application.properties.ontologyLibraryFolder & "/beer.owl";
	variables.defaultModel.read( variables.beerOntology, "http://www.purl.org/net/ontology/beer##" );
</cfscript>

<cf_sparql name="qInstances" model="#variables.defaultModel#" debug="true">
				
		<cf_sparqlns prefix="rdf" uri="#application.util.vocab.RDF.uri#" />
		<cf_sparqlns prefix="rdfs" uri="#application.util.vocab.RDFS.uri#" />
		<cf_sparqlns prefix="owl" uri="#application.util.vocab.OWL.uri#" />
		<cf_sparqlns prefix="beer" uri="http://www.purl.org/net/ontology/beer##" />
								
		SELECT ?subj
		WHERE {
			?subj rdfs:subClassOf beer:Beer.
		}
</cf_sparql>

Records: <cfoutput>#qInstances.recordcount#</cfoutput><br>
Execution Time: <cfoutput>#CFSPARQL.executionTime#ms</cfoutput><br>

<cfdump var="#qInstances#">

<a href=".">Back</a>
</body>
</html>