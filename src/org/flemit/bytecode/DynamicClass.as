package org.flemit.bytecode
{
	import org.flemit.reflection.FieldInfo;
	import org.flemit.reflection.MetadataInfo;
	import org.flemit.reflection.MethodInfo;
	import org.flemit.reflection.PropertyInfo;
	import org.flemit.reflection.Type;

	import flash.utils.Dictionary;
		
	public final class DynamicClass extends Type
	{
		public const methodBodies : Dictionary = new Dictionary();
		
		public const metadata : Vector.<MetadataInfo> = new Vector.<MetadataInfo>();
		
		public function DynamicClass(qname : QualifiedName, baseClass : Type, interfaces : Array)
		{
			super(qname);
			
			_baseClass = baseClass;
			
			_interfaces = interfaces;
		}
		
		public function addMetadata(metaDataInfo : MetadataInfo) : void
		{
			metadata.push(metaDataInfo);
		}
		
		public function addMethodBody(method : MethodInfo, methodBody : DynamicMethod) : void
		{
			methodBodies[method] = methodBody;
		}
		
		public function addMethod(method : MethodInfo) : void
		{
			_methods.push(method);
		}
		
		public function addProperty(property : PropertyInfo) : void
		{
			_properties.push(property);
		}
		
		public function addSlot(field : FieldInfo) : void
		{
			_fields.push(field);
		}
		
		public function set constructor(value : MethodInfo) : void { _constructor = value; }
	}
}