/**
 *
 * as3extensions - ActionScript Extension Classes
 * Copyright (C) 2010-2012, Sandeep Gupta
 * http://www.sangupta.com/projects/as3extensions
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

package com.sangupta.as3extensions.db {
	
	import com.sangupta.as3extensions.IDisposable;
	import com.sangupta.as3utils.AssertUtils;
	
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.filesystem.File;
	import flash.net.Responder;
	
	public class Database implements IDisposable {
		
		/**
		 * Shared database connection
		 */
		protected var dbConnection:SQLConnection = null;
		
		public function Database() {
			super();
			
			initialize();
		}
		
		public function initialize():void {
			throw new Error('Must be implemented in a child class.');
		}
		
		protected static function initializeFromFile(file:File, openMode:String = SQLMode.CREATE):SQLConnection {
			var dbConnection:SQLConnection = new SQLConnection();
			dbConnection.open(file, openMode);
			return dbConnection;
		}
		
		/**
		 * Execute a given query and return its results back.
		 */
		public function executeSQLQuery(statement:String):SQLResult {
			if(dbConnection != null && dbConnection.connected && AssertUtils.isNotEmptyString(statement)) {
				try {
					var sqlStatement:SQLStatement = new SQLStatement();
					sqlStatement.sqlConnection = dbConnection;
					sqlStatement.text = statement ;
					sqlStatement.execute();
					return sqlStatement.getResult();
				} catch(e:Error) {
					trace("Error executing DB statement: " + statement + "\nError caught: " + e.toString());
				}
			}
			
			return null;
		}
		
		/**
		 * Return a prepared statement for the given query string.
		 */
		public function getStatement(query:String):SQLStatement {
			if(AssertUtils.isEmptyString(query)) {
				throw new Error('Query cannot be null/empty.');
			}
			
			var statement:SQLStatement = new SQLStatement();
			statement.sqlConnection = dbConnection;
			statement.text = query;
			return statement;
		}
		
		public function beginTransaction(option:String = null, responder:Responder = null):void {
			dbConnection.begin(option, responder);
		}
		
		public function commitTransaction(responder:Responder = null):void {
			dbConnection.commit(responder);
		}
		
		public function rollbackTransaction(responder:Responder = null):void {
			dbConnection.rollback(responder);
		}
		
		/**
		 * Prepare this object for destruction and garbage collection
		 */
		public function dispose():void {
			try {
				this.dbConnection.close();
			} catch(e:Error) {
				
			}
			
			this.dbConnection = null;
		}
	}
}
