<cfcomponent output="false">
	
	<cfscript>
		variables.model = "";
		variables.loader = "";
		
		public Model function init( any model, any loader=null )
		{
			variables.model = arguments.model;
			variables.loader = arguments.loader;
			
			return this;
		}
		
		public function getSource()
		{
			return variables.model;
		}
		
		public function setSource( any model )
		{
			variables.model = arguments.model;
		}
		
		public function setNsPrefix( String prefix, String uri )
		{
			variables.model.setNsPrefix( arguments.prefix, arguments.uri );
		}
		
		
		/**
		* Data input/output methods
		**/
		public function read( String filepath, String baseUri  )
		{
			var local = {};
			local.source = fileRead( arguments.filepath );
			load( local.source, arguments.baseUri );			
		}
		
		public function write( String filepath, String format )
		{
			fileWrite( arguments.filepath, dump( arguments.format ) );	
		}
		
		public function load( String source, String baseUri  )
		{			
			var local = {};
			local.byteStream = variables.loader.create("java.io.ByteArrayInputStream").init(arguments.source.getBytes());			
			variables.model.read( local.byteStream, arguments.baseUri );	
		}
		
		public String function dump( String format  )
		{			
			var local = {};
			local.byteStream = variables.loader.create("java.io.ByteArrayOutputStream").init();
			variables.model.write( local.byteStream, arguments.format );
			
			return local.byteStream.toString();
		}
		
		
		/**
		* Resource methods
		**/
		public any function getResource( String uri )
		{
			return variables.model.getResource( arguments.uri ); 
		}
		
		public any function createResource( String uri )
		{
			return variables.model.createResource( arguments.uri ); 
		}
		
		public any function removeAll( any subject, any predicate, any object )
		{
			/*
			writeOutput("subject: " & isDefined("arguments.subject") & "<br>" );
			writeOutput("predicate: " & isDefined("arguments.predicate") & "<br>" );
			writeOutput("object: " & isDefined("arguments.object") & "<br>" );
			*/

			variables.model.removeAll(
				( isDefined("arguments.subject") ) ? arguments.subject : JavaCast("null", ""),
				( isDefined("arguments.predicate") ) ? arguments.predicate : JavaCast("null", ""),
			 	( isDefined("arguments.object") ) ? arguments.object : JavaCast("null", "")
			 );
		}
		
		
		/**
		* SPARQL Query methods
		**/
		private function resultSet2Query( any result )
		{
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
		}
		
		public any function query( String query, String returnformat = "query" )
		{
			var local = {};

			local.query = getQueryFactory().create( query );
			
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
						local.returnValue = XmlParse(getResultSetFormatter().asXMLString(result));
						break;
					
					case "pre": // Preformatted text for HTML
						local.returnValue = "<pre>" & HTMLEditFormat(getResultSetFormatter().asText(result, query)) & "</pre>";
						break;
					
					case "text": //raw text
						local.returnValue = getResultSetFormatter().asText(result, query);
						break;
				
					default: // Query Object
						local.returnValue = resultSet2Query(result);
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
						local.returnValue = XmlParse(getResultSetFormatter().asXMLString(result));
						break;
					
					case "pre": // Preformatted text for HTML
					case "text": //raw text
						local.returnValue = result;
						break;
				
					default: // Boolean Object
						local.returnValue = result;
					}
			}
			else
			{
				throw( type="CF_SPARQL", message="Unsupported query type.");
			}

			// Free up resources used running the query
			local.exec.close();
			
			// Pop the query statistics out to the request scope
			request.sparql.executionTime = GetTickCount() - local.tickBegin;
			request.sparql.query = arguments.query;
			
			return local.returnValue;
		}
		
		
		/**
		* Private utility methods
		**/
		private function getQueryFactory()
		{
			if (!isDefined("variables.QueryFactory") )
			{
				variables.QueryFactory = variables.loader.create("com.hp.hpl.jena.query.QueryFactory");
			}
			
			return variables.QueryFactory;
		}

		private function getQueryExecutionFactory()
		{
			if (!isDefined("variables.QueryExecutionFactory") )
			{
				variables.QueryExecutionFactory = variables.loader.create("com.hp.hpl.jena.query.QueryExecutionFactory");
			}
			
			return variables.QueryExecutionFactory;
		}

		private function getResultSetFormatter()
		{
			if (!isDefined("variables.ResultSetFormatter") )
			{
				variables.ResultSetFormatter = variables.loader.create("com.hp.hpl.jena.query.ResultSetFormatter");
			}
			
			return variables.ResultSetFormatter;
		}
	</cfscript>
</cfcomponent>