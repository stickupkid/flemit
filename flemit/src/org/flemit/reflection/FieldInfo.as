package org.flemit.reflection
{
	
	public final class FieldInfo extends MemberInfo
	{
		private var _type : Type;
		
		public function FieldInfo(	owner : Type, 
									name : String, 
									fullName : String, 
									visibility : int, 
									isStatic : Boolean, 
									type : Type
									)
		{
			super(owner, name, fullName, visibility, isStatic, false, null);
			
			_type = type;
		}
		
		public function get type() : Type {	return _type; }
	}
}