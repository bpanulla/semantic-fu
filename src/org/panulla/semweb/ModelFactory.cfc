<cfcomponent>

	<cfscript>
		// ColdFusion Service API
		variables.dsServiceFactory = CreateObject("java", "coldfusion.server.ServiceFactory").getDataSourceService();
		
		variables.loader = CreateObject("component", "org.panulla.semweb.DefaultClassLoader");
	</cfscript>
	
	
	<cffunction name="dump" access="private" hint="Wraps CFDUMP in a function" output="true" returntype="void">
		<cfargument name="var" required="true" type="any">
		<cfargument name="expand" required="false" type="boolean" default="false">
		<cfargument name="abort" required="false" type="boolean" default="false">
		
		<cfdump var="#arguments.var#" expand="#arguments.expand#" format="html" abort="#arguments.abort#">
	</cffunction>
	
	
	<cffunction name="init" access="public" hint="Constructor" returntype="ModelFactory" output="false">
		<cfargument name="loader" type="javaloader.JavaLoader">
		
		<cfscript>
			this.loader =  variables.loader; //arguments.loader;

			// Create helper objects -- Jena Framework
			variables.modelFactory = this.loader.create("com.hp.hpl.jena.rdf.model.ModelFactory");
			variables.dbModelLocator = this.loader.create("com.hp.hpl.jena.db.ModelRDB");
			variables.modelSpec = this.loader.create("com.hp.hpl.jena.ontology.OntModelSpec");
			
			// Pellet Reasoner
			variables.reasonerFactory = this.loader.create("org.mindswap.pellet.jena.PelletReasonerFactory");
		</cfscript>
	
		<cfreturn this>
	</cffunction>


	<cffunction name="getModel" access="public" returntype="any" output="false">
		<cfreturn variables.modelFactory.createDefaultModel() />
	</cffunction>
	
	
	<cffunction name="getPersistentModel" access="public" returntype="any" output="false">
		<cfargument name="datasource" type="string" required="true" />
		<cfargument name="name" type="string" required="false" />
		<cfargument name="dbtype" type="string" required="false" default="MySQL" />
		<cfargument name="createOnNew" type="boolean" default="false" />
		
		<cfscript>
			var local = structNew();
			
			// Get a handle to a CF datasource - http://www.petefreitag.com/item/152.cfm
			local.myConn = variables.dsServiceFactory.getDatasource(arguments.datasource).getConnection();
			
			// Create a Jena IDBConnection - http://jena.sourceforge.net/javadoc/com/hp/hpl/jena/db/DBConnection.html
			local.jenaConn = this.loader.create("com.hp.hpl.jena.db.DBConnection").init(local.myConn, arguments.dbtype);
			
			if (local.jenaConn.containsModel(arguments.name))
			{
				local.model = variables.dbModelLocator.open(local.jenaConn, arguments.name);
			}
			else if (arguments.createOnNew)
			{
				local.model = variables.dbModelLocator.createModel(local.jenaConn, arguments.name);
			}
			else
			{
				throw("Requested model does not exist.", "Jena Model", "Model '"& arguments.name &"' does not exist in datasource '"& arguments.datasource &"'. Create the model, or set createOnNew to true to create automatically.");
			}		
		</cfscript>
	
		<cfreturn local.model />
	</cffunction>


	<cffunction name="getReasoningModel" access="public" returntype="Any" output="false">
		<cfargument name="inferencing" type="string" required="true" hint="Level of inferencing supported by model." default="OWL_DL_MEM" />
		<cfargument name="model" type="any" required="false" default="#getModel()#" />
		
		<cfscript>
			var local = structNew();
			
			local.baseReasoner = variables.reasonerFactory.theInstance().create();
			local.infModel = variables.modelFactory.createInfModel( local.baseReasoner, arguments.model);
			
			local.model = variables.modelFactory.createOntologyModel(variables.modelSpec[arguments.inferencing], local.infModel);
		</cfscript>
	
		<cfreturn local.model />
	</cffunction>
</cfcomponent>