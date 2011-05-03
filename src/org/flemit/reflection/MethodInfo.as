package org.flemit.reflection
{
	
	public final class MethodInfo extends MemberInfo
	{
		private var _returnType : Type;
		
		private var _parameters : Array;
		
		public function MethodInfo(	type : Type, 
									name : String, 
									fullName : String, 
									visibility : int, 
									isStatic : Boolean, 
									isOverride : Boolean, 
									returnType : Type,  
									parameters : Array, 
									ns : String = null
									)
		{
			super(type, name, fullName, visibility, isStatic, isOverride, ns);
			
			_returnType = returnType;
			_parameters = parameters ? [].concat(parameters) : [];
		}
		
		public function get returnType() : Type
		{
			return _returnType;
		}
		
		public function get parameters() : Array
		{
			return [].concat(_parameters);
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