﻿<!---
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

<cfcomponent output="false" hint="A simple Java class loader. Wraps native ColdFusion class loading functionality">
	
	<cffunction name="create" access="public" output="false" returntype="any">
		<cfargument name="classname" type="string" required="true" />
		
		<cfreturn createObject("java", arguments.classname) />
	</cffunction>

</cfcomponent>