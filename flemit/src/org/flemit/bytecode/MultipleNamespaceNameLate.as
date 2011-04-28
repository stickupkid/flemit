package org.flemit.bytecode
{
	
	public final class MultipleNamespaceNameLate extends Multiname
	{
		private var _namespaceSet : NamespaceSet;
		
		public function MultipleNamespaceNameLate(	namespaceSet : NamespaceSet, 
													kind : uint = MultinameKind.MULTINAME_LATE
													)
		{
			super(kind);
			
			_namespaceSet = namespaceSet;
		}
		
		public function get namespaceSet() : NamespaceSet { return _namespaceSet; }
	}
}