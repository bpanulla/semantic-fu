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

<cfsetting showdebugoutput="false">

<cfscript>
	variables.modelFactory = CreateObject("component", "org.panulla.semweb.ModelFactory").init();	
	variables.vocab = CreateObject("component", "org.panulla.semweb.VocabularyModel").init();

	// Get a model with inferencing
	variables.infModel = variables.modelFactory.getReasoningModel( application.properties.infLevel );
							
	// Read in Beer Ontology
	variables.beerOntology = application.properties.ontologyLibraryFolder & "/beer.owl";
	variables.infModel.read( variables.beerOntology, "http://www.purl.org/net/ontology/beer##" );	
</cfscript>

<cf_sparql name="qInstances" model="#variables.infModel#">
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

<html>
<head>
	<title>SPARQL Examples: Instances</title>
</head>
<body>

<h1>Instances</h1>

Records: <cfoutput>#qInstances.recordcount#</cfoutput><br>
Execution Time: <cfoutput>#CFSPARQL.executionTime#ms</cfoutput><br>
Source: <div><pre><cfoutput>#HTMLEditFormat(CFSPARQL.source)#</cfoutput></pre></div>

<cfdump var="#qInstances#">

<a href=".">Back</a>
</body>
</html>