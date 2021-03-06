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

	// Get a standard model
	variables.defaultModel = variables.modelFactory.getModel();
		
	// Read in Beer Ontology
	variables.defaultModel.read( expandPath("./owl/beer.owl"), "http://www.purl.org/net/ontology/beer##" );
</cfscript>

<cf_sparql name="qAllTriples" model="#variables.defaultModel#">
	SELECT ?subj ?pred ?obj
	WHERE {
		?subj ?pred ?obj.
	}
</cf_sparql>

<html>
<head>
	<title>SPARQL Examples: All Triples</title>
</head>
<body>

<h1>All Triples</h1>

Records: <cfoutput>#qAllTriples.recordcount#</cfoutput><br>
Execution Time: <cfoutput>#CFSPARQL.executionTime#ms</cfoutput><br>
Source: <div><pre><cfoutput>#HTMLEditFormat(CFSPARQL.source)#</cfoutput></pre></div>

<cfdump var="#qAllTriples#" expand="false">

<a href=".">Back</a>
</body>
</html>