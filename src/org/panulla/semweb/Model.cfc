<cfcomponent output="false">
	
	<cfscript>
		variables.jenaModelClasses =
			"com.hp.hpl.jena.rdf.model.Model," &
			"com.hp.hpl.jena.db.ModelRDB," &
			"com.hp.hpl.jena.rdf.model.impl.ModelCom," &
			"com.hp.hpl.jena.rdf.model.impl.InfModelImpl," &
			"com.hp.hpl.jena.ontology.impl.OntModelImpl";
	</cfscript>

	
	<cffunction name="init" access="public" output="false" returntype="org.panulla.semweb.Model">
		<cfargument name="model" type="any" required="true" />
		<cfargument name="loader" type="any" required="false" />
		
		<cfscript>
			setSource( arguments.model );
			setLoader( arguments.loader );
			
			return this;
		</cfscript>
	</cffunction>
	
	
	<!--- =========================================================
	* Model configuration
	\========================================================= --->

	<cffunction name="getLoader" access="public" output="false" returntype="any">
		<cfscript>
			return variables.loader;
		</cfscript>
	</cffunction>


	<cffunction name="setLoader" access="public" output="false" returntype="org.panulla.semweb.Model">
		<cfargument name="loader" type="any" required="true" />
		
		<cfscript>
			if ( not isDefined("arguments.loader.create") or not isCustomFunction(arguments.loader.create) )
			{
				throwException("Model", "Invalid class loader", "The argument passed to the setLoader() method does not appear to be a Java class loader");	
			}
			
			variables.loader = arguments.loader;
		
			return this;
		</cfscript>
	</cffunction>


	<cffunction name="getSource" access="public" output="false" returntype="any">
		<cfscript>
			return variables.model;
		</cfscript>
	</cffunction>


	<cffunction name="setSource" access="public" output="false" returntype="org.panulla.semweb.Model">
		<cfargument name="model" type="any" required="true" />
		
		<cfscript>
			var local = {};
			local.modelClass = GetMetaData( arguments.model ).getCanonicalName();
		
			if (not listFind( variables.jenaModelClasses, modelClass ))
			{
				throwException("Model", "Invalid model type", "Instance of type '#modelClass#' passed to setSource() method is not a known model type.");	
			}
			
			variables.model = arguments.model;
			
			return this;
		</cfscript>
	</cffunction>


	<cffunction name="setNsPrefix" access="public" output="false" returntype="org.panulla.semweb.Model">
		<cfargument name="prefix" type="string" required="true" />
		<cfargument name="uri" type="string" required="true" />
		
		<cfscript>
			variables.model.setNsPrefix( arguments.prefix, arguments.uri );
			
			return this;
		</cfscript>
	</cffunction>
	
	
	<!--- =========================================================
	* Data input/output methods
	\========================================================= --->
		
	<cffunction name="read" access="public" output="false" returntype="org.panulla.semweb.Model">
		<cfargument name="path" type="string" required="true" />
		<cfargument name="baseUri" type="string" required="true" />
		
		<cfscript>
			var local = {};
			local.source = fileRead( arguments.path );
			
			return load( local.source, arguments.baseUri );
		</cfscript>
	</cffunction>
	
	
	<cffunction name="write" access="public" output="false" returntype="void">
		<cfargument name="path" type="string" required="true" />
		<cfargument name="format" type="string" required="true" />
		
		<cfscript>
			fileWrite( arguments.path, dump( arguments.format ) );
		</cfscript>
	</cffunction>


	<cffunction name="load" access="public" output="false" returntype="org.panulla.semweb.Model">
		<cfargument name="source" type="string" required="true" />
		<cfargument name="baseUri" type="string" required="true" />
		
		<cfscript>
			var local = {};
			local.byteStream = variables.loader.create("java.io.ByteArrayInputStream").init(arguments.source.getBytes());			
			variables.model.read( local.byteStream, arguments.baseUri );
			
			return this;
		</cfscript>
	</cffunction>


	<cffunction name="dump" access="public" output="false" returntype="string">
		<cfargument name="format" type="string" required="true" />
		
		<cfscript>
			var local = {};
			local.byteStream = variables.loader.create("java.io.ByteArrayOutputStream").init();
			variables.model.write( local.byteStream, arguments.format );
			
			return local.byteStream.toString();
		</cfscript>
	</cffunction>
		

	<!--- =========================================================
	* Resource methods
	\========================================================= --->

	<cffunction name="getResource" access="public" output="false" returntype="any">
		<cfargument name="uri" type="string" required="true" />
		
		<cfscript>
			return variables.model.getResource( arguments.uri );
		</cfscript>
	</cffunction>
		

	<cffunction name="createResource" access="public" output="false" returntype="any">
		<cfargument name="uri" type="string" required="true" />
		
		<cfscript>
			return variables.model.createResource( arguments.uri );
		</cfscript>
	</cffunction>


	<cffunction name="removeAll" access="public" output="false" returntype="org.panulla.semweb.Model">
		<cfargument name="subject" type="any" required="false" />
		<cfargument name="predicate" type="any" required="false" />
		<cfargument name="object" type="any" required="false" />
		
		<cfscript>
			/*
			writeOutput("subject: " & isDefined("arguments.subject") & "<br>" );
			writeOutput("predicate: " & isDefined("arguments.predicate") & "<br>" );
			writeOutput("object: " & isDefined("arguments.object") & "<br>" );
			*/

			variables.model.removeAll(
				ifNotInScopeThenJavaNull( arguments, "subject" ),
				ifNotInScopeThenJavaNull( arguments, "predicate" ),
				ifNotInScopeThenJavaNull( arguments, "object" )
			 );
			 
			 return this;
		</cfscript>
	</cffunction>

	<!--- =========================================================
	* SPARQL Query methods
	\========================================================= --->

	<cffunction name="query" access="public" output="false" returntype="any">
		<cfargument name="source" type="string" required="true" />
		<cfargument name="returnformat" type="string" required="false" default="query" />

		<cfscript>
			var local = {};

			local.query = getQueryFactory().create( arguments.source );
			
			// Time the query
			local.tickBegin = GetTickCount(); 
		
			if (local.query.isSelectType())
			{
				// Execute the query
				local.exec = getQueryExecutionFactory().create(local.query, variables.model);
				local.result = local.exec.execSelect();
				
				// Format the result
				switch (arguments.returnformat)
				{
					case "xml": // XML result object
						local.returnValue = XmlParse(getResultSetFormatter().asXMLString(local.result));
						break;
					
					case "pre": // Preformatted text for HTML
						local.returnValue = "<pre>" & HTMLEditFormat(getResultSetFormatter().asText(local.result, local.query)) & "</pre>";
						break;
					
					case "text": //raw text
						local.returnValue = getResultSetFormatter().asText(local.result, local.query);
						break;
				
					default: // Query Object
						local.returnValue = resultSet2Query(local.result);
				}
			}
			else if (local.query.isAskType())
			{
				// Execute the query
				local.exec = getQueryExecutionFactory().create(local.query, variables.model);
				local.result = local.exec.execAsk();
				
				// Format the result
				switch (arguments.returnformat)
				{
					case "xml": // XML result object
						local.returnValue = XmlParse(getResultSetFormatter().asXMLString(local.result));
						break;
					
					case "pre": // Preformatted text for HTML
					case "text": //raw text
						local.returnValue = local.result;
						break;
				
					default: // Boolean Object
						local.returnValue = local.result;
					}
			}
			else
			{
				throwException( "Model", "Unsupported SPARQL query type.");
			}

			// Free up resources used running the query
			local.exec.close();
			
			// Pop the query statistics out to the request scope
			request.sparql.executionTime = GetTickCount() - local.tickBegin;
			request.sparql.source = arguments.source;
			
			return local.returnValue;
		</cfscript>
	</cffunction>
	
	
	<!--- =========================================================
	* Protected utility methods
	\========================================================= --->

	<cffunction name="ifNotInScopeThenJavaNull" access="package" output="false" returntype="any">
		<cfargument name="scope" type="struct" required="true" />
		<cfargument name="key" type="string" required="true" />
		
		<cfscript>
			if ( structKeyExists( arguments.scope, key) )
			{
				return arguments.scope[key];
			}
			else
			{
				return JavaCast("null", "");
			}
		</cfscript>
	</cffunction>


	<cffunction name="getQueryFactory" access="package" output="false" returntype="any">
		<cfscript>
			if ( not isDefined("variables.QueryFactory") )
			{
				variables.QueryFactory = variables.loader.create("com.hp.hpl.jena.query.QueryFactory");
			}
			
			return variables.QueryFactory;
		</cfscript>
	</cffunction>


	<cffunction name="getQueryExecutionFactory" access="package" output="false" returntype="any">
		<cfscript>
			if ( not isDefined("variables.QueryExecutionFactory") )
			{
				variables.QueryExecutionFactory = variables.loader.create("com.hp.hpl.jena.query.QueryExecutionFactory");
			}
			
			return variables.QueryExecutionFactory;
		</cfscript>
	</cffunction>


	<cffunction name="getResultSetFormatter" access="package" output="false" returntype="any">
		<cfscript>
			if ( not isDefined("variables.ResultSetFormatter") )
			{
				variables.ResultSetFormatter = variables.loader.create("com.hp.hpl.jena.query.ResultSetFormatter");
			}
			
			return variables.ResultSetFormatter;
		</cfscript>
	</cffunction>


	<cffunction name="resultSet2Query" access="package" output="false" returntype="query">
		<cfargument name="result" required="true" type="any" />
		
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
			
			return local.returnValue;
		</cfscript>
	</cffunction>


	<cffunction name="throwException" access="private" hint="Wraps CFTHROW in a function" output="false" returntype="void">
		<cfargument name="type" required="true" type="string">
		<cfargument name="message" required="true" type="string">
		<cfargument name="detail" required="false" type="string" default="">
		
		<cfthrow type="#arguments.type#" message="#arguments.message#" detail="#arguments.detail#" />
	</cffunction>
</cfcomponent>