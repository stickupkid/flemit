package org.flemit.bytecode
{
	public final class BCNamespace implements IEqualityComparable
	{
		
		private var _name : String;
		
		private var _kind : int;
		
		public function BCNamespace(name : String, kind : int)
		{
			_name = name;
			_kind = kind;	
		}
		
		public static function packageNS(name : String) : BCNamespace
		{
			return new BCNamespace(name, NamespaceKind.PACKAGE_NAMESPACE);
		}

		public function equals(object:Object):Boolean
		{
			const ns : BCNamespace = object as BCNamespace;
			if (ns != null) return ns.name == _name && ns.kind == _kind;
			
			return false;
		}
		
		public function get name() : String { return _name; }
		
		public function get kind() : int { return _kind; }
		
		public function toString() : String
		{
			return _name;
		}
	}
}