package org.flemit.bytecode
{
	
	public final class GenericName extends Multiname
	{
		private var _typeDefinition : Multiname;
		
		private var _genericParameters : Array;
		
		public function GenericName(	typeDefinition : Multiname, 
										genericParameters : Array, 
										kind : int = MultinameKind.GENERIC
										)
		{
			super(kind);
			
			_typeDefinition = typeDefinition;
			_genericParameters = new Array().concat(genericParameters);
		}
		
		
		public override function equals(object:Object):Boolean
		{
			const gn : GenericName = object as GenericName;
			if (gn != null)
			{
				const gnGenericParamsTotal : int = gn._genericParameters.length;
				const genericParamsTotal : int = _genericParameters.length;
				if (!gn._typeDefinition.equals(_typeDefinition) 
					|| gnGenericParamsTotal != genericParamsTotal)
				{
					return false;
				}
				
				for (var i:int = 0; i<genericParamsTotal; i++)
				{
					const comparable : IEqualityComparable = gn._genericParameters[i];
					if (!comparable.equals(_genericParameters[i])) return false;
				}
				
				return true;
			}
			
			return false;
		}
		
		public function get typeDefinition() : Multiname { return _typeDefinition; }
		
		public function get genericParameters() : Array { return _genericParameters; }
	}
}