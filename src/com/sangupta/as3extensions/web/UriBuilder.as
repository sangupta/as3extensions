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

package com.sangupta.as3extensions.web {
	import com.sangupta.as3extensions.model.StringKeyValuePair;
	import com.sangupta.as3utils.AssertUtils;
	import com.sangupta.as3utils.StringUtils;
	
	/**
	 * Helper class for building and manipulating URLs.
	 * 
	 * Use <code>fromUri()</code> to convert an exisitng URL into a builder object.
	 * 
	 */
	public class UriBuilder {
		
		public function UriBuilder() {
		}
		
		/**
		 * Holds the scheme or the protocol for the url being constructed
		 * 
		 * @private
		 */
		private var _scheme:String = null;
		
		public function scheme(value:String):UriBuilder {
			this._scheme = value;
			return this;
		}

		/**
		 * Holds the host or the IP address for the url being constructed
		 * 
		 * @private
		 */
		private var _host:String = null;
		
		public function host(value:String):UriBuilder {
			this._host = value;
			return this;
		}
		
		/**
		 * Holds the connection port for the url being constructed
		 * 
		 * @private
		 */
		private var _port:uint = 80;
		
		public function port(value:uint):UriBuilder {
			this._port = value;
			return this;
		}
		
		/**
		 * Holds the path for the url being constructed
		 *
		 * @private
		 */
		private var _path:String = null;
		
		public function get path():String {
			return this._path;
		}

		/**
		 * Holds the various query parameters and their values for the url being constructed
		 * 
		 * @private
		 */
		private const _queryParameters:Vector.<StringKeyValuePair> = new Vector.<StringKeyValuePair>();
		
		private function buildQueryString():String {
			return null;
		}
		
		/**
		 * Holds the fragment aka anchor for the url being constructed
		 */
		private var _fragment:String = null;
		
		/**
		 * Encodes and sets the fragment.
		 */
		public function fragment(value:String):UriBuilder {
			this._fragment = encodeURIComponent(value);
			return this;
		}
		
		/**
		 * Sets the previously encoded fragment.
		 */
		public function encodedFragment(value:String):UriBuilder {
			this._fragment = value;
			return this;
		}

		/**
		 * Construct the URI with the given attributes
		 */
		public function build():String {
			var url:String = this._scheme + '://' + this._host;
			
			if(this._port != 80) {
				url += ':' + this._port;
			}
			
			if(this.path != null) {
				url += '/' + this.path;
			}

			const queryString:String = buildQueryString();
			if(queryString != null) {
				url += '?' + queryString;
			}
			
			if(this._fragment != null) {
				url += '#' + this._fragment;
			}
			
			return url;
		}
		
		/**
		 * Clears the previously set query parameters
		 */
		public function clearQuery():UriBuilder {
			this._queryParameters.splice(0, this._queryParameters.length);
			return this;
		}
		
		public function setFragment(fragment:String):UriBuilder {
			this._fragment = encodeURI(fragment);
			return this;
		}
		
		public function setEncodedFragment(fragment:String):UriBuilder {
			this._fragment = encodeURIComponent(fragment);
			return this;
		}
		
		/**
		 * Set the path to the provided value
		 */
		public function setPath(path:String):UriBuilder {
			this._path = encodeURIComponent(path);
			return this;
		}
		
		/**
		 * Set the path to the provided (already) encoded value
		 */
		public function setEncodedPath(path:String):UriBuilder {
			this._path = path;
			return this;
		}
		
		/**
		 * Encodes the given segment and appends it to the path
		 */
		public function appendPath(segment:String):UriBuilder {
			if(AssertUtils.isEmptyString(segment)) {
				return this;
			}
			
			if(!StringUtils.endsWith(path, '/') && !StringUtils.startsWith(segment, '/')) {
				segment += '/';
			}
			
			this._path += encodeURIComponent(segment);
			return this;
		}
		
		/**
		 * Appends the (already) encoded segment to the path
		 */
		public function appendEncodedPath(segment:String):UriBuilder {
			if(AssertUtils.isEmptyString(segment)) {
				return this;
			}
			
			if(!StringUtils.endsWith(path, '/') && !StringUtils.startsWith(segment, '/')) {
				segment += '/';
			}
			
			this._path += segment;
			return this;
		}
		
		/**
		 * Set the query parameters from the given string.
		 */
		public function setQuery(query:String):UriBuilder {
			return this;
		}
		
		/**
		 * Adds/replaces the query parameter defined by the key with the provided value encoding alongside.
		 */
		public function setQueryParameter(key:String, value:String):UriBuilder {
			return this;
		}
		
		/**
		 * Adds/replaces the query parameter defined by the key with the provided (already) encoded value
		 */
		public function setEncodedQueryParameter(key:String, value:String):UriBuilder {
			return this;
		}
		
		/**
		 * Returns a string containing a concise, human-readable description of this object.
		 */
		public function toString():String {
			return null;
		}
		
		/**
		 * Test if the given instance of <code>UriBuiler</code> represents exactly the same URI or not.
		 * 
		 * @param other an instance of <code>UriBuilder</code> to be tested against
		 * 
		 * @return <code>true</code> if both this instance and the given instance represent exactly the same
		 * URI, <code>false</code> otherwise
		 */
		public function equals(other:UriBuilder):Boolean {
			if(other == null) {
				return false;
			}
			
			if(this === other) {
				return true;
			}
			
			return false;
		}
		
		/**
		 * Test if the given URI is the same as the URI represented by this <code>UriBuilder</code> object.
		 */
		public function equalsUri(uri:String):Boolean {
			if(uri == null) {
				return false;
			}
			
			var other:UriBuilder = UriBuilder.fromUri(uri);
			
			return this.equals(other);
		}

		/**
		 * Obtain a <code>UriBuilder</code> object from the given URI represented as a <code>String</code>
		 * 
		 * @return returns a new <code>UriBuilder</code> object instance which can be used to build upon
		 * a URI. This method never returns a <code>null</code>
		 */
		public static function fromUri(uri:String):UriBuilder {
			if(AssertUtils.isEmptyString(uri)) {
				return null;
			}
			
			return null; 
		}
		
	}
}
