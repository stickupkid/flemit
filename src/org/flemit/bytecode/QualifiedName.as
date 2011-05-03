package org.flemit.bytecode
{
	
	public final class QualifiedName extends Multiname
	{
		private var _name : String;
		
		private var _ns : BCNamespace;
		
		public function QualifiedName(	ns : BCNamespace, 
										name : String, 
										kind : int = MultinameKind.QUALIFIED_NAME
										)
		{
			super(kind);
			
			_ns = ns;
			_name = name;
		}
		
		public override function equals(object : IEqualityComparable):Boolean
		{
			const qname : QualifiedName = object as QualifiedName;
			if (qname != null) return qname.ns.equals(_ns) && qname.name == _name; 
			
			return false;
		}
		
		public function get ns() : BCNamespace { return _ns; }
		
		public function get name() : String { return _name; }
		
		public function toString():String
		{
			const nsString : String = ns.toString();
			const sepChar : String = nsString.indexOf(':') == -1 ? ':' : '/';
			return nsString.concat(sepChar, name);
		}
	}
}