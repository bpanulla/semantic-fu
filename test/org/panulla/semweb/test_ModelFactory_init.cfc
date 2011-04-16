<cfcomponent extends="mxunit.framework.TestCase">

	<cfscript>
		TEST_SIMPLE_MODEL_TYPE = "com.hp.hpl.jena.rdf.model.impl.ModelCom";
		TEST_PERSISTENT_MODEL_TYPE = "com.hp.hpl.jena.db.ModelRDB";
		TEST_INFERENCING_MODEL_TYPE = "com.hp.hpl.jena.rdf.model.impl.InfModelImpl";
		TEST_ONTOLOGY_MODEL_TYPE = "com.hp.hpl.jena.ontology.impl.OntModelImpl";
		
		TEST_INFERENCING_LEVEL = "OWL_DL_MEM";
		
		// Create helper objects -- Jena Framework
		variables.modelFactory = createObject("java","com.hp.hpl.jena.rdf.model.ModelFactory");
		variables.modelSpec = createObject("java","com.hp.hpl.jena.ontology.OntModelSpec");
		
		function beforeTests()
		{
		}
		
		function setUp()
		{
			// Create a handle to the component under test
			variables.testModelFactory = createObject("component","org.panulla.semweb.ModelFactory");
		}

		function test_init_default()
		{
			var local = {};
			
			local.modelFactory = variables.testModelFactory.init();
			assertEquals("org.panulla.semweb.ModelFactory", getMetadata(local.modelFactory).name);	
		}
		
		function test_init_invalid_loader()
		{
			var local = {};
			
			try
			{
				local.modelFactory = variables.testModelFactory.init( "" );
				fail( "Expected exception to be thrown with invalid init arguments, but none was." );
			}
			catch ( any e )
			{
				assertEquals("org.panulla.util.JavaLoaderFacade", e.type);	
				assertEquals("The loader argument passed to the init function is not of type org.panulla.util.JavaLoaderFacade.", e.message);	
			}
		}
		
		function test_init_simple_loader()
		{
			var local = {};
			local.expectedLoader = createObject("component", "org.panulla.util.JavaLoaderFacade");
			
			local.modelFactory = variables.testModelFactory.init( local.expectedLoader );
			
			// Verify model factory
			assertEquals("org.panulla.semweb.ModelFactory", getMetadata(local.modelFactory).name);
		}
		
		
		function test_getModel()
		{
			var local = {};
			local.modelFactory = variables.testModelFactory.init();
			
			// Verify model type
			local.model = local.modelFactory.getModel();
			assertEquals( TEST_SIMPLE_MODEL_TYPE, getMetadata(local.model.getSource()).name );
		}

		function test_getInferencingModel()
		{
			fail("Not implemented");
		}
		
		function test_getReasoningModel()
		{
			var local = {};
			local.modelFactory = variables.testModelFactory.init();
			
			// Verify model type
			local.model = local.modelFactory.getReasoningModel( TEST_INFERENCING_LEVEL );
			assertEquals( TEST_ONTOLOGY_MODEL_TYPE, getMetadata(local.model.getSource()).name );
		}
	</cfscript>

</cfcomponent>