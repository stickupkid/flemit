package org.flemit.bytecode
{
	import org.flemit.util.ClassUtility;
	
	public class Multiname implements IEqualityComparable
	{
		private var _kind : int;
		
		public function Multiname(kind : int)
		{
			ClassUtility.assertAbstract(this, Multiname);
			
			_kind = kind;
		}
		
		public function equals(object : Object) : Boolean
		{
			return false;
		}
		
		public function get kind() : int { return _kind; }
	}
}