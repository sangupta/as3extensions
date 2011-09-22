/**
 *
 * as3extensions - ActionScript Extension Classes
 * Copyright (C) 2010-2011, myJerry Developers
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

package org.myjerry.as3extensions.model {
	
	/**
	 * A utility holding class for key-value pairs, where both keys
	 * and values are <code>String</code> objects.
	 * 
	 * @author Sandeep Gupta
	 * @since 1.0
	 */
	public class StringKeyValuePair	{
		
		/**
		 * Holds the key part of the pair
		 * 
		 * @private
		 */
		private var _key:String = null;
		
		/**
		 * Holds the value part of the pair
		 *
		 * @private
		 */
		private var _value:String = null;
		
		/**
		 * Constructor
		 */
		public function StringKeyValuePair(key:String, value:String) {
			if(key == null) {
				throw new ArgumentError('Key cannot be null.');
			}
			
			this._key = key;
			this._value = value;
		}
		
		public function get key():String {
			return this._key;
		}
		
		public function get value():String {
			return this._value;
		}
		
		public function set value(value:String):void {
			this._value = value;
		}
	}
}
