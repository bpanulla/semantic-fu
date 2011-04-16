﻿<cfcomponent>

	<cfscript>
		// ColdFusion Service API
		variables.dsServiceFactory = CreateObject("java", "coldfusion.server.ServiceFactory").getDataSourceService();
		
		variables.loader = CreateObject("component", "org.panulla.util.DefaultClassLoader");
		
		function $( classname ) { return variables.loader.create( arguments.classname ); };
	</cfscript>
	
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
			
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="wrapModel" access="private" output="false" returntype="org.panulla.semweb.Model">
		<cfargument name="model" type="any" required="true" />
		
		<cfreturn createObject("component", "org.panulla.semweb.Model").init( arguments.model, variables.loader ) />		
	</cffunction>


	<cffunction name="getModel" access="public" returntype="org.panulla.semweb.Model" output="false">
		<cfreturn wrapModel( variables.modelFactory.createDefaultModel() )  />
	</cffunction>
	
	
	<cffunction name="getPersistentModel" access="public" returntype="org.panulla.semweb.Model" output="false">
		<cfargument name="datasource" type="string" required="true" />
		<cfargument name="name" type="string" required="false" />
		<cfargument name="dbtype" type="string" required="false" default="MySQL" />
		<cfargument name="createOnNew" type="boolean" default="false" />
		
		<cfscript>
			var local = {};
			
			// Get a handle to a CF datasource - http://www.petefreitag.com/item/152.cfm
			local.myConn = variables.dsServiceFactory.getDatasource(arguments.datasource).getConnection();
			
			 // Create a Jena IDBConnection - http://jena.sourceforge.net/javadoc/com/hp/hpl/jena/db/DBConnection.html
			local.jenaConn = variables.loader.create("com.hp.hpl.jena.db.DBConnection").init(local.myConn, arguments.dbtype);
			
			if ( local.jenaConn.containsModel(arguments.name) )
			{
				local.model = variables.dbModelLocator.open(local.jenaConn, arguments.name);
			}
			else if ( arguments.createOnNew )
			{
				local.model = variables.dbModelLocator.createModel(local.jenaConn, arguments.name);
			}
			else
			{
				throwException( "Requested model does not exist.", "ModelFactory", "Model '#arguments.name#' does not exist in datasource '#arguments.datasource#'. Create the model, or set createOnNew to true to create automatically." );
			}

			return wrapModel( local.model );
		</cfscript>
	</cffunction>


	<cffunction name="getReasoningModel" access="public" returntype="org.panulla.semweb.Model" output="false">
		<cfargument name="inferencing" type="string" required="true" hint="Level of inferencing supported by model." default="OWL_DL_MEM" />
		<cfargument name="model" type="any" required="false" default="#getModel()#" />
		
		<cfscript>
			var local = {};
			
			// Create a Pellet reasoner
			local.baseReasoner = variables.reasonerFactory.theInstance().create();
			
			// Extract the source model object from the wrapper passed to the method
			local.infModel = variables.modelFactory.createInfModel( local.baseReasoner, arguments.model.getSource());
			
			// Re-inject the resoner model into the model wrapper
			arguments.model.setSource( variables.modelFactory.createOntologyModel(variables.modelSpec[arguments.inferencing], local.infModel) );
			
			return arguments.model;
		</cfscript>
	</cffunction>


	<cffunction name="throwException" access="private" hint="Wraps CFTHROW in a function" output="false" returntype="void">
		<cfargument name="type" required="true" type="string">
		<cfargument name="message" required="true" type="string">
		<cfargument name="detail" required="false" type="string" default="">
		
		<cfthrow type="#arguments.type#" message="#arguments.message#" detail="#arguments.detail#" />
	</cffunction>
</cfcomponent>