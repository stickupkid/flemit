package org.flemit.bytecode
{
	import org.flemit.reflection.FieldInfo;
	import org.flemit.reflection.MethodInfo;
	import org.flemit.reflection.ParameterInfo;
	import org.flemit.reflection.PropertyInfo;
	import org.flemit.reflection.Type;

	import flash.errors.IllegalOperationError;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.IDataOutput;
	
	
	public final class ByteCodeLayout implements IByteCodeLayout
	{
		private static var _instructionParamTypes : Dictionary = 
									ByteCodeLayoutInstructionParamTypes.getInstructionParamTypes();
		
		private var _readOnly : Boolean	= false;
		
		private var _integers : Array;
		
		private var _uintegers : Array;
		
		private var _doubles : Array;
		
		private var _strings : Array;
		
		private var _namespaces : Array;
		
		private var _namespaceSets : Array;
		
		private var _multinames : Array;
		
		private var _methods : Array;
		
		private var _metadata : Array;
		
		private var _types : Array;
		
		private var _methodBodies : Array;
		
		private var _methodBodiesBuffer : ByteArray;
		
		private var _methodBodiesWriter : IByteCodeWriter;
		
		private var _majorVersion : int = 46;
		
		private var _minorVersion : int = 16;
		
		public function ByteCodeLayout()
		{
			_integers = [0];
			_uintegers = [0];
			_doubles = [0];
			_strings = ['*'];
			_namespaces = [];
			_namespaceSets = [];
			_multinames = [];
			_methods = [];
			_metadata = [];
			
			_types = [];
			_methodBodies = [];
			
			_methodBodiesBuffer = new ByteArray();
			_methodBodiesWriter = new ByteCodeWriter(_methodBodiesBuffer);
			
			registerNamespaceSet(new NamespaceSet([Type.star.qname.ns]));
			registerMultiname(Type.star.qname);
		}
		
		
		public function dispose() : void
		{
			_integers.length = 0;
			_integers = null;
			
			_uintegers.length = 0;
			_uintegers = null;
			
			_doubles.length = 0;
			_doubles = null;
			
			_strings.length = 0;
			_strings = null;
			
			_namespaces.length = 0;
			_namespaces = null;
			
			_namespaceSets.length = 0;
			_namespaceSets = null;
			
			_multinames.length = 0;
			_multinames = null;
			
			_methods.length = 0;
			_methods = null;
			
			_metadata.length = 0;
			_metadata = null;
			
			_types.length = 0;
			_types = null;
			
			_methodBodies.length = 0;
			_methodBodies = null;
			
			_methodBodiesBuffer.length = 0;
			_methodBodiesBuffer = null;
			
			_methodBodiesWriter.dispose();
			_methodBodiesWriter = null;
		}
		
		public function write(output : IDataOutput) : void
		{
  			_readOnly = true;
			
			try
			{
				const writer : IByteCodeWriter = new ByteCodeWriter(output);
				
				// Version
				writer.writeU16(_minorVersion);
				writer.writeU16(_majorVersion);
				
				writeConstantPool(writer);
				
				writeMethods(writer);
				
				writeMetadata(writer);
				
				writeClasses(writer);
				
				writeMethodBodies(writer);
			}
			catch(error : Error)
			{
				// Something went wrong.
			}
			finally
			{
				_readOnly = false;
			}
		}
		
		public function registerInteger(value : int) : uint
		{
			return assertArrayIndex(_integers, value);
		}
		
		public function registerUInteger(value : uint) : uint
		{
			return assertArrayIndex(_uintegers, value);
		}
		
		public function registerDouble(value : Number) : uint
		{
			return assertArrayIndex(_doubles, value);
		}
		
		public function registerString(value : String) : uint
		{
			return assertArrayIndex(_strings, value);
		}
		
		public function registerClass(value : Type) : uint
		{
			const index : uint = assertArrayIndex(_types, value);
			
			registerTypeMultiname(value);
			registerMultiname(value.multiNamespaceName);
			registerNamespace(value.typeNamespace);
			
			registerMethod(value.scriptInitialiser);
			registerMethod(value.staticInitialiser);
			registerMethod(value.constructor);
			
			for each(var method : MethodInfo in value.getMethods())
			{
				registerMethod(method);
			}
			
			for each(var property : PropertyInfo in value.getProperties())
			{
				registerString(property.fullName);
				registerMultiname(property.qname);
				
				if (property.canRead)
				{
					registerMethod(property.getMethod);
				}
				
				if (property.canWrite)
				{
					registerMethod(property.setMethod);
				}
			}
			
			for each(var field : FieldInfo in value.getFields())
			{
				registerTypeMultiname(field.type);
			}
			
			return index;
		}
		
		public function registerMethod(value : MethodInfo) : uint
		{
			registerString(value.name);
			registerString(value.fullName);
			registerMultiname(value.qname);
			registerTypeMultiname(value.returnType);
			
			for each(var param : ParameterInfo in value.parameters)
			{
				registerTypeMultiname(param.type);
				registerString(param.name);
			}
			
			return assertArrayIndex(_methods, value);
		}
		
		public function registerMethodBody(method : MethodInfo, value : DynamicMethod) : uint
		{
			var index : int = _methodBodies.indexOf(value);
			
			if (index == -1)
			{
				index = _methodBodies.push(value);
			
				_methodBodiesWriter.writeU30(registerMethod(method));
				
				_methodBodiesWriter.writeU30(value.maxStack);
				_methodBodiesWriter.writeU30(value.maxLocal);
				_methodBodiesWriter.writeU30(value.minScope);
				_methodBodiesWriter.writeU30(value.maxScope);
				
				var instruction : Array = null;
				
				const instructionBuffer : ByteArray = new ByteArray();
				const instructionWriter : IByteCodeWriter = new ByteCodeWriter(instructionBuffer);
				
				for each(instruction in value.instructionSet)
				{
					instructionWriter.writeU8(instruction[0]);
					
					var paramTypesObj : Object = _instructionParamTypes[instruction[0]];
					
					if (paramTypesObj is Function)
					{
						Function(paramTypesObj)(instruction, instructionWriter);
					}
					else if (paramTypesObj is Array)
					{
						var paramTypes : Array = paramTypesObj as Array;
					
						const total : int = paramTypes.length;
						for (var i : int = 0; i<total; i++)
						{
							var paramType : uint = paramTypes[i];
							var paramVal : Object = instruction[i + 1];
							
							switch(paramType)
							{
								case InstructionArgumentType.Integer:
									instructionWriter.writeU30(registerInteger(paramVal as int));
									break;
								case InstructionArgumentType.UInteger:
									instructionWriter.writeU30(registerUInteger(paramVal as uint));
									break;
								case InstructionArgumentType.Double:
									instructionWriter.writeU30(registerDouble(paramVal as Number));
									break;
								case InstructionArgumentType.String:
									instructionWriter.writeU30(registerString(paramVal as String));
									break;
								case InstructionArgumentType.Class:
									instructionWriter.writeU30(registerClass(Type(paramVal)));
									break;
								case InstructionArgumentType.Method:
									instructionWriter.writeU30(registerMethod(MethodInfo(paramVal)));
									break;
								case InstructionArgumentType.Multiname:
									instructionWriter.writeU30(registerMultiname(Multiname(paramVal)));
									break;
								case InstructionArgumentType.U8:
									instructionWriter.writeU8(paramVal as uint);
									break;
								case InstructionArgumentType.U30:
									instructionWriter.writeU30(paramVal as uint);
									break;
								case InstructionArgumentType.S24:
									instructionWriter.writeS24(paramVal as int);
									break;
								default:
									throw new IllegalOperationError("Unsupported argument type: " 
																					+ paramType);
							}
						}
					}
				}
				
				instructionBuffer.position = 0;
				
				var codeLength : uint = instructionBuffer.bytesAvailable;
				
				_methodBodiesWriter.writeU30(codeLength);
				_methodBodiesWriter.writeBytes(instructionBuffer, 0, codeLength);
				
				// TODO: Support exceptions
				_methodBodiesWriter.writeU30(0);
				
				// TODO: Supports trait (presumably inline functions?)
				_methodBodiesWriter.writeU30(0);				
			}
			
			return index;
		}
		
		public function registerMultiname(value : Multiname) : uint
		{
			return assertEqArrayIndex(_multinames, value, function():Array
			{
				switch(value.kind)
				{
					case MultinameKind.QUALIFIED_NAME:
					case MultinameKind.QUALIFIED_NAME_ATTRIBUTE:
						var qname : QualifiedName = value as QualifiedName;
						return [value.kind,
								registerNamespace(qname.ns),								 
								registerString(qname.name)];
						
					case MultinameKind.MULTINAME:
					case MultinameKind.MULTINAME_ATTRIBUTE:
						var mname : MultipleNamespaceName = value as MultipleNamespaceName;
						return [value.kind, 
								registerString(mname.name),
								registerNamespaceSet(mname.namespaceSet)];
								
					case MultinameKind.MULTINAME_LATE:
					case MultinameKind.MULTINAME_LATE_ATTRIBUTE:
						var mnamel : MultipleNamespaceNameLate = value as MultipleNamespaceNameLate;
						return [value.kind, registerNamespaceSet(mnamel.namespaceSet)];
						
					case MultinameKind.RUNTIME_QUALIFIED_NAME:
					case MultinameKind.RUNTIME_QUALIFIED_NAME_ATTRIBUTE:
						var rtqname : RuntimeQualifiedName = value as RuntimeQualifiedName;
						return [value.kind, registerString(rtqname.name)];
						
				 	case MultinameKind.RUNTIME_QUALIFIED_NAME_LATE:
					case MultinameKind.RUNTIME_QUALIFIED_NAME_LATE_ATTRIBUTE:
						return [value.kind];
					
					case MultinameKind.GENERIC:
						var gen : GenericName = value as GenericName;
						var arr : Array = [	value.kind, 
											registerMultiname(gen.typeDefinition), 
											gen.genericParameters.length
											];
											
						for each(var mn : Multiname in gen.genericParameters)
						{
							arr.push(registerMultiname(mn));
						}
						
						return arr;
						
					default:
						throw new IllegalOperationError("Invalid multiname kind");
				}
			});
		}
		
		public function registerNamespace(value : BCNamespace) : uint
		{
			return assertEqArrayIndex(_namespaces, value, function():Array
			{
				return [
					value.kind,
					registerString(value.name)
				];
			});
		}
		
		public function registerNamespaceSet(value : NamespaceSet) : uint
		{
			return assertEqArrayIndex(_namespaceSets, value, function():Array
			{
				var indexValues : Array = new Array();
				
				for each(var ns : BCNamespace in value.namespaces)
				{
					indexValues.push(registerNamespace(ns));
				}
				
				return indexValues;
			});
		}
		
		private function registerTypeMultiname(type : Type) : void
		{
			if (type.isGeneric)
			{
				registerMultiname(type.genericTypeDefinition.multiname);
			}
			
			registerMultiname(type.multiname);
		}
		
		private function writeConstantPool(output : IByteCodeWriter) : void
		{
			writeArray(_integers, output, output.writeS32, 1);
			writeArray(_uintegers, output, output.writeU32, 1);
			writeArray(_doubles, output, output.writeD64, 1);
			writeArray(_strings, output, output.writeString, 1);
			
			writeIndexedArray(_namespaces, output, function(ns : Array) : void
			{
				output.writeU8(ns[0]);
				output.writeU30(ns[1]);
			}, 1);
			
			writeIndexedArray(_namespaceSets, output, function(namespaceSet : Array) : void
			{
				output.writeU30(namespaceSet.length);
				for each(var index : uint in namespaceSet)
					output.writeU30(index);
			}, 1);
			
			writeIndexedArray(_multinames, output, function(multiname : Array) : void
			{
				output.writeU8(multiname[0]);
				
				const total : int = multiname.length;
				for (var i : int = 1; i < total; i++)
					output.writeU30(multiname[i]);
			}, 1);
		}
				
		private function writeMethods(output : IByteCodeWriter) : void
		{
			var param : ParameterInfo = null;
			
			output.writeU30(_methods.length);
			
			for each(var method : MethodInfo in _methods)
			{
				const params : Array = [].concat(method.parameters);
				const needsRest : Boolean = needsRest(method);
				
				if (needsRest) params.pop();
				
				output.writeU30(params.length);
				output.writeU30(registerMultiname(method.returnType.multiname));
				
				var optionalArgsCount : int = 0;
				
				const paramCount : int = params.length;
				for (var i : int = 0; i<paramCount; i++)
				{
					param = method.parameters[i];
					
					if (param.optional) optionalArgsCount++;
					
					output.writeU30(registerMultiname(param.type.multiname));
				}
				
				output.writeU30(registerString(method.fullName));
				
				// TODO: Only specify NEED_ARGUMENTS if the method needs it... ?
				var flags : int = MethodFlags.HAS_PARAM_NAMES;
				
				if (needsRest)
				{
					flags |= MethodFlags.NEED_REST;
					params.pop();
				}
				else
				{
					flags |= MethodFlags.NEED_ARGUMENTS;
				}

				if (optionalArgsCount > 0) flags |= MethodFlags.HAS_OPTIONAL; 
				
				output.writeU8(flags);
				
				if (optionalArgsCount > 0)
				{
					output.writeU30(optionalArgsCount);
					
					for (var p:int=optionalArgsCount; p>0; p--)
					{
						// TODO: Determine optional value?
						
						output.writeU30(0);
						output.writeU8(0x0C); // Undefined
					}
				}
				
				for each(param in params)
				{
					output.writeU30(registerString(param.name));
				}
			}
		}
		
		private function needsRest(methodInfo : MethodInfo) : Boolean
		{
			for each(var param : ParameterInfo in methodInfo.parameters)
			{
				if (param.type == Type.rest)
				{
					return true;
				}
			}
			
			return false;
		}
		
		private function writeMetadata(output : IByteCodeWriter) : void
		{
			output.writeU30(0);
		}
		
		private function writeClasses(output : IByteCodeWriter) : void
		{
			output.writeU30(_types.length);
			
			var type : Type;
			var method : MethodInfo;
			
			for each(type in _types)
			{
				output.writeU30(registerMultiname(type.multiname));
				
				// No base type - 4.3 Instance / super_name
				if (type.baseType == null || type.baseType.fullName == "Object")
					output.writeU30(0);
				else
					output.writeU30(registerMultiname(type.baseType.multiname));
				
				const flags : int = getClassFlags(type);
				const hasProtectedNs : Boolean = ((flags & ClassFlags.PROTECTED_NAMESPACE) != 0);
				
				output.writeU8(flags);
				
				if (hasProtectedNs)
					output.writeU30(registerNamespace(type.typeNamespace));
				 
				const interfaces : Array = type.getInterfaces();
				output.writeU30(interfaces.length);
				
				for each(var interfaceType : Type in interfaces)
				{
					output.writeU30(registerMultiname(interfaceType.multiNamespaceName));
				}
				
				// iinit
				output.writeU30(registerMethod(type.constructor));
				
				// trait count
				output.writeU30(getTraitCount(type, false));
				
				for each(method in type.getMethods(false, true))
				{
					output.writeU30(registerMultiname(method.qname));
					output.writeU8(TraitKind.METHOD | (getMethodTraitAttributes(method) << 4));
					output.writeU30(0);
					output.writeU30(registerMethod(method));
				}
				
				for each(var property : PropertyInfo in type.getProperties(false, true))
				{
					if (property.canRead)
					{
						// Getter
						output.writeU30(registerMultiname(property.qname));
						output.writeU8(TraitKind.GETTER 
											| (getMethodTraitAttributes(property.getMethod) << 4));
						output.writeU30(0);
						output.writeU30(registerMethod(property.getMethod));
					}
					
					if (property.canWrite)
					{
						// Setter
						output.writeU30(registerMultiname(property.qname));
						output.writeU8(TraitKind.SETTER 
											| (getMethodTraitAttributes(property.setMethod) << 4));
						output.writeU30(0);
						output.writeU30(registerMethod(property.setMethod));
					}
				}
				
				for each(var field : FieldInfo in type.getFields(false, true))
				{
					// Getter 
					output.writeU30(registerMultiname(field.qname));
					output.writeU8(TraitKind.SLOT);
					output.writeU30(0);
					output.writeU30(registerMultiname(field.type.multiname));
					output.writeU30(0);
				}
			}
			
			for each(type in _types)
			{
				output.writeU30(registerMethod(type.staticInitialiser));
				
				const staticTraitCount : int = type.getMethods(true, false).length;
				
				output.writeU30(staticTraitCount);
				
				for each(method in type.getMethods(true, false))
				{
					output.writeU30(registerMultiname(method.qname));			
					output.writeU8(TraitKind.METHOD | (getMethodTraitAttributes(method) << 4)); // kind
					output.writeU30(0); // disp_id (optimisation disabled)
					output.writeU30(registerMethod(method));
				}
			}
			
			// Scripts
			output.writeU30(_types.length);
			
			for each(type in _types)
			{
				output.writeU30(registerMethod(type.scriptInitialiser));
				output.writeU30(1); // trait_count
				
				output.writeU30(registerMultiname(type.qname));
				output.writeU8(TraitKind.CLASS);
				output.writeU30(0); // slot_id, avm assigned
				output.writeU30(registerClass(type));
			}
		}
		
		private function getClassFlags(type : Type) : int
		{
			var flags : int = 0;
			
			if (type.typeNamespace.kind == NamespaceKind.PROTECTED_NAMESPACE)
				flags |= ClassFlags.PROTECTED_NAMESPACE;
			if (type.isInterface) 
				flags |= ClassFlags.INTERFACE;
			if (type.isFinal) 
				flags |= ClassFlags.FINAL;
			if (!type.isDynamic) 
				flags |= ClassFlags.SEALED;
			
			return flags;
		}
		
		private function getTraitCount(type : Type, staticMembers : Boolean) : uint 
		{
			var traitCount : int = 0;
			
			traitCount += type.getFields(staticMembers, !staticMembers).length;
			traitCount += type.getMethods(staticMembers, !staticMembers).length;
			
			for each(var property : PropertyInfo in type.getProperties(staticMembers, !staticMembers))
			{
				if (property.canRead)
					traitCount++;
				
				if (property.canWrite)
					traitCount++;
			}
			
			return traitCount;
		}
		
		private function getMethodTraitAttributes(method : MethodInfo) : int
		{
			var attributes : int = 0;
			if (method.isOverride)
				attributes |= TraitAttribute.OVERRIDE;
			return attributes;
		}
		
		private function writeMethodBodies(output : IByteCodeWriter) : void
		{
			output.writeU30(_methodBodies.length);
			
			_methodBodiesBuffer.position = 0;
			output.writeBytes(_methodBodiesBuffer);
		}
		
		private function writeArray(	array : Array, 
										output : IByteCodeWriter, 
										writeFunc : Function, 
										startIndex : int = 0
										) : void
		{
			output.writeU30(array.length);
			
			const total : int = array.length;
			for (var i : int = startIndex; i<total; i++)	
			{
				writeFunc(array[i]);
			}
		}
		
		private function writeIndexedArray(	array : Array, 
											output : IByteCodeWriter, 
											writeFunc : Function, 
											startIndex : int = 0
											) : void
		{
			output.writeU30(array.length);
			
			const total : int = array.length;
			for (var i : int = startIndex; i<total; i++)	
			{
				const indexedObject : IndexedObject = array[i];
				writeFunc(indexedObject.data);
			}
		}
		
		private function assertEqArrayIndex(	array : Array, 
												value : IEqualityComparable, 
												dataCallback : Function
												) : int
		{
			const total : int = array.length;
			for (var i : int =0; i<total; i++)
			{
				const indexedObject : IndexedObject = array[i];
				if (value.equals(indexedObject.object))
					return i;
			}
			
			if (_readOnly)
				throw new IllegalOperationError("Cannot register a new item when the " + 
																			"instance is readonly");
			
			const indexedObj : IndexedObject = new IndexedObject();
			indexedObj.object = value;
			indexedObj.data = dataCallback();
			
			return array.push(indexedObj) - 1;
		}
		
		private function assertArrayIndex(array : Array, value : Object) : uint
		{
			var index : int = array.indexOf(value);
			if (index == -1)
			{
				if (_readOnly)
					throw new IllegalOperationError("Cannot register a new item when the " + 
																			"instance is readonly");
				index = array.push(value) - 1;
			}
			return index;
		}

	}
}
import org.flemit.bytecode.IEqualityComparable;

class IndexedObject
{
	public var data : Array;
	public var object : IEqualityComparable;
}
