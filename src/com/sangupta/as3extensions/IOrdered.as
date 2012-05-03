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

package com.sangupta.as3extensions {
	
	/**
	 * Interface enforcing contract that the implementing object can be ordered
	 * in a given list of objects. The order of this object can be set and retrieved
	 * via public methods.
	 *
	 * @author sangupta
	 * @since 1.0
	 */
	public interface IOrdered {
		
		/**
		 * Return the current ordering preference of this object.
		 * 
		 * @return unsigned integer representing the order of this object
		 */
		function get order():uint;
		
		/**
		 * Set the order of this object to the given value
		 * 
		 * @param value an unsigned integer indicating the new order for this object
		 */
		function set order(value:uint):void;
		
	}
}
