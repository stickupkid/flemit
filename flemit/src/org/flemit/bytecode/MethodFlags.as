package org.flemit.bytecode
{
	public final class MethodFlags
	{

		public static var NEED_ARGUMENTS : int = 0x01;

		public static var NEED_ACTIVATION : int = 0x02;

		public static var NEED_REST : int = 0x04;

		public static var HAS_OPTIONAL : int = 0x08;

		public static var SET_DXNS : int = 0x40;

		public static var HAS_PARAM_NAMES : int = 0x80;
	}
}