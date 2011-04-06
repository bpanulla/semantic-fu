<cfcomponent hint="ColdFusion representation of an RDF model" output="false">
	
	<cffunction name="init" description="constructor" hint="constructor" access="public" output="false" returntype="Model">
		<cfargument name="rdf" type="any" hint="String (uri) or xml" required="false" />
		<cfargument name="prefixes" type="struct" hint="Namespace prefixes" required="false">
		<cfargument name="type" type="string" hint="String (uri) or xml" required="false" />
		
		<cfset var javaString = false>
		<cfset var stream = false>
		<cfset var pp = '' />
		<cfset var input = "">
		
		<cfset variables.model = createObject("java", "com.hp.hpl.jena.rdf.model.ModelFactory").createDefaultModel()>
		<cfif structKeyExists(arguments,"prefixes")>
			<cfloop collection="#arguments.prefixes#" item="pp">
				<cfset variables.model.setNsPrefix(lcase(pp),arguments.prefixes[pp])>
			</cfloop>
		</cfif>
		
		<cfif not structKeyExists(arguments,"type")>
			<cfif structKeyExists(arguments,"rdf") and len(arguments.rdf)>
				<cfif isValid("URL",arguments.rdf)>
					<cfset input = "uri">
				<cfelseif isXml(arguments.rdf)>
					<cfset input = "rdf/xml">
				</cfif>
			<cfelse>
				<cfset input = "none">
			</cfif>
		<cfelse>
			<cfset input = arguments.type>
		</cfif>
		
		<cfswitch expression="#input#">
			<cfcase value = "uri">
				<cfset variables.model.read(arguments.rdf)>
			</cfcase>
			
			<cfcase value= "rdf/xml">
				<cfset javaString = createObject("java", "java.lang.String").init(toString(arguments.rdf))>
				<cfset stream = createObject("java", "java.io.ByteArrayInputStream").init(javaString.getBytes())>
				<cfset variables.model.read(stream, "")>
			</cfcase>
			
			<cfcase value = "rdf">
			
			</cfcase>
			
			<cfcase value = "turtle">
				<cfset javaString = createObject("java", "java.lang.String").init(toString(arguments.rdf))>
				<cfset stream = createObject("java", "java.io.ByteArrayInputStream").init(javaString.getBytes())>
				<cfset variables.model.read(stream, javaCast("null",""), "TURTLE")>	
			</cfcase>
			
			<cfdefaultcase>
			
			</cfdefaultcase>
		</cfswitch>
		
		
		<cfreturn this>
	</cffunction>

	<cffunction name="asQuery" description="return the model as triples" hint="return the model as triples (s, p, o)" access="public" output="false" returntype="query">
		<cfargument name="markup" hint="markup for inserts" type="boolean" required="false" />
		<cfset var iterator = variables.model.listStatements()>
		<cfset var resultset = queryNew("s,p,o")>
		<cfset var statement = false>
		<cfloop condition="iterator.hasNext()">
			<cfset statement = iterator.nextStatement()>
			<cfset queryAddRow(resultset,1)>
			
			<cfif structKeyExists(arguments,"markup") and arguments.markup>
				<cfset querySetCell(resultset, "s", "<" & trim(statement.getSubject().getURI()) & ">")>
				<cfset querySetCell(resultset, "p", "<" & trim(statement.getPredicate().getURI()) & ">")>
				<cfif statement.getObject().isLiteral()>
					<cfset querySetCell(resultset, "o", """" & xmlFormat(reReplaceNoCase(trim(statement.getObject().toString()),"\n","","all")) & """")>
				<cfelse>
					<cfset querySetCell(resultset, "o", "<" & trim(statement.getObject().toString()) & ">")>
				</cfif>
			<cfelse>
				<cfset querySetCell(resultset, "s",  statement.getSubject().getURI() )>
				<cfset querySetCell(resultset, "p",  statement.getPredicate().getURI() )>
				<cfset querySetCell(resultset, "o", statement.getObject().toString())>
			</cfif>
		</cfloop>
		<cfreturn resultset>
	</cffunction>
	
	<cffunction name="asJava" displayname="toJava" description="return a java (jena) model" hint="return a java (jena) model" access="public" output="false" returntype="any">
		<cfreturn variables.model>
	</cffunction>

	<cffunction name="toJava" displayname="toJava" description="set the java (jena) model" hint="set the java (jena) model" access="public" output="false" returntype="void">
		<cfargument name="model" type="any" required="true" hint="jena model">
		<cfset variables.model = arguments.model>
	</cffunction>

	<cffunction name="asString" description="returns the model as a string" hint="String representation of the model" access="public" output="false" returntype="string">
		<cfset var stream = createObject("java", "java.io.ByteArrayOutputStream").init()>
		<cfset variables.model.write(stream, javaCast("null",""))>
		<cfreturn stream.toString()>
	</cffunction>

	<cffunction name="getSPARQLPrefixes" hint="Return a SPARQL prefix string" returntype="string" access="public" output="false">
		<cfset var prefixString = "">
		<cfset var prefixes = variables.model.getNsPrefixMap()>
		<cfloop collection="#prefixes#" item="ff">
			<cfset prefixString = prefixString & "PREFIX #lcase(ff)#: <#prefixes[ff]#> ">
		</cfloop>
		<cfreturn prefixString>
	</cffunction>
	
	<cffunction name="listObjectsOfProperty" description="returns array of objects" hint="returns array of objects" access="public" output="false" returntype="array">
		<cfargument name="resource" type="string" required="true" hint="resource uri">
		<cfargument name="namespace" type="string" required="true" hint="namespace uri">
		<cfargument name="property" type="string" required="true" hint="property">
		<cfset resource = this.getResource(arguments.resource)>
		<cfset property = this.asJava().createProperty(arguments.namespace,arguments.property)>
		<cfset iterator = this.asJava().listObjectsOfProperty(resource, property)>
		<cfset result = arrayNew(1)>
		<cfloop condition = "iterator.hasNext()">
			<cfset arrayAppend(result,iterator.nextNode().toString())>
		</cfloop>
		<cfreturn result>
	</cffunction>

	<cffunction name="getProperty" hint="returns a java Property representation" access="public" output="false" returntype="any">
		<cfargument name="namespace" type="string" required="true" hint="namespace">
		<cfargument name="property" type="string" required="true" hint="property">
		<cfreturn this.asJava().getResource(arguments.uri)>
	</cffunction>
	
	<cffunction name="getResource" hint="returns a java Resource representation" access="public" output="false" returntype="any">
		<cfargument name="uri" type="String" hint="The URI of the associated resource" required="false" />
		<cfreturn this.asJava().getResource(arguments.uri)>
	</cffunction>
	
</cfcomponent>