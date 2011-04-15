<cfcomponent>

	<cfscript>
		// ColdFusion Service API
		variables.dsServiceFactory = CreateObject("java", "coldfusion.server.ServiceFactory").getDataSourceService();
		
		variables.loader = CreateObject("component", "org.panulla.util.DefaultClassLoader");
		
		private function $( String classname ) { return variables.loader.create( classname ); };
	</cfscript>
	
	
	<cffunction name="dump" access="private" hint="Wraps CFDUMP in a function" output="true" returntype="void">
		<cfargument name="var" required="true" type="any">
		<cfargument name="expand" required="false" type="boolean" default="false">
		<cfargument name="abort" required="false" type="boolean" default="false">
		
		<cfdump var="#arguments.var#" expand="#arguments.expand#" format="html" abort="#arguments.abort#">
	</cffunction>
	
	
	<cffunction name="throwException" access="private" hint="Wraps CFTHROW in a function" output="false" returntype="void">
		<cfargument name="type" required="true" type="string">
		<cfargument name="message" required="true" type="string">
		<cfargument name="detail" required="false" type="string" default="">
		
		<cfthrow type="#arguments.type#" message="#arguments.message#" detail="#arguments.detail#" />
	</cffunction>
	
	
	<cffunction name="init" access="public" hint="Constructor" returntype="ModelFactory" output="false">
		<cfargument name="loader" type="JavaLoaderFacade" required="false">
		
		<cfscript>
			if (isDefined("arguments.loader") and isObject(arguments.loader))
			{
				variables.loader = arguments.loader;
			}

			// Create helper objects -- Jena Framework
			variables.modelFactory = $("com.hp.hpl.jena.rdf.model.ModelFactory");
			variables.dbModelLocator = $("com.hp.hpl.jena.db.ModelRDB");
			variables.modelSpec = $("com.hp.hpl.jena.ontology.OntModelSpec");
			
			// Pellet Reasoner
			variables.reasonerFactory = $("org.mindswap.pellet.jena.PelletReasonerFactory");
		</cfscript>
	
		<cfreturn this>
	</cffunction>

	<cffunction name="wrapModel" access="private" output="false" returntype="org.panulla.semweb.Model">
		<cfargument name="model" type="any" required="true" />
		
		<cfset var modelClass = GetMetaData(arguments.model).getCanonicalName() />
		
		<cfif NOT listFind( variables.jenaModelClasses, modelClass )>
			<cfthrow type="ModelFactory" message="Unknown model type '#modelClass#'" />
		<cfelse>
			<cfreturn createObject("component", "org.panulla.semweb.Model").init( arguments.model, variables.loader ) />
		</cfif>
	</cffunction>


	<cffunction name="getModel" access="public" returntype="org.panulla.semweb.Model" output="false">
		<cfreturn wrapModel( variables.modelFactory.createDefaultModel() )  />
	</cffunction>
	
	
	<cffunction name="getPersistentModel" access="public" returntype="org.panulla.semweb.Model" output="false">
		<cfargument name="datasource" type="string" required="true" />
		<cfargument name="name" type="string" required="false" />
		<cfargument name="dbtype" type="string" required="false" default="MySQL" />
		<cfargument name="createOnNew" type="boolean" default="false" />
		
		<cfset var local = structNew() />
			
		<!--- Get a handle to a CF datasource - http://www.petefreitag.com/item/152.cfm--->
		<cfset local.myConn = variables.dsServiceFactory.getDatasource(arguments.datasource).getConnection() />
			
		<!---Create a Jena IDBConnection - http://jena.sourceforge.net/javadoc/com/hp/hpl/jena/db/DBConnection.html--->
		<cfset local.jenaConn = $("com.hp.hpl.jena.db.DBConnection").init(local.myConn, arguments.dbtype) />
			
		<cfif local.jenaConn.containsModel(arguments.name)>
			<cfset local.model = variables.dbModelLocator.open(local.jenaConn, arguments.name) />
		<cfelseif arguments.createOnNew>
			<cfset local.model = variables.dbModelLocator.createModel(local.jenaConn, arguments.name) />
		<cfelse>
			<cfthrow message="Requested model does not exist." type="ModelFactory"
					 detail="Model '#arguments.name#' does not exist in datasource '#arguments.datasource#'. Create the model, or set createOnNew to true to create automatically.">
		</cfif>

		<cfreturn wrapModel( local.model ) />
	</cffunction>


	<cffunction name="getReasoningModel" access="public" returntype="org.panulla.semweb.Model" output="false">
		<cfargument name="inferencing" type="string" required="true" hint="Level of inferencing supported by model." default="OWL_DL_MEM" />
		<cfargument name="model" type="any" required="false" default="#getModel()#" />
		
		<cfscript>
			var local = structNew();
			
			// Create a Pellet reasoner
			local.baseReasoner = variables.reasonerFactory.theInstance().create();
			
			// Extract the source model object from the wrapper passed to the method
			local.infModel = variables.modelFactory.createInfModel( local.baseReasoner, arguments.model.getSource());
			
			// Re-inject the resoner model into the model wrapper
			arguments.model.setSource( variables.modelFactory.createOntologyModel(variables.modelSpec[arguments.inferencing], local.infModel) );
		</cfscript>
	
		<cfreturn arguments.model />
	</cffunction>
	
	
	<cffunction name="getStardogModel" access="public" returntype="org.panulla.semweb.Model" output="false">
		<cfargument name="name" type="string" required="true" hint="Name model server to connect to." />
		
		<cfscript>
			var local = {};
			local.conn = $("com.clarkparsia.stardog.api.ConnectionConfiguration")
								.to( arguments.name )	// the name of the db to connect to
								.createIfNotPresent()	// create the db if it does not exist -- this creates a temporary, non-persistent memory db
								.connect(); 			// now open the connection

			// obtain a jena for the specified stardog database.
			local.model = $("com.clarkparsia.stardog.jena.SDJenaFactory").createModel( local.conn );
		</cfscript>
	
		<cfreturn wrapModel( local.model ) />
	</cffunction>

	<cffunction name="getStardogServerModel" access="public" returntype="org.panulla.semweb.Model" output="false">
		<cfargument name="url" type="string" required="true" hint="URL of the server to connect to." />
		
		<cfscript>
			var local = {};
			local.conn = $("com.clarkparsia.stardog.api.ConnectionConfiguration").at( arguments.url );

			// obtain a jena for the specified stardog database.
			local.model = $("com.clarkparsia.stardog.jena.SDJenaFactory").createModel( local.conn );
		</cfscript>
	
		<cfreturn wrapModel( local.model ) />
	</cffunction>
	
</cfcomponent>