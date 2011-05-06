package org.flemit.reflection
{
	import flash.utils.Dictionary;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public class MetadataInfo
	{
		
		private var _name : String;
		
		private var _parameters : Dictionary = new Dictionary();

		public function MetadataInfo(name : String, parameters : Dictionary)
		{
			_name = name;
			_parameters = parameters;
		}
		
		public function get name() : String { return _name; }
		
		public function get parameters() : Dictionary { return _parameters; }
	}
}
