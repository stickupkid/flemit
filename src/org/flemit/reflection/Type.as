package org.flemit.reflection
{
	import org.flemit.bytecode.BCNamespace;
	import org.flemit.bytecode.Multiname;
	import org.flemit.bytecode.MultipleNamespaceName;
	import org.flemit.bytecode.NamespaceKind;
	import org.flemit.bytecode.NamespaceSet;
	import org.flemit.bytecode.QualifiedName;

	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;

	public class Type
	{
		
		private static var _typeProvider : ITypeProvider = new DescribeTypeTypeProvider();
		
		private static var _cachedTypes : Dictionary = new Dictionary(true);
		
		private static var _star : Type = createStar();

		private static var _rest : Type = createRest();
		
		private static var _void : Type = createVoid();
		
		private var _class : Class;

		private var _isDynamic : Boolean = false;

		private var _isFinal : Boolean = false;

		private var _isInterface : Boolean = false;

		private var _scriptInitialiser : MethodInfo;

		private var _staticInitialiser : MethodInfo;

		private var _qname : QualifiedName;

		private var _multiname : Multiname;

		private var _multiNamespaceName : MultipleNamespaceName;

		private var _typeNamespace : BCNamespace;

		private var _genericParameterCount : int;

		private var _genericParameters : Array;

		private var _genericTypeDefinition : Type;
				
		protected var _baseClass : Type;

		protected var _properties : Array;

		protected var _methods : Array;

		protected var _fields : Array;

		protected var _constructor : MethodInfo;
		
		protected var _interfaces : Array;

		public function Type(	qname : QualifiedName, 
								multiname : Multiname = null, 
								classDefinition : Class = null
								)
		{
			_interfaces = [];
			_properties = [];
			_methods = [];
			_fields = [];
			_qname = qname;
			_multiname = multiname || qname;
			
			_genericParameterCount = 0;

			_multiNamespaceName = new MultipleNamespaceName(name, new NamespaceSet([qname.ns]));

			_class = classDefinition;

			const typeNamespaceKind : int = _qname.ns.kind == NamespaceKind.PACKAGE_NAMESPACE 
												? NamespaceKind.NAMESPACE 
												: NamespaceKind.PROTECTED_NAMESPACE;

			_typeNamespace = new BCNamespace(	qname.ns.name.concat(':', qname.name), 
												typeNamespaceKind
												);

			_constructor = new MethodInfo(	this, 
											qname.name, 
											null, 
											MemberVisibility.PUBLIC, 
											false, 
											false, 
											star, 
											[]
											);
											
			_scriptInitialiser = new MethodInfo(	this, 
													"", 
													"", 
													MemberVisibility.PUBLIC, 
													true, 
													false, 
													star, 
													[]
													);
													
			_staticInitialiser = new MethodInfo(	this, 
													"", 
													"", 
													MemberVisibility.PUBLIC, 
													true, 
													false, 
													star, 
													[]
													);
		}

		public static function getTypeByName(	name : String, 
												applicationDomain : ApplicationDomain = null) : Type
		{
			applicationDomain = applicationDomain || ApplicationDomain.currentDomain;

			if (name == "*") return Type.star;
			if (name == "void") return Type.voidType;

			name = removeGenericStar(name);

			var cls : Class = null;

			try
			{
				cls = applicationDomain.hasDefinition(name) 
						? applicationDomain.getDefinition(name) as Class 
						: getClassByAlias(name);
			}
			catch (err : ReferenceError)
			{
				throw new TypeNotFoundError(name);
			}

			return getType(cls);
		}

		private static function removeGenericStar(typeName : String) : String
		{
			const expr : RegExp = /^([^\<]+)\.\<\*(, \*)*\>$/;
			const result : Object = expr.exec(typeName);

			return (result != null) ? result[1] : typeName;
		}

		public static function getType(obj : Object, useCache : Boolean = true) : Type
		{	
			if (obj == null)
				throw new ArgumentError("obj cannot be null");
			
			var cls : Class = null;
			
			// for when obj has no constructor property (why does it not extend Error or have an ID?)
			try
			{
				cls = obj as Class || obj.constructor as Class;
			}
			catch (ref : Error) 
			{
			}

			if (cls == null)
				cls = getDefinitionByName(getQualifiedClassName(obj)) as Class;
			
			// Return the cached version
			if(useCache && _cachedTypes[cls]) 
				return _cachedTypes[cls];
			
			const type : Type = _typeProvider.getType(cls, ApplicationDomain.currentDomain);
			
			// Cache the value if we're using the cache
			if(useCache) _cachedTypes[cls] = type;
			
			return type;
		}
		
		public static function clearCache() : void
		{
			for each(var type : Type in _cachedTypes)
			{
				type.dispose();
				type = null;
			}
			
			for(var item : String in _cachedTypes)
			{
				_cachedTypes[item] = null;
				delete _cachedTypes[item];
			}
		}
		
		private static function createStar() : Type
		{
			return new Type(new QualifiedName(BCNamespace.packageNS("*"), "*"));
		}
		
		private static function createRest() : Type
		{
			return new Type(new QualifiedName(BCNamespace.packageNS(""), "..."));
		}
		
		private static function createVoid() : Type
		{
			return new Type(new QualifiedName(BCNamespace.packageNS(""), "void"));
		}
		
		/**
		 * Returns whether this type is a numeric type (Number, int, uint)
		 * @return true is the type is a numeric type; false otherwsie
		 */
		public function get isNumeric() : Boolean
		{
			return this == Type.getType(int) 
					|| this == Type.getType(uint) 
					|| this == Type.getType(Number);
		}

		public function isAssignableFromInstance(value : Object) : Boolean
		{
			if (this.classDefinition == Class && value is Class) return true;
			if (value == null) return true;
			
			return this.isAssignableFrom(getType(value));
		}

		public function isAssignableFrom(type : Type) : Boolean
		{
			if (this == Type.voidType) return false;
			if (this == Type.star) return true;
			if (this == type) return true;
			if (this.classDefinition == Class) return true;

			// Vector can be assigne from Vector.<int>
			if (	this.isGenericTypeDefinition 
					&& type.isGeneric 
					&& type.genericTypeDefinition == this)
			{
				return true;
			}

			// int/Number can be implicitly cast
			if (this.isNumeric && type.isNumeric) return true;
			if (this.isInterface && type.getInterfaces().indexOf(this) != -1) return true;

			var parentType : Type = type;
			while (parentType != null)
			{
				if (this == parentType) return true;
				parentType = parentType.baseType;
			}

			return false;
		}
				
		public function getProperties(	includeStatic : Boolean = true, 
										includeInstance : Boolean = true,
										trySuper : Boolean = false
										) : Array
		{
			const result : Array = [];
			const total : int = _properties.length;
			for(var i : int = 0; i<total; i++)
			{
				const member : MemberInfo = _properties[i];
				if(member.isStatic)
				{
					if(includeStatic) result[result.length] = member;
				}
				else
				{
					if(includeInstance)	result[result.length] = member;
				}
			}
			
			if(null == baseType)
				return result;
			
			return trySuper 
							? result.concat(baseType.getProperties(
																	includeStatic, 
																	includeInstance,
																	trySuper
																	)) 
							: result;
		}
				
		public function getMethods(	includeStatic : Boolean = true, 
									includeInstance : Boolean = true,
									trySuper : Boolean = false
									) : Array
		{
			const result : Array = [];
			const total : int = _methods.length;
			for(var i : int = 0; i<total; i++)
			{
				const member : MemberInfo = _methods[i];
				if(member.isStatic)
				{
					if(includeStatic) result[result.length] = member;
				}
				else
				{
					if(includeInstance)	result[result.length] = member;
				}
			}
			
			if(null == baseType)
				return result;
						
			return trySuper 
							? result.concat(baseType.getMethods(
																includeStatic, 
																includeInstance,
																trySuper
																)) 
							: result;
		}
				
		public function getFields(	includeStatic : Boolean = true, 
									includeInstance : Boolean = true,
									trySuper : Boolean = false
									) : Array
		{
			const result : Array = [];
			const total : int = _fields.length;
			for(var i : int = 0; i<total; i++)
			{
				const member : MemberInfo = _fields[i];
				if(member.isStatic)
				{
					if(includeStatic) result[result.length] = member;
				}
				else
				{
					if(includeInstance)	result[result.length] = member;
				}
			}
			
			if(null == baseType)
				return result;
			
			return trySuper 
							? result.concat(baseType.getFields(
																includeStatic, 
																includeInstance,
																trySuper
																)) 
							: result;
		}
		
		public function getMembers(	includeStatic : Boolean = true, 
									includeInstance : Boolean = true,
									trySuper : Boolean = false
									) : Array
		{
			const members : Array = _methods.concat(_properties).concat(_fields);
			
			const result : Array = [];
			const total : int = members.length;
			for(var i : int = 0; i<total; i++)
			{
				const member : MemberInfo = members[i];
				if(member.isStatic)
				{
					if(includeStatic) result[result.length] = member;
				}
				else
				{
					if(includeInstance)	result[result.length] = member;
				}
			}
			
			if(null == baseType)
				return result;
			
			return trySuper 
							? result.concat(baseType.getMembers(
																includeStatic, 
																includeInstance,
																trySuper
																)) 
							: result;
		}
		
		public function getProperty(	name : String, 
										ns : String = null, 
										trySuper : Boolean = false
										) : PropertyInfo
		{
			const property : PropertyInfo = findMember(_properties, name, ns) as PropertyInfo;
			if (property) return property;
			
			return trySuper ? baseType.getProperty(name, ns, trySuper) : property;
		}

		public function getMethod(	name : String, 
									ns : String = null, 
									trySuper : Boolean = false
									) : MethodInfo
		{
			const method : MethodInfo = findMember(_methods, name, ns) as MethodInfo;
			if (method)	return method;
			
			return trySuper ? baseType.getMethod(name, ns, trySuper) : method;
		}
		
		public function getField(	name : String, 
									ns : String, 
									trySuper : Boolean = false
									) : FieldInfo
		{
			const field : FieldInfo = findMember(_fields, name, ns) as FieldInfo;
			if (field) return field;
			
			return trySuper ? baseType.getField(name, ns, trySuper) : null;
		}

		public function getMember(name : String) : MemberInfo
		{
			return getMethod(name) || getProperty(name) || getField(name, null);
		}
		
		public function getInterfaces() : Array
		{
			return _interfaces;
		}
		
		private function findMember(members : Array, name : String, ns : String) : MemberInfo
		{
			var index : int = members.length;
			while(--index > -1)
			{
				const memberInfo : MemberInfo = members[index];
				if (memberInfo.name == name && (!ns || memberInfo.ns == ns))
				{
					return memberInfo;
				}
			}
			
			return null;
		}
		
		internal function setBaseType(value : Type) : void
		{
			_baseClass = value;
		}
		
		internal function setMultiNamespaceName(value : MultipleNamespaceName) : void
		{
			_multiNamespaceName = value;
		}
		
		internal function setIsDynamic(value : Boolean) : void
		{
			_isDynamic = value;
		}
		
		internal function setIsInterface(value : Boolean) : void
		{
			_isInterface = value;
		}

		internal function setIsFinal(value : Boolean) : void
		{
			_isFinal = value;
		}

		internal function setTypeNamespace(value : BCNamespace) : void
		{
			_typeNamespace = value;
		}

		internal function setInterfaces(value : Array) : void
		{
			_interfaces = [].concat(value);
		}

		internal function setGenericParameterCount(value : uint) : void
		{
			_genericParameterCount = value;
		}

		internal function setGenericParameters(	parameters : Array, 
												genericTypeDefinition : Type
												) : void
		{
			_genericParameters = parameters;
			_genericTypeDefinition = genericTypeDefinition;
		}

		internal function addProperty(propertyInfo : PropertyInfo) : void
		{
			_properties.push(propertyInfo);
		}

		internal function addMethod(methodInfo : MethodInfo) : void
		{
			_methods.push(methodInfo);
		}

		internal function addField(fieldInfo : FieldInfo) : void
		{
			_fields.push(fieldInfo);
		}

		internal function setConstructor(value : MethodInfo) : void
		{
			_constructor = value;
		}
		
		public static function get star() : Type { return _star; }
		
		public static function get voidType() : Type { return _void; }

		public static function get rest() : Type { return _rest; }
		
		public function get scriptInitialiser() : MethodInfo { return _scriptInitialiser; }

		public function get staticInitialiser() : MethodInfo { return _staticInitialiser; }

		public function get constructor() : MethodInfo { return _constructor; }
		
		public function get genericTypeDefinition() : Type { return _genericTypeDefinition; }

		public function get genericParameters() : Array { return _genericParameters; }

		public function get isGeneric() : Boolean
		{
			return _genericTypeDefinition != null && _genericParameters.length > 0;
		}

		public function get isGenericTypeDefinition() : Boolean
		{
			return _genericTypeDefinition == null && _genericParameterCount > 0;
		}

		public function get classDefinition() : Class { return _class; }

		public function get baseType() : Type { return _baseClass; }

		public function get name() : String { return qname.name; }

		public function get fullName() : String { return qname.toString(); }

		public function get packageName() : String { return qname.ns.name; }

		public function get qname() : QualifiedName { return _qname; }

		public function get multiname() : Multiname { return _multiname; }

		public function get multiNamespaceName() : MultipleNamespaceName 
		{ 
			return _multiNamespaceName; 
		}

		public function get isDynamic() : Boolean { return _isDynamic; }

		public function get isFinal() : Boolean { return _isFinal; }

		public function get isInterface() : Boolean { return _isInterface; }
		
		public function get typeNamespace() : BCNamespace { return _typeNamespace; }
		
		public function dispose() : void
		{
			_scriptInitialiser = null;
			_staticInitialiser = null;
			
			_qname = null;
			_multiname = null;
			_baseClass = null;
			_constructor = null;
			_typeNamespace = null;
			_multiNamespaceName = null;
			_genericTypeDefinition = null;
			
			if(null != _genericParameters)
			{
				_genericParameters.length = 0;
				_genericParameters = null;
			}
			
			if(null != _properties)
			{
				_properties.length = 0;
				_properties = null;
			}
			
			if(null != _methods)
			{
				_methods.length = 0;
				_methods = null;
			}
			
			if(null != _fields)
			{
				_fields.length = 0;
				_fields = null;
			}
			
			if(null != _interfaces)
			{
				_interfaces.length = 0;
				_interfaces = null;
			}
		}
	}
}