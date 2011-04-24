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