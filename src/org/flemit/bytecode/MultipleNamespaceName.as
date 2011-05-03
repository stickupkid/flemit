package org.flemit.bytecode
{
	public final class MultipleNamespaceName extends Multiname
	{

		private var _name : String;

		private var _namespaceSet : NamespaceSet;

		public function MultipleNamespaceName(	name : String, 
												namespaceSet : NamespaceSet, 
												kind : int = MultinameKind.MULTINAME
												)
		{
			super(kind);

			_name = name;
			_namespaceSet = namespaceSet;
		}

		public override function equals(object : IEqualityComparable) : Boolean
		{
			const mnsn : MultipleNamespaceName = object as MultipleNamespaceName;
			if (mnsn != null) return mnsn.name == _name && mnsn.namespaceSet.equals(_namespaceSet);
			
			return false;
		}
		
		public function get name() : String { return _name; }

		public function get namespaceSet() : NamespaceSet { return _namespaceSet; }

		public function toString() : String
		{
			const nsString : String = namespaceSet.toString();
			const sepChar : String = (nsString.indexOf(':') == -1) ? ':' : '/';

			return nsString.concat(sepChar, name);
		}
	}
}