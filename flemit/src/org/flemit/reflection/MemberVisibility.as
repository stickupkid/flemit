package org.flemit.reflection
{
	public final class MemberVisibility
	{

		public static const PUBLIC : int = 0x08;

		public static const PROTECTED : int = 0x18;

		public static const PRIVATE : int = 0x05;
		
		public static function contains(value : int) : Boolean
		{
			return value == PUBLIC || value == PROTECTED || value == PRIVATE;
		}
	}
}