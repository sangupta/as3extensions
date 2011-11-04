/**
 *
 * as3extensions - ActionScript Extension Classes
 * Copyright (C) 2011, myJerry Developers
 * http://www.myjerry.org/as3extensions
 *
 * The file is licensed under the the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

package org.myjerry.as3extensions.db {
	
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	
	import org.myjerry.as3extensions.db.Database;
	
	public class ORMDatabase extends Database {
		
		private var createTables:Boolean = true;
		
		private var showSQL:Boolean = false;
		
		public function ORMDatabase(createTables:Boolean = true, showSQL:Boolean = false) {
			super();
			
			this.createTables = createTables;
			this.showSQL = showSQL;
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

			if(this.showSQL) {
				trace(stmt.text);
			}
			
			stmt.execute();
			// Return typed objects
			var result:Array = stmt.getResult().data;
			return typeArray(result,clazz);
		}
		
		public function save(object:Object):void {
			var c:Class = Class(getDefinitionByName(getQualifiedClassName(object)));
			// If not yet done, load the metadata for this class
			if (!map[c]) loadMetadata(c);
			var identity:Object = map[c].identity;
			
			// Check if the object has an identity
			if (object[identity.field] > 0) {
				// If yes, we deal with an update
				updateItem(object, c);
			} else {
				// If no, this is a new item
				createItem(object, c);
			}
		}
		
		private function updateItem(o:Object, c:Class):void {
			var stmt:SQLStatement = map[c].updateStmt;
			var fields:ArrayCollection = map[c].fields;
			for (var i:int = 0; i<fields.length; i++) {
				var field:String = fields.getItemAt(i).field;
				stmt.parameters[":" + field] = o[field];
			}
			
			if(this.showSQL) {
				trace(stmt.text);
			}
			
			stmt.execute();
			
			var result:SQLResult = stmt.getResult();
			if(result.rowsAffected == 0) {
				// the item was not updated as it does not exists
				createItem(o, c);
			}
		}
		
		private function createItem(o:Object, c:Class):void {
			var stmt:SQLStatement = map[c].insertStmt;
			var identity:Object = map[c].identity;
			var fields:ArrayCollection = map[c].fields;
			for (var i:int = 0; i<fields.length; i++) {
				var field:String = fields.getItemAt(i).field;
				if (field != identity.field)
				{
					stmt.parameters[":" + field] = o[field];
				}
			}
			
			if(this.showSQL) {
				trace(stmt.text);
			}
			
			stmt.execute();
			
			var result:SQLResult = stmt.getResult();
			o[identity.field] = result.lastInsertRowID;
		}
		
		public function remove(o:Object):void {
			var c:Class = Class(getDefinitionByName(getQualifiedClassName(o)));
			// If not yet done, load the metadata for this class
			if (!map[c]) loadMetadata(c);
			var identity:Object = map[c].identity;
			var stmt:SQLStatement = map[c].deleteStmt;
			stmt.parameters[":"+identity.field] = o[identity.field];
			
			if(this.showSQL) {
				trace(stmt.text);
			}
			
			stmt.execute();
		}
		
		public function removeID(clazz:Class, id:*):void {
			if(!map[clazz]) {
				loadMetadata(clazz);
			}
			
			var identity:Object = map[clazz].identity;
			var stmt:SQLStatement = map[clazz].deleteStmt;
			stmt.parameters[":"+identity.field] = id;
			
			if(this.showSQL) {
				trace(stmt.text);
			}
			
			stmt.execute();
		}
		
		public function find(clazz:Class, id:*):Object {
			if(!map[clazz]) {
				loadMetadata(clazz);
			}
			
			var identity:Object = map[clazz].identity;
			var stmt:SQLStatement = map[clazz].findStmt;
			stmt.parameters[":" + identity.field] = id;
			
			if(this.showSQL) {
				trace(stmt.text);
			}
			
			stmt.execute();
			
			// Return typed objects
			var result:Array = stmt.getResult().data;
			
			if(result != null && result.length == 1) {
				return typeObject(result[0], clazz);
			}
			
			return null;
		}
		
		private function loadMetadata(c:Class):void {
			var object:ORMMetadataObject = new ORMMetadataObject();
			map[c] = object;
			
			var xml:XML = describeType(new c());
			
			const tableName:String = xml.metadata.(@name=="Table").arg.(@key=="name").@value;
			
			object.table = tableName;
			
			
			var updateSQL:String = "UPDATE " + tableName + " SET ";
			var insertSQL:String = "INSERT INTO " + tableName + " (";
			var createSQL:String = "CREATE TABLE IF NOT EXISTS " + tableName + " (";
			
			var variables:XMLList = null;
			var vbu:VariableBuildup = new VariableBuildup();
			
			vbu.updateSQL = updateSQL;
			vbu.insertSQL = insertSQL;
			vbu.createSQL = createSQL;

			// first do for directly accessible variables
			variables = xml.variable;
			if(variables.length() > 0) {
				doForVariables(variables, object, vbu);
			}
			
			// now do for accessors - properties that are bindable
			variables = xml.accessor;
			if(variables.length() > 0) {
				doForVariables(variables, object, vbu);
			}
			
			// set the variables back
			createSQL = vbu.createSQL;
			insertSQL = vbu.insertSQL;
			updateSQL = vbu.updateSQL;
			var insertParams:String = vbu.insertParams;
			
			// start building query statements
			createSQL = createSQL.substring(0, createSQL.length-1) + ")";
			
			insertSQL = insertSQL.substring(0, insertSQL.length-1) + ") VALUES (" + insertParams;
			insertSQL = insertSQL.substring(0, insertSQL.length-1) + ")";
			
			updateSQL = updateSQL.substring(0, updateSQL.length-1);
			updateSQL += " WHERE " + object.identity.column + "=:" + object.identity.field;
			
			const deleteSQL:String = "DELETE FROM " + tableName + " WHERE " + object.identity.column + "=:" + object.identity.field;
			const findSQL:String = "SELECT * FROM " + tableName + " WHERE " + object.identity.column + "=:" + object.identity.field;
			
			if(this.showSQL) {
				trace('insertSQL: ' + insertSQL);
				trace('updateSQL: ' + updateSQL);
				trace('deleteSQL: ' + deleteSQL);
				trace('findSQL: ' + findSQL);
			}
			
			object.insertStmt = getStatement(insertSQL);
			object.updateStmt = getStatement(updateSQL);
			object.deleteStmt = getStatement(deleteSQL);
			object.findStmt = getStatement(findSQL);
			object.findAllStmt = getStatement("SELECT * FROM " + tableName);
			
			// create the table if needed
			if(this.createTables) {
				if(this.showSQL) {
					trace(createSQL);
				}
				
				executeSQLQuery(createSQL);
			}
		}
		
		private function doForVariables(variables:XMLList, object:ORMMetadataObject, vbu:VariableBuildup):void {
			for (var i:int = 0 ; i < variables.length() ; i++) {
				var field:String = variables[i].@name.toString();
				var column:String;
				
				// check if the variable is not transient
				if(variables[i].metadata.(@name=="Transient").length() > 0) {
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
					vbu.createSQL += column + " INTEGER PRIMARY KEY AUTOINCREMENT,";
				} else {
					vbu.insertSQL += column + ",";
					vbu.insertParams += ":" + field + ",";
					vbu.updateSQL += column + "=:" + field + ",";	
					vbu.createSQL += column + " " + getSQLType(variables[i].@type) + ",";
				}
			}
		}
		
		private function typeArray(a:Array, c:Class):ArrayList {
			var ac:ArrayList = new ArrayList();
			
			if (a != null) { 
				for (var i:int = 0; i < a.length; i++) {
					ac.addItem(typeObject(a[i],c));
				}
			}
			
			return ac;			
		}
		
		private function typeObject(o:Object,c:Class):Object {
			var instance:Object = new c();
			var fields:ArrayCollection = map[c].fields;
			
			for (var i:int; i<fields.length; i++) {
				var item:Object = fields.getItemAt(i);
				instance[item.field] = o[item.column];	
			}
			
			return instance;
		}
		
		private function getSQLType(asType:String):String {
			if (asType == "int" || asType == "uint") {
				return "INTEGER";
			}
			
			if (asType == "Number") {
				return "REAL";
			}
			
			return "TEXT";				
		}
	}
}

import flash.data.SQLStatement;

import mx.collections.ArrayCollection;

class ORMMetadataObject{
	
	public var table:String;
	
	public var fields:ArrayCollection = new ArrayCollection();
	
	public var identity:Object;
	
	public var insertStmt:SQLStatement;
	public var updateStmt:SQLStatement;
	public var deleteStmt:SQLStatement;
	public var findStmt:SQLStatement;
	public var findAllStmt:SQLStatement;
	
}

class VariableBuildup {
	
	public var createSQL:String = '';
	
	public var insertSQL:String = '';
	
	public var updateSQL:String = '';
	
	public var insertParams:String = '';
}