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
		TEST_PERSISTENT_MODEL_TYPE = "com.hp.hpl.jena.db.ModelRDB";
		
		TEST_PERSISTENT_MODEL_DATASOURCE = "SemanticFuTest";
		TEST_PERSISTENT_MODEL_DATASOURCE_BAD = "NonExistentDatasource";
		TEST_PERSISTENT_MODEL_DATASOURCE_NO_MODEL = "cfartgallery";
		TEST_PERSISTENT_MODEL_NAME = "UnitTesting";
		TEST_PERSISTENT_MODEL_DBTYPE = "Derby";
		TEST_PERSISTENT_MODEL_DBLOCATION = getTempDirectory() & TEST_PERSISTENT_MODEL_NAME;
		
		// Create helper objects -- Jena Framework
		variables.modelFactory = createObject("java","com.hp.hpl.jena.rdf.model.ModelFactory");
		
		function beforeTests()
		{
		}
		
		function setUp()
		{
			// Create a handle to the component under test
			variables.testModelFactory = createObject("component","org.panulla.semweb.ModelFactory");

			activateCFAdminAPI();
			createTestDerbyDatasource( TEST_PERSISTENT_MODEL_DATASOURCE, TEST_PERSISTENT_MODEL_DBLOCATION, true );
		}

		function tearDown()
		{
			activateCFAdminAPI();
			destroyTestDerbyDatasource( TEST_PERSISTENT_MODEL_DATASOURCE, TEST_PERSISTENT_MODEL_DBLOCATION );
		}			
		
		function test_getPersistentModel_bad_datasource()
		{
			var local = {};
			local.modelFactory = variables.testModelFactory.init();
			
			// Datasource should not exist
			local.dsnNotFoundMessage = "Datasource #TEST_PERSISTENT_MODEL_DATASOURCE_BAD# could not be found.";
			
			try
			{
				local.model = local.modelFactory.getPersistentModel(
												TEST_PERSISTENT_MODEL_DATASOURCE_BAD,
												TEST_PERSISTENT_MODEL_NAME,
												TEST_PERSISTENT_MODEL_DBTYPE,
												false);

				fail( "getPersistentModel() should have failed with non-existent datasource '#TEST_PERSISTENT_MODEL_DATASOURCE_BAD#' but it didn't" );
			}
			catch ( Database e )
			{
				assertEquals( local.dsnNotFoundMessage, left( e.message, len(local.dsnNotFoundMessage) ) );	
			}
		}
		
		
		function test_getPersistentModel_with_and_without_autocreate()
		{
			var local = {};
			local.modelFactory = variables.testModelFactory.init();
			
			// If the test datasource doesn't exist go ahead and create it
			debug(createTestDerbyDatasource( TEST_PERSISTENT_MODEL_DATASOURCE, TEST_PERSISTENT_MODEL_DBLOCATION )); 
			
			try
			{
				local.model = local.modelFactory.getPersistentModel(
												TEST_PERSISTENT_MODEL_DATASOURCE_NO_MODEL,
												TEST_PERSISTENT_MODEL_NAME,
												TEST_PERSISTENT_MODEL_DBTYPE,
												false);

				fail( "getPersistentModel() should have failed with without autocreate on bad model name but it didn't" );
			}
			catch ( ModelFactory e )
			{
				assertEquals( "Requested model does not exist.", e.message );	
			}
			
			// Try again, this time allowing autocreation of model.
			local.model = local.modelFactory.getPersistentModel(
							TEST_PERSISTENT_MODEL_DATASOURCE,
							TEST_PERSISTENT_MODEL_NAME,
							TEST_PERSISTENT_MODEL_DBTYPE,
							true);
			
			// Verify model type
			assertEquals( TEST_PERSISTENT_MODEL_TYPE, getMetadata(local.model.getSource()).name );
		}
	</cfscript>
	
	
	
	<!--- ============================================================ 
		Private utility methods	
	 ============================================================ --->
	
	
	<cffunction name="activateCFAdminAPI" access="private" output="false">
		<cfscript>
			var local = {};
	
			// Look for CFAdmin credentials in the current directory and log us in to the API
			local.credsFile = getDirectoryFromPath( getCurrentTemplatePath() ) & "../../../cfadmin.txt";
			
			if (fileExists( local.credsFile ))
			{
				try
				{
					local.credsText = fileRead( local.credsFile );
					local.adminuser = listGetAt( local.credsText, 1, ":");
					local.adminpass = listGetAt( local.credsText, 2, ":");
					
					local.adminAPI = CreateObject("component", "cfide.adminapi.administrator");
					
					if ( local.adminAPI.login( local.adminpass ) or
							local.adminAPI.login( local.adminuser, local.adminpass ) )
					{
						return true;
					}
					else
					{
						throwException("Admin API", "CFAdmin API support not enabled: Bad credentials");
					}
				}
				catch ( Expression e )
				{
					throwException("Admin API", "CFAdmin API support not enabled: Unable to parse credentials from file: '#local.credsFile#'");
				}
			}
			else
			{
				throwException("Admin API", "CFAdmin API support not enabled: No credentials file at '#local.credsFile#'");
			}
		</cfscript>
	</cffunction>
	
	
	<cffunction name="createTestDerbyDatasource" access="private" output="false" returntype="boolean">
		<cfargument name="datasource" type="string" required="true" />
		<cfargument name="location" type="string" required="true" />
		<cfargument name="create" type="boolean" required="false" default="true" />

		<cfscript>
			var local = {};
			
			local.dsnMgr = CreateObject("component", "cfide.adminapi.datasource");
			
			local.dsnMgr.setDerbyEmbedded(
					name=arguments.datasource,
					database=arguments.location,
					isnewdb=arguments.create
			);

			return local.dsnMgr.verifyDsn(arguments.datasource, true);
		</cfscript>
	</cffunction>
	
	
	<cffunction name="destroyTestDerbyDatasource" access="private" output="false">
		<cfargument name="datasource" type="string" required="true" />
		<cfargument name="location" type="string" required="true" />
		
		<cfscript>
			var local = {};
			
			local.dsnMgr = CreateObject("component", "cfide.adminapi.datasource");
			
			if ( local.dsnMgr.verifyDsn( arguments.datasource ) )
			{
				local.dsnMgr.deleteDatasource( arguments.datasource );
				deleteFolderFromTemp(arguments.location, true);
			}
		</cfscript>
	</cffunction>
	
	
	<!--- Methods for CF8 compatibility --->
	<cffunction name="throwException" access="private" hint="Wraps CFTHROW in a function" output="false" returntype="void">
		<cfargument name="type" required="true" type="string">
		<cfargument name="message" required="true" type="string">
		<cfargument name="detail" required="false" type="string" default="">
		
		<cfthrow type="#arguments.type#" message="#arguments.message#" detail="#arguments.detail#" />
	</cffunction>
	
	
	<cffunction name="deleteFolderFromTemp" access="private" hint="Wraps CFDIRECTORY delete option in a function" output="false" returntype="void">
		<cfargument name="path" type="string" required="true" />
		<cfargument name="recurse" type="boolean" required="false" default="false">
		
		<cfset var local = {} />
		<cfset local.tempDirectory = getTempDirectory() />
		
		<cfif left( arguments.path, len(local.tempDirectory)) neq local.tempDirectory>
			<cfthrow type="File" message="Directory to be deleted is not in temp folder.">
		<cfelseif fileExists( arguments.path )>
			<cfdirectory action="delete" directory="#arguments.path#" recurse="#arguments.recurse#" />
		</cfif>
			
	</cffunction>

</cfcomponent>