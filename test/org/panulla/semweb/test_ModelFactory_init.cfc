<cfcomponent extends="mxunit.framework.TestCase">

	<cfscript>
		TEST_SIMPLE_MODEL_TYPE = "com.hp.hpl.jena.rdf.model.impl.ModelCom";
		TEST_INFERENCING_MODEL_TYPE = "com.hp.hpl.jena.rdf.model.impl.InfModelImpl";
		TEST_ONTOLOGY_MODEL_TYPE = "com.hp.hpl.jena.ontology.impl.OntModelImpl";
		
		TEST_INFERENCING_LEVEL = "OWL_DL_MEM";
		
		// Create helper objects -- Jena Framework
		variables.modelFactory = createObject("java","com.hp.hpl.jena.rdf.model.ModelFactory");
		variables.modelSpec = createObject("java","com.hp.hpl.jena.ontology.OntModelSpec");
		
		TEST_JENA_INFERENCE_LEVELS = {
					transitive = "com.hp.hpl.jena.reasoner.transitiveReasoner.TransitiveReasoner",
					rdfs_simple = "com.hp.hpl.jena.reasoner.rulesys.RDFSRuleReasoner",
					rdfs = "com.hp.hpl.jena.reasoner.rulesys.RDFSRuleReasoner",
					owl_micro = "com.hp.hpl.jena.reasoner.rulesys.OWLMicroReasoner",
					owl_mini = "com.hp.hpl.jena.reasoner.rulesys.OWLMiniReasoner",
					owl = "com.hp.hpl.jena.reasoner.rulesys.OWLFBRuleReasoner"
			};
		
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

		function test_getInferredModel()
		{
			var local = {};
			local.modelFactory = variables.testModelFactory.init();
			
			// Default model type
			local.model = local.modelFactory.getInferredModel();
			local.actual = local.model.getSource();
			assertEquals( TEST_INFERENCING_MODEL_TYPE, getMetadata(local.actual).name );
			assertEquals( TEST_JENA_INFERENCE_LEVELS['owl'], getMetadata(local.actual.getReasoner()).name );
			
			// Supported inferencing levels
			for ( local.level in TEST_JENA_INFERENCE_LEVELS )
			{
				local.model = local.modelFactory.getInferredModel( local.level );
				local.actual = local.model.getSource();
				assertEquals( TEST_INFERENCING_MODEL_TYPE, getMetadata(local.actual).name );
				
				assertEquals( TEST_JENA_INFERENCE_LEVELS[local.level], getMetadata(local.actual.getReasoner()).name );
			}
			
			// Unknown inferencing type
			local.inferencing = "magic";
			try
			{
				local.model = local.modelFactory.getInferredModel( local.inferencing );
				fail( "Expected exception to be thrown with invalid arguments, but none was." );
			}
			catch ( ModelFactory e )
			{
				assertEquals("Unknown reasoner 'magic'", e.message);	
				assertEquals("The requested reasoning profile does not exist in the current reasoner registry configuration.", e.detail);	
			}
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