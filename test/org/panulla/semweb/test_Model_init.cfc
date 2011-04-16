<cfcomponent extends="mxunit.framework.TestCase">

	<cfscript>
		TEST_SIMPLE_MODEL_TYPE = "com.hp.hpl.jena.rdf.model.impl.ModelCom";
		TEST_PERSISTENT_MODEL_TYPE = "com.hp.hpl.jena.db.ModelRDB";
		TEST_INFERENCING_MODEL_TYPE = "com.hp.hpl.jena.rdf.model.impl.InfModelImpl";
		TEST_ONTOLOGY_MODEL_TYPE = "com.hp.hpl.jena.ontology.impl.OntModelImpl";
		
		TEST_INFERENCING_LEVEL = "OWL_DL_MEM";
		
		TEST_NS_DEFAULT_URI = "http://linkeddata.org/";
		TEST_NS_RDF = "rdf";
		TEST_NS_RDF_URI = "http://www.w3.org/1999/02/22-rdf-syntax-ns##";
		
		// Create helper objects -- Jena Framework
		variables.modelFactory = createObject("java","com.hp.hpl.jena.rdf.model.ModelFactory");
		variables.modelSpec = createObject("java","com.hp.hpl.jena.ontology.OntModelSpec");
		
		function beforeTests()
		{
			// Basic Jena model
			variables.testDefaultModel = variables.modelFactory.createDefaultModel();

			// Jena model with built-in OWL reasoner
			variables.reasonerRegistry = createObject("java", "com.hp.hpl.jena.reasoner.ReasonerRegistry");
			variables.testInfModel = variables.modelFactory.createInfModel(
										variables.reasonerRegistry.getOWLReasoner(),
										variables.modelFactory.createDefaultModel()
									);
			
			// Jena model with Pellet reasoner
			variables.pelletFactory = createObject("java", "org.mindswap.pellet.jena.PelletReasonerFactory");
			variables.testPelletModel = variables.modelFactory.createOntologyModel(
											variables.modelSpec[TEST_INFERENCING_LEVEL],
											variables.modelFactory.createInfModel(
													variables.pelletFactory.theInstance().create(),
													variables.modelFactory.createDefaultModel()
												)
										);
		}
		
		function setUp()
		{
			// Create a handle to the component under test
			variables.testModel = createObject("component","org.panulla.semweb.Model");
		}

		function test_init_default_no_model()
		{
			var local = {};
			
			try
			{
				local.model = variables.testModel.init();
				fail( "Expected exception to be thrown with invalid init arguments, but none was." );
			}
			catch ( Application e )
			{
				assertEquals("The MODEL parameter to the init function is required but was not passed in.", e.message);	
			}
		}

		function test_init_default_invalid_model()
		{
			var local = {};
			
			try
			{
				local.model = variables.testModel.init("");
				fail( "Expected exception to be thrown with invalid init arguments, but none was." );
			}
			catch ( Model e )
			{
				assertEquals("Invalid model type", e.message);	
				assertEquals("Instance of type 'java.lang.String' passed to setSource() method is not a known model type.", e.detail);	
			}
		}

		function test_init_simple_model()
		{
			var local = {};
			local.expected = variables.testDefaultModel;
			local.model = variables.testModel.init(local.expected);
			
			// Verify model and loader type
			assertEquals( local.expected, local.model.getSource() );
			assertEquals( "org.panulla.util.JavaLoaderFacade",
							getMetadata(local.model.getLoader()).name);
		}

		function test_init_inferencing_model()
		{
			var local = {};
			local.expected = variables.testInfModel;
			local.model = variables.testModel.init(local.expected);
			
			// Verify model and loader type
			assertEquals( local.expected, local.model.getSource() );
			assertEquals( "org.panulla.util.JavaLoaderFacade",
							getMetadata(local.model.getLoader()).name);
		}
		
		function test_init_pellet_model()
		{
			var local = {};
			local.expected = variables.testPelletModel;
			local.model = variables.testModel.init(local.expected);
			
			// Verify model and loader type
			assertEquals( local.expected, local.model.getSource() );
			assertEquals( "org.panulla.util.JavaLoaderFacade",
							getMetadata(local.model.getLoader()).name);
		}
		
		function test_init_invalid_loader()
		{
			var local = {};
			
			try
			{
				local.model = variables.testModel.init(variables.testDefaultModel, "");
				fail( "Expected exception to be thrown with invalid init arguments, but none was." );
			}
			catch ( any e )
			{
				assertEquals("org.panulla.util.JavaLoaderFacade", e.type);	
				assertEquals("The loader argument passed to the init function is not of type org.panulla.util.JavaLoaderFacade.", e.message);	
			}
		}
		
		function test_init_simple_model_and_loader()
		{
			var local = {};
			local.expectedModel = variables.testDefaultModel;
			local.expectedLoader = createObject("component", "org.panulla.util.JavaLoaderFacade");
			
			local.model = variables.testModel.init( local.expectedModel, local.expectedLoader);
			
			// Verify model and loader type
			assertEquals( local.expectedModel, local.model.getSource() );
			assertEquals( "org.panulla.util.JavaLoaderFacade",
							getMetadata(local.model.getLoader()).name);
		}
		
		function test_setSource()
		{
			var local = {};
			local.model = variables.testModel.init( variables.testDefaultModel );
			
			// Verify default model
			assertEquals( variables.testDefaultModel, local.model.getSource() );
			
			// Inject a different model via setSource()
			local.model.setSource( variables.testInfModel );
			assertEquals( variables.testInfModel, local.model.getSource() );
		}
		
		function test_setLoader()
		{
			var local = {};

			// Create a loader
			local.expectedLoader = createObject("component", "org.panulla.util.JavaLoaderFacade").init();
			
			// Instantiate a model with the default loader
			local.model = variables.testModel.init( variables.testDefaultModel );
			
			// Verify default loader is different from the one we created
			assertEquals( local.expectedLoader, local.model.getLoader() );
			
			// Inject a different model via setLoader()
			local.model.setLoader( local.expectedLoader );
			assertEquals( local.expectedLoader, local.model.getLoader() );
		}		
		
		function test_setNSPrefix()
		{
			var local = {};
			local.expected = variables.testDefaultModel;
			
			// Verify that raw Jena model currently has no namespaces defined
			local.initialPrefixes = local.expected.getNsPrefixMap();
			
			assertEquals( 0, local.initialPrefixes.size() );
			
			// Configure the Model CFC and add a couple of namespaces
			local.model = variables.testModel.init(local.expected)
							.setNSPrefix("", TEST_NS_DEFAULT_URI)
							.setNSPrefix(TEST_NS_RDF, TEST_NS_RDF_URI);
			
			// Verify model and loader type
			local.actual = local.model.getSource();
			assertEquals( 2, local.actual.getNsPrefixMap().size() );
			assertEquals( TEST_NS_DEFAULT_URI, local.actual.getNsPrefixURI(""));
			assertEquals( "", local.actual.getNsURIPrefix(TEST_NS_DEFAULT_URI));
			assertEquals( TEST_NS_RDF_URI, local.actual.getNsPrefixURI(TEST_NS_RDF));
			assertEquals( TEST_NS_RDF, local.actual.getNsURIPrefix(TEST_NS_RDF_URI));
		}
	</cfscript>

</cfcomponent>