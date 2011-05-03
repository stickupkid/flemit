package org.flemit.bytecode
{
	
	public class Multiname implements IEqualityComparable
	{
		private var _kind : int;
		
		public function Multiname(kind : int)
		{
			_kind = kind;
		}
		
		public function equals(object : IEqualityComparable) : Boolean
		{
			return false;
		}
		
		public function get kind() : int { return _kind; }
	}
}