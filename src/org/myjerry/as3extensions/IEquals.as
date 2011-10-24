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

package org.myjerry.as3extensions {
	
	/**
	 * Interface enforcing contract that the implementing object provides an
	 * implementation to be tested for equality.
	 * 
	 * @author Sandeep Gupta
	 * @since 1.0
	 */
	public interface IEquals {
		
		/**
		 * Tests whether the provided second object is equal to this object.
		 * 
		 * @param object the object to be tested against
		 * 
		 * @return <code>true</code> if the objects are equals, <code>false</code>
		 * otherwise.
		 */
		function equals(other:Object):Boolean;
		
	}
}