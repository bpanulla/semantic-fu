<cfsilent>

<cfparam name="attributes.name" type="variablename" />
<cfparam name="attributes.model" type="any" />
<cfparam name="attributes.returnformat" type="string" default="" />
<cfparam name="attributes.debug" type="boolean" default="false" />
<cfparam name="attributes.returnMetadata" type="variablename" default="CFSPARQL" />

<cffunction name="resultSet2Query">
	<cfargument name="result" type="any" required="true" />
	
	<cfscript>
			var local = {};
			local.bindings = arguments.result.getResultVars();
			local.bList = "";
			
			for ( local.i = 0; local.i < local.bindings.size(); local.i = local.i + 1 )
			{
				local.binding  = local.bindings.get(local.i);
				if (len(trim(local.binding))) local.bList = listAppend(local.bList, local.binding);
			}
			local.returnValue = queryNew(local.bList);
			
			while ( arguments.result.hasNext() )
			{
				local.solution = arguments.result.next();
				queryAddRow(local.returnValue);
				
				local.varNames = local.solution.varNames();
				while ( local.varNames.hasNext() )
				{
					local.thisVar = local.varNames.next();
					local.thisVal = "";
					
					try
					{
						// Try to retrieve as a literal
						local.thisVal = local.solution.getLiteral(local.thisVar).getValue();
					}
					catch ( "java.lang.ClassCastException" e )
					{
							local.thisVal = local.solution.get(local.thisVar).toString();
					}

					querySetCell(local.returnValue, local.thisVar, local.thisVal);
				}
			}
	</cfscript>
	
	<cfreturn local.returnValue />
</cffunction>


<cfset newline = chr(13) & chr(10) />

<!--- Validate parameters --->
<cfif NOT IsDefined("thisTag.executionMode")>
	<cfthrow type="CF_SPARQL" message="Must be called as custom tag.">

<cfelseif NOT isInstanceOf(attributes.model, "com.hp.hpl.jena.rdf.model.impl.ModelCom")
					AND NOT isInstanceOf(attributes.model, "com.hp.hpl.jena.rdf.model.impl.InfModelImpl")
					AND NOT isInstanceOf(attributes.model, "com.hp.hpl.jena.ontology.impl.OntModelImpl")>
	<cfthrow type="CF_SPARQL" message="Model reference is not a known model type.">
</cfif>

<cfif thisTag.executionMode IS "end">
	<!--- Grab the query source --->
	<cfset q = thisTag.GeneratedContent />

	<cfif attributes.debug>
		<cfset thisTag.GeneratedContent = "<pre>" & newline & HTMLEditFormat(thisTag.GeneratedContent) & newline & "</pre>" />
	<cfelse>
		<!--- Reset the generated content; no output from this tag --->
		<cfset thisTag.GeneratedContent = "" />
	</cfif>
	
	<cfscript>
		QueryFactory = createObject("java", "com.hp.hpl.jena.query.QueryFactory");
		QueryExecutionFactory = createObject("java", "com.hp.hpl.jena.query.QueryExecutionFactory");
		query = QueryFactory.create(q);
		
		// Time the query
		tickBegin = GetTickCount(); 
		
		if (query.isSelectType())
		{
			// Execute the query
			qe = QueryExecutionFactory.create(query, attributes.model);
			result = qe.execSelect();
			
			// Format the result
			ResultSetFormatter = createObject("java", "com.hp.hpl.jena.query.ResultSetFormatter");
			
			switch (attributes.returnformat)
			{
				case "xml": // XML result object
					returnValue = XmlParse(ResultSetFormatter.asXMLString(result));
					break;
				
				case "pre": // Preformatted text for HTML
					returnValue = "<pre>" & HTMLEditFormat(ResultSetFormatter.asText(result, query)) & "</pre>";
					break;
				
				case "text": //raw text
					returnValue = ResultSetFormatter.asText(result, query);
					break;
			
				default: // Query Object
					returnValue = resultSet2Query(result);
			}
		}
		else if (query.isAskType())
		{
			// Execute the query
			qe = QueryExecutionFactory.create(query, attributes.model);
			result = qe.execAsk();
			
			// Format the result
			ResultSetFormatter = createObject("java", "com.hp.hpl.jena.query.ResultSetFormatter");
			
			switch (attributes.returnformat)
			{
				case "xml": // XML result object
					returnValue = XmlParse(ResultSetFormatter.asXMLString(result));
					break;
				
				case "pre": // Preformatted text for HTML
				case "text": //raw text
					returnValue = result;
					break;
			
				default: // Boolean Object
					returnValue = result;
				}
		}
		else
		{
			throw( type="CF_SPARQL", message="Unsupported query type.");
		}

		// Free up resources used running the query
		qe.close();
		
		tickEnd = GetTickCount(); 
		executionTime = tickEnd - tickBegin;
	</cfscript>
	
	<cfset caller["#attributes.name#"] = returnValue />
	
	<cfset metadata = structNew() />
	<cfset metadata.executionTime = executionTime />
	
	<cfset caller[attributes.returnMetadata] = metadata />
</cfif>

</cfsilent>
