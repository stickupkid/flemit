package org.flemit.reflection
{
	
	public final class MethodInfo extends MemberInfo
	{
		private var _returnType : Type;
		
		private var _parameters : Array;
		
		private var _metadata : Array;
		
		public function MethodInfo(	type : Type, 
									name : String, 
									fullName : String, 
									visibility : int, 
									isStatic : Boolean, 
									isOverride : Boolean, 
									returnType : Type,  
									parameters : Array, 
									metadata : Array = null,
									ns : String = null
									)
		{
			super(type, name, fullName, visibility, isStatic, isOverride, ns);
			
			_returnType = returnType;
			_parameters = parameters ? parameters : [];
			_metadata = metadata ? metadata : [];
		}
		
		public function get returnType() : Type
		{
			return _returnType;
		}
		
		public function get parameters() : Array
		{
			return _parameters;
		}
		
		public function get metadata() : Array
		{
			return _metadata;
		}
		
		public function clone() : MethodInfo
		{
			return new MethodInfo(	owner, 
									name, 
									fullName, 
									visibility, 
									isStatic, 
									isOverride, 
									returnType, 
									parameters
									);
		}
	}
}