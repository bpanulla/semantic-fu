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
	</cfscript>
</cfcomponent>