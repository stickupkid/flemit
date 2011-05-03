package org.flemit.bytecode
{
	
	public final class NamespaceSet implements IEqualityComparable
	{
		private var _namespaces : Array;
		
		public function NamespaceSet(namespaces : Array)
		{
			_namespaces = [].concat(namespaces);
		}
		
		public function equals(object : IEqualityComparable) : Boolean 
		{
			const namespaceSet : NamespaceSet = object as NamespaceSet;
			if (namespaceSet != null)
			{
				const nsSetTotal : int = namespaceSet._namespaces.length;
				const nsTotal : int = _namespaces.length;
				if (nsSetTotal == nsTotal)
				{
					for (var i : int = 0; i<nsTotal; i++)
					{
						const comparable : IEqualityComparable = namespaceSet._namespaces[i];
						if (!comparable.equals(_namespaces[i]))
							return false;
					}
					return true;
				}
			}
			return false;
		}
		
		public function get namespaces() : Array { return _namespaces; }
		
		public function toString() : String
		{
			return '[' + _namespaces.join(',') + ']';
		}
	}
}