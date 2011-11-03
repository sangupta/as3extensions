package org.myjerry.as3extensions.db {
	
	import flash.data.SQLStatement;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	
	import org.myjerry.as3extensions.db.Database;
	
	public class ORMDatabase extends Database {
		
		public function ORMDatabase() {
			super();
		}
		
		/**
		 * Map of metadata information for each class used by the application. The class is used as
		 * the map key. The information maintained for each class includes:
		 * table: name of the database table used to persist the object information.
		 * identity: object that maps the table primary key to the name of the corresponding class field.
		 * fields: list of objects that map field names of the class to the corresponding database colums.
		 */
		private var map:Object = new Object();
		
		public function findAll(clazz:Class):ArrayList {
			// If not yet done, load the metadata for this class
			if (!map[clazz]) {
				loadMetadata(clazz);
			}
			
			var stmt:SQLStatement = map[clazz].findAllStmt;
			stmt.execute();
			// Return typed objects
			var result:Array = stmt.getResult().data;
			return typeArray(result,clazz);
		}
		
		public function save(o:Object):void
		{
			var c:Class = Class(getDefinitionByName(getQualifiedClassName(o)));
			// If not yet done, load the metadata for this class
			if (!map[c]) loadMetadata(c);
			var identity:Object = map[c].identity;
			// Check if the object has an identity
			if (o[identity.field]>0)
			{
				// If yes, we deal with an update
				updateItem(o,c);
			}
			else
			{
				// If no, this is a new item
				createItem(o,c);
			}
		}
		
		private function updateItem(o:Object, c:Class):void
		{
			var stmt:SQLStatement = map[c].updateStmt;
			var fields:ArrayCollection = map[c].fields;
			for (var i:int = 0; i<fields.length; i++)
			{
				var field:String = fields.getItemAt(i).field;
				stmt.parameters[":" + field] = o[field];
			}
			stmt.execute();
		}
		
		private function createItem(o:Object, c:Class):void {
			var stmt:SQLStatement = map[c].insertStmt;
			var identity:Object = map[c].identity;
			var fields:ArrayCollection = map[c].fields;
			for (var i:int = 0; i<fields.length; i++)
			{
				var field:String = fields.getItemAt(i).field;
				if (field != identity.field)
				{
					stmt.parameters[":" + field] = o[field];
				}
			}
			stmt.execute();
			o[identity.field] = stmt.getResult().lastInsertRowID;
		}
		
		public function remove(o:Object):void {
			var c:Class = Class(getDefinitionByName(getQualifiedClassName(o)));
			// If not yet done, load the metadata for this class
			if (!map[c]) loadMetadata(c);
			var identity:Object = map[c].identity;
			var stmt:SQLStatement = map[c].deleteStmt;
			stmt.parameters[":"+identity.field] = o[identity.field];
			stmt.execute();
		}
		
		public function removeID(clazz:Class, id:*):void {
			if(!map[clazz]) {
				loadMetadata(clazz);
			}
			
			var identity:Object = map[clazz].identity;
			var stmt:SQLStatement = map[clazz].deleteStmt;
			stmt.parameters[":"+identity.field] = id;
			stmt.execute();
		}
		
		public function find(clazz:Class, id:*):Object {
			if(!map[clazz]) {
				loadMetadata(clazz);
			}
			
			var identity:Object = map[clazz].identity;
			var stmt:SQLStatement = map[clazz].findStmt;
			stmt.parameters[":" + identity.field] = id;
			stmt.execute();
			
			// Return typed objects
			var result:Array = stmt.getResult().data;
			
			if(result.data.length == 1) {
				return typeObject(result.data[0], clazz);
			}
			
			return null;
		}
		
		private function loadMetadata(c:Class):void {
			var object:Object = new Object();
			map[c] = object;
			
			var xml:XML = describeType(new c());
			
			var table:String = xml.metadata.(@name=="Table").arg.(@key=="name").@value;
			
			object.table = table;
			object.fields = new ArrayCollection();
			var variables:XMLList = xml.accessor;
			
			var insertParams:String = "";
			var updateSQL:String = "UPDATE " + table + " SET ";
			var insertSQL:String = "INSERT INTO " + table + " (";
			var createSQL:String = "CREATE TABLE IF NOT EXISTS " + table + " (";
			
			for (var i:int = 0 ; i < variables.length() ; i++) {
				var field:String = variables[i].@name.toString();
				var column:String;
				
				// check if the variable is not transient
				if(variables[i].metadata.(@name=="Transient") != null) {
					// no need to keep this variable
					continue;
				}
				
				if (variables[i].metadata.(@name=="Column").length()>0) {
					column = variables[i].metadata.(@name=="Column").arg.(@key=="name").@value.toString(); 
				} else {
					column = field.toUpperCase();
				}
				
				object.fields.addItem({field: field, column: column});
				
				if (variables[i].metadata.(@name=="Id").length() > 0) {
					object.identity = {field: field, column: column};
					createSQL += column + " INTEGER PRIMARY KEY AUTOINCREMENT,";
				} else {
					insertSQL += column + ",";
					insertParams += ":" + field + ",";
					updateSQL += column + "=:" + field + ",";	
					createSQL += column + " " + getSQLType(variables[i].@type) + ",";
				}
			}
			
			createSQL = createSQL.substring(0, createSQL.length-1) + ")";
			
			insertSQL = insertSQL.substring(0, insertSQL.length-1) + ") VALUES (" + insertParams;
			insertSQL = insertSQL.substring(0, insertSQL.length-1) + ")";
			
			updateSQL = updateSQL.substring(0, updateSQL.length-1);
			updateSQL += " WHERE " + object.identity.column + "=:" + object.identity.field;
			
			var deleteSQL:String = "DELETE FROM " + table + " WHERE " + object.identity.column + "=:" + object.identity.field;
			
			var findSQL:String = "SELECT * FROM " + table + " WHERE " + object.identity.column + "=:" + object.identity.field;
			
			var stmt:SQLStatement = new SQLStatement();
			stmt.sqlConnection = this.dbConnection;
			stmt.text = insertSQL;
			object.insertStmt = stmt;
			
			stmt = new SQLStatement();
			stmt.sqlConnection = this.dbConnection;
			stmt.text = updateSQL;
			object.updateStmt = stmt;
			
			stmt = new SQLStatement();
			stmt.sqlConnection = this.dbConnection;
			stmt.text = deleteSQL;
			object.deleteStmt = stmt;
			
			stmt = new SQLStatement();
			stmt.sqlConnection = this.dbConnection;
			stmt.text = findSQL;
			object.findStmt = stmt;
				
			stmt = new SQLStatement();
			stmt.sqlConnection = this.dbConnection;
			stmt.text = "SELECT * FROM " + table;
			object.findAllStmt = stmt;
			
			stmt = new SQLStatement();
			stmt.sqlConnection = this.dbConnection;
			stmt.text = createSQL;
			stmt.execute();
			
		}
		
		private function typeArray(a:Array, c:Class):ArrayList {
			if (a==null) return null;
			var ac:ArrayList = new ArrayList();
			for (var i:int = 0; i < a.length; i++) {
				ac.addItem(typeObject(a[i],c));
			}
			
			return ac;			
		}
		
		private function typeObject(o:Object,c:Class):Object
		{
			var instance:Object = new c();
			var fields:ArrayCollection = map[c].fields;
			
			for (var i:int; i<fields.length; i++)
			{
				var item:Object = fields.getItemAt(i);
				instance[item.field] = o[item.column];	
			}
			return instance;
		}
		
		private function getSQLType(asType:String):String
		{
			if (asType == "int" || asType == "uint")
				return "INTEGER";
			else if (asType == "Number")
				return "REAL";
			else
				return "TEXT";				
		}
	}
}

