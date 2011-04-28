package org.flemit.bytecode
{
	import org.flemit.reflection.MethodInfo;
	import org.flemit.reflection.Type;
	import org.flemit.util.ClassUtility;
	
	import flash.utils.Dictionary;
	
	public final class ByteCodeLayoutBuilder implements IByteCodeLayoutBuilder
	{
		
		private var _types : Array = [];
		
		private var _methods : Dictionary = new Dictionary();
		
		private var _ignoredPackages : Array = [	"flash.*", 
													"mx.*", 
													"fl.*", 
													":Object"
													];
		
		public function ByteCodeLayoutBuilder()
		{
		}
		
		public function registerType(type : Type) : void
		{
			if (_types.indexOf(type) == -1)
			{
				if (type.baseType != type && type.baseType != null)
				{
					registerType(type.baseType);
				}
				
				for each(var interfaceType : Type in type.getInterfaces())
				{
					registerType(interfaceType);
				}
				
				_types.push(type);
			}
		}
		
		public function registerMethodBody(method : MethodInfo, methodBody : DynamicMethod) : void
		{
			_methods[method] = methodBody;
		}
		
		public function createLayout() : IByteCodeLayout
		{
			var layout : ByteCodeLayout = new ByteCodeLayout();
			
			for each(var type : Type in this._types)
			{
				const dynamicClass : DynamicClass = type as DynamicClass;
				
				if (isIgnored(type) || dynamicClass == null)
				{
					layout.registerMultiname(type.multiname);
					layout.registerMultiname(type.multiNamespaceName);
				}
				else
				{
					layout.registerClass(type);
					
					if (null != dynamicClass)
					{
						for each (var methodBody : DynamicMethod in dynamicClass.methodBodies)
						{
							layout.registerMethodBody(methodBody.method, methodBody);
						}
					}
				}
			}
			
			return layout;
		}
		
		private function isIgnored(type : Type) : Boolean
		{
			var index : int = _ignoredPackages.length;
			while(--index > -1)
			{
				const ignoredPackage : String = _ignoredPackages[index];
				if(ClassUtility.isMatch(ignoredPackage, type.fullName))
				{
					return true;
				}
			}
			
			return false;
		}
	}
}