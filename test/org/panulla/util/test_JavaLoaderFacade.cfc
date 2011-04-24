<!---
Copyright 2010 Brainpan Labs
http://BrainpanLabs.com

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
--->

<cfcomponent extends="mxunit.framework.TestCase">
	
	<cfscript>
		CLASS_UNDER_TEST = "org.panulla.util.JavaLoaderFacade";
		
		TEST_JAVA_CLASS = "java.io.File";
		
		function beforeTests()
		{
		}
		
		function setUp()
		{
			variables.testLoaderClass = createObject("component", CLASS_UNDER_TEST);
		}
		
		function test_init_default()
		{
			var local = {};
			
			// Initialize the loader with no arguments; component instantiates a SimpleClassLoader
			local.testLoader = variables.testLoaderClass.init();
			assertEquals( CLASS_UNDER_TEST, getMetadata(local.testLoader).name );
		}
		
		function test_init_invalid_argument()
		{
			var local = {};
			
			// Initialize the loader an invalid argument
			try
			{
				local.testLoader = variables.testLoaderClass.init( structNew() );
				fail( "Expected exception to be thrown with invalid init arguments, but none was." );
			}
			catch ( any e )
			{
				assertEquals("org.panulla.util.DynamicClassLoader", e.type);
				assertEquals("The dynamicLoader argument passed to the init function is not of type org.panulla.util.DynamicClassLoader.", e.message);	
			}
		}
		
		function test_init_dynamicLoader()
		{
			var local = {};
			// Create a handle on the dynamic loader
			local.dynamicLoader = createObject("component", "org.panulla.util.DynamicClassLoader");
			
			// Initialize the loader with no arguments; component instantiates a SimpleClassLoader
			local.testLoader = variables.testLoaderClass.init( local.dynamicLoader );
			assertEquals( CLASS_UNDER_TEST, getMetadata(local.testLoader).name );
		}

		function test_create_default_loader()
		{
			var local = {};
			
			// Initialize the loader with no arguments; component instantiates a SimpleClassLoader
			local.testLoader = variables.testLoaderClass.init();
			
			// Create an instance of the java File class for the current template
			local.testClass = local.testLoader.create( TEST_JAVA_CLASS ).init( getCurrentTemplatePath() );
			
			assertEquals( TEST_JAVA_CLASS, getMetadata(local.testClass).name );
		}
			
	</cfscript>
	
</cfcomponent>