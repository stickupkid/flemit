package org.flemit.bytecode
{
	
	public final class RuntimeQualifiedName extends Multiname
	{
		private var _name : String;
		
		public function RuntimeQualifiedName(	name : String, 
												kind : int = MultinameKind.RUNTIME_QUALIFIED_NAME
												)
		{
			super(kind);
			
			_name = name;
		}
		
		public override function equals(object:Object):Boolean
		{
			const rtqn : RuntimeQualifiedName = object as RuntimeQualifiedName;
			if (rtqn != null) return rtqn.name == this._name;
			
			return false;
		}
		
		public function get name() : String { return _name; }
	}
}