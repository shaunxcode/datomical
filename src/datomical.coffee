jsedn = require "jsedn"
fs = require "fs"

args = require("optimist")
	.usage("expects --schema to be edn schema file")
	.alias("s", "schema")
	.alias("m", "models")
	.alias("r", "rest")
	.argv
	
if not args.schema
	console.log "Please pass in the name of the schema file to --schema"
	process.exit()
	
schema = jsedn.parse fs.readFileSync args.schema, "UTF-8"

entityNS = {}
attrs = "Entity Attributes"

schema.each (item) -> 
	if item instanceof jsedn.Map
		ident = item.at("db/ident").split "/"
		edef = entityNS
		
		for part in ident[0..-2]
			if not edef[part]
				edef[part] = {}
			edef = edef[part]
		
		if not edef[attrs]
			edef[attrs] = {}
		
		edef[attrs][ident[ident.length - 1]] = 
			ident: item.at "db/ident"
			valueType: item.at "db/valueType"
			cardinality: item.at "db/cardinality"
			doc: item.at "db/doc"
			
	else
		true #could be an enum 

if args.models
	console.log JSON.stringify entityNS, null, "\t"
	