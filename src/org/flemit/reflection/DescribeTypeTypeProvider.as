package org.flemit.reflection
{
	import flash.utils.getDefinitionByName;
	import org.flemit.bytecode.BCNamespace;
	import org.flemit.bytecode.GenericName;
	import org.flemit.bytecode.Multiname;
	import org.flemit.bytecode.NamespaceKind;
	import org.flemit.bytecode.QualifiedName;
	import org.flemit.util.DescribeTypeUtil;

	import flash.net.registerClassAlias;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	
	public final class DescribeTypeTypeProvider implements ITypeProvider
	{
		private var _typeCache : Dictionary = new Dictionary(true);
		
		public function DescribeTypeTypeProvider()
		{
		}
		
		public function getType(cls : Class, applicationDomain : ApplicationDomain = null) : Type
		{
			if (_typeCache[cls] == null)
			{
				const className : String = getQualifiedClassName(cls);
				
				if (!applicationDomain.hasDefinition(className))
				{
					registerClassAlias(className, cls);
				}
				
				const typeXml : XML = DescribeTypeUtil.describe(cls);
				const typeName : String = typeXml.@name.toString();
				const genericParams : Array = getGenericParameters(typeName);
				const typeDefinition : Type = genericParams.length > 0
												? getGenericTypeDefinition(typeName)
												: null;
					
				if (typeDefinition != null)
				{
					// TODO: This should only happen once
					typeDefinition.setGenericParameterCount(genericParams.length);
				}
				
				const qname : QualifiedName = getQualifiedName(typeName);
				const multiname : Multiname = typeDefinition != null
												? getGenericName(typeDefinition, genericParams)
												: qname;

				const type : Type = new Type(qname, multiname, cls);
				_typeCache[cls] = type; // for circular references
								
				setClassFlags(type, typeXml);
				
				type.setBaseType(getBaseType(type, typeXml));
				type.setInterfaces(getInterfaces(typeXml));
				
				if (!type.isInterface && typeXml.factory.constructor.length() != 0)
					type.setConstructor(getMethodInfo(typeXml.factory.constructor[0], type, false));
				
				addMembers(typeXml, type, true);
				addMembers(typeXml.factory[0], type, false);
			}
			
			return _typeCache[cls];
		}
		
		private function isPrivateClass(namespaceName : String) : Boolean
		{
			return (namespaceName.indexOf(".as$") > -1);
		}
		
		private function getGenericName(	genericTypeDefinition : Type, 
											genericParams : Array
											) : GenericName 
		{
			// What does this do?
			genericParams = genericParams.map(function(type : Type,	... args) : Multiname 
												{ 
													return type.multiname; 
												});
			
			return new GenericName(genericTypeDefinition.multiname, genericParams);
		}

		private function getQualifiedName(typeName : String) : QualifiedName
		{
			var ns : String;
			var nsKind : int;
			var name : String;
				
			if (typeName.indexOf('::') == -1)
			{
				ns = "";
				nsKind = NamespaceKind.PACKAGE_NAMESPACE;
				name = typeName;
			}
			else
			{
				ns = typeName.substr(0, typeName.indexOf('::'));
				name = typeName.substr(typeName.indexOf('::') + 2);
				nsKind = isPrivateClass(ns)
					? NamespaceKind.PRIVATE_NS
					: NamespaceKind.PACKAGE_NAMESPACE;
			}
			
			return new QualifiedName(new BCNamespace(ns, nsKind), name);
		}
		
		private function setClassFlags(type : Type, typeXml : XML) : void
		{
			const isClass : Boolean = (typeXml.factory.extendsClass.length() > 0) 
										|| type.classDefinition == Object;
			const isDynamic : Boolean = (typeXml.@isDynamic.toString() == "true");
			
			var isFinal : Boolean = (typeXml.@isFinal.toString() == "true");
			
			// TODO: Experimental for nested types
			if (isFinal && type.qname.ns.kind != NamespaceKind.PACKAGE_NAMESPACE)
			{
				isFinal = false;
			}
			
			type.setIsInterface(!isClass);
			type.setIsFinal(isFinal);
			type.setIsDynamic(isDynamic);
		}
		
		private function getInterfaces(typeXml : XML) : Array
		{
			const interfaces : Array = [];
			for each(var interfaceNode : XML in typeXml.factory.implementsInterface)
			{
				const interfaceTypeName : String = interfaceNode.@type.toString();
				const interfaceType : Type = Type.getTypeByName(interfaceTypeName);
				
				interfaces.push(interfaceType);
			}
			return interfaces;
		}
		
		private function getBaseType(type : Type, typeXml : XML) : Type
		{
			if (!type.isInterface && type.classDefinition != Object)
			{
				const baseTypeName : String = typeXml.factory.extendsClass[0].@type.toString();
				return Type.getTypeByName(baseTypeName);
			}
			
			return null;
		}
		
		private function getGenericTypeDefinition(typeName : String) : Type
		{
			const genericExpr : RegExp = /^([^\<]+)\.\<.+\>$/;
			const genericTypeName : String = genericExpr.exec(typeName)[1].toString();
			
			return Type.getTypeByName(genericTypeName);
		}
		
		private function getGenericParameters(typeName : String) : Array
		{
			const genericParameters : Array = [];
			const paramsExpr : RegExp = /\<(.+)\>$/;
			const result : Object = paramsExpr.exec(typeName);
			if (result != null)
			{
				// TODO: Update with correct delmiter
				const paramTypeNames : Array = result[1].toString().split(', ');
				
				for each(var paramTypeName : String in paramTypeNames) 
				{
					genericParameters.push(Type.getTypeByName(paramTypeName));
				}
			}
			
			return genericParameters;
		}
		
		private function addMembers(typeXML : XML, owner : Type, isStatic : Boolean) : void 
		{
			var declaredBy : String = null;
			for each(var methodNode : XML in typeXML.method)
			{
				declaredBy = methodNode.@declaredBy.toString().replace('::',':');
				
				if (declaredBy == owner.fullName)
				{
					try
					{
						const methodInfo : MethodInfo = getMethodInfo(methodNode, owner, isStatic);
						owner.addMethod(methodInfo);
					}
					catch(err : TypeNotFoundError)
					{
					}
				}
			}
			
			for each(var propertyNode : XML in typeXML.accessor)
			{
				declaredBy = propertyNode.@declaredBy.toString().replace('::',':');
				if (declaredBy == owner.fullName)
				{
					try
					{
						const propertyInfo : PropertyInfo = getPropertyInfo(	propertyNode, 
																				owner, 
																				isStatic
																				);
						owner.addProperty(propertyInfo);
					}
					catch(err : TypeNotFoundError)
					{
					}
				}
			}
			
			var fieldInfo : FieldInfo = null;
			for each(var fieldNode : XML in typeXML.variable)
			{
				try
				{
					fieldInfo = getFieldInfo(fieldNode, owner, isStatic);
					owner.addField(fieldInfo);
				}
				catch(err : TypeNotFoundError)
				{
				}
			}
			
			for each(var constantNode : XML in typeXML.constant)
			{
				fieldInfo = getFieldInfo(constantNode, owner, isStatic);
				owner.addField(fieldInfo);
			}
		}
		
		private function getMemberFullName(name : String, owner : Type) : String
		{
			return owner.isInterface
				? owner.qname.toString().concat('/', owner.qname.toString(), ':', name)
				: owner.qname.toString().concat('/', name);
		}
		
		private function getMethodInfo(	methodInfoNode : XML, 
										owner : Type, 
										isStatic : Boolean
										) : MethodInfo
		{			
			const uri : String = methodInfoNode.@uri.toString();
			const name : String = methodInfoNode.@name.toString();
			const returnTypeName : String = methodInfoNode.@returnType.toString();
			
			const returnType : Type = returnTypeName == "" 
														? Type.voidType 
														: Type.getTypeByName(returnTypeName);
			const isOverride : Boolean = (owner.baseType != null 
														&& owner.baseType.getMethod(name) != null);
			const parameters : Array = [];
			for each(var parameterXML : XML in methodInfoNode.parameter)
			{
				const index : int = parseInt(parameterXML.@index.toString());
				const parameterTypeName : String = parameterXML.@type.toString();
				const optional : Boolean = (parameterXML.@optional.toString() == "true");

				const parameterName : String = ("arg" + index.toString());
				const parameterType : Type = Type.getTypeByName(parameterTypeName); 
				
				const parameter : ParameterInfo = new ParameterInfo(	parameterName, 
																		parameterType, 
																		optional
																		);
				parameters.push(parameter);
			}
			
			const metadatas : Array = [];
			for each(var metadataXML : XML in methodInfoNode.metadata)
			{
				const metadataName : String = metadataXML.@name.toString();
				
				const metadataParameters : Dictionary = new Dictionary();
				for each(var metadataArgXML : XML in metadataXML.arg)
				{
					const metadataArgKey : String = metadataArgXML.@key.toString();
					const metadataArgValue : String = metadataArgXML.@value.toString();
					
					metadataParameters[metadataArgKey] = metadataArgValue;
				}
								
				const metadata : MetadataInfo = new MetadataInfo(metadataName, metadataParameters);
				
				metadatas.push(metadata);
			}
			
			return new MethodInfo(	owner, 
									name, 
									getMemberFullName(name, owner), 
									MemberVisibility.PUBLIC, 
									isStatic, 
									isOverride, 
									returnType, 
									parameters,
									metadatas, 
									uri
									);
		}
		
		private function getPropertyInfo(	propertyInfoNode : XML, 
											owner : Type, 
											isStatic : Boolean
											) : PropertyInfo
		{
			const uri : String = propertyInfoNode.@uri.toString();
			const name : String = propertyInfoNode.@name.toString();
			const typeName : String = propertyInfoNode.@type.toString();
			
			const propertyType : Type = Type.getTypeByName(typeName);
			
			const access : String = propertyInfoNode.@access.toString();
			const canRead : Boolean = (access == "readonly" || access == "readwrite");
			const canWrite : Boolean = (access == "writeonly" || access == "readwrite");
			
			const isOverride : Boolean = (owner.baseType != null 
													&& owner.baseType.getProperty(name) != null);
			
			return new PropertyInfo(	owner, 
										name, 
										getMemberFullName(name, owner), 
										MemberVisibility.PUBLIC, 
										isStatic, 
										isOverride, 
										propertyType, 
										canRead, 
										canWrite, 
										uri
										);
		}
		
		private function getFieldInfo(	fieldInfoNode : XML, 
										owner : Type, 
										isStatic : Boolean
										) : FieldInfo
		{
			const name : String = fieldInfoNode.@name.toString();
			const typeName : String = fieldInfoNode.@type.toString();
			
			const type : Type = Type.getTypeByName(typeName);
			
			return new FieldInfo(	owner, 
									name, 
									getMemberFullName(name, owner), 
									MemberVisibility.PUBLIC, 
									isStatic, 
									type
									);
		}
	}
}