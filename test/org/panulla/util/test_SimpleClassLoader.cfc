<cfcomponent extends="mxunit.framework.TestCase">
	
	<cfscript>
		TEST_CLASS_NAME = "java.io.File";
		
		function beforeTests()
		{
		}
		
		function setUp()
		{
			// Create a handle to the component under test
			variables.testLoader = createObject("component","org.panulla.util.SimpleClassLoader");
		}

		function test_create()
		{
			var local = {};
			
			// Create an instance of the java File class for the current template
			local.testClass = variables.testLoader.create( TEST_CLASS_NAME ).init( getCurrentTemplatePath() );
			
			assertEquals( TEST_CLASS_NAME, getMetadata(local.testClass).name );
		}
			
	</cfscript>
	
</cfcomponent>