package org.flemit.reflection
{
	
	public final class ParameterInfo
	{
		private var _name : String;
		
		private var _type : Type;
		
		private var _optional : Boolean;
		
		public function ParameterInfo(name : String, type : Type, optional : Boolean)
		{
			_name = name;
			_type = type;
			_optional = optional;
		}
		
		public function get name() : String { return _name; }
		
		public function get type() : Type {	return _type; }
		
		public function get optional() : Boolean { return _optional; }
	}
}