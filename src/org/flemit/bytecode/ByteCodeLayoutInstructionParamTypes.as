package org.flemit.bytecode
{
	import org.flemit.reflection.MethodInfo;

	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;

	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	internal final class ByteCodeLayoutInstructionParamTypes
	{

		internal static function getInstructionParamTypes() : Dictionary
		{
			const dict : Dictionary = new Dictionary();

			const clazz : int = InstructionArgumentType.Class;
			const method : int = InstructionArgumentType.Method;
			const multiname : int = InstructionArgumentType.Multiname;
			const u30 : int = InstructionArgumentType.U30;
			const integer : int = InstructionArgumentType.Integer;
			const uInteger : int = InstructionArgumentType.UInteger;
			const double : int = InstructionArgumentType.Double;
			const string : int = InstructionArgumentType.String;
			const u8 : int = InstructionArgumentType.U8;
			const s24 : int = InstructionArgumentType.S24;

			dict[Instructions.AsType] = [multiname];
			dict[Instructions.Call] = [u30];
			dict[Instructions.CallMethod] = [method, u30];
			dict[Instructions.CallProperty] = [multiname, u30];
			dict[Instructions.CallPropLex] = [multiname, u30];
			dict[Instructions.CallPropVoid] = [multiname, u30];
			dict[Instructions.CallStatic] = [method, u30];
			dict[Instructions.CallSuper] = [multiname, u30];
			dict[Instructions.CallSuperVoid] = [multiname, u30];
			dict[Instructions.Coerce] = [multiname];
			dict[Instructions.Construct] = [u30];
			dict[Instructions.ConstructProp] = [multiname, u30];
			dict[Instructions.ConstructSuper] = [u30];
			dict[Instructions.Debug] = [u8, string, u8, u30];
			dict[Instructions.DebugFile] = [string];
			dict[Instructions.DebugLine] = [u30];
			dict[Instructions.DecrementLocal] = [u30];
			dict[Instructions.DecrementLocalInteger] = [u30];
			dict[Instructions.DeleteProperty] = [multiname];
			dict[Instructions.DefaultXMLNamespace] = [string];
			dict[Instructions.FindProperty] = [multiname];
			dict[Instructions.FindPropertyStrict] = [multiname];
			dict[Instructions.GetDescendants] = [multiname];
			dict[Instructions.GetGlobalSlot] = [u30];
			dict[Instructions.GetLex] = [multiname];
			dict[Instructions.GetLocal] = [u30];
			dict[Instructions.GetProperty] = [multiname];
			dict[Instructions.GetScopeObject] = [u8];
			dict[Instructions.GetSlot] = [u30];
			dict[Instructions.GetSuper] = [multiname];
			dict[Instructions.HasNext2] = [u30, u30]; // ?
			dict[Instructions.IfEquals] = [s24];
			dict[Instructions.IfFalse] = [s24];
			dict[Instructions.IfGreaterThanOrEquals] = [s24];
			dict[Instructions.IfGreaterThan] = [s24];
			dict[Instructions.IfLessThanOrEquals] = [s24];
			dict[Instructions.IfLessThan] = [s24];
			dict[Instructions.IfNotGreaterThanOrEquals] = [s24];
			dict[Instructions.IfNotGreaterThan] = [s24];
			dict[Instructions.IfNotLessThanOrEquals] = [s24];
			dict[Instructions.IfNotLessThan] = [s24];
			dict[Instructions.IfNotEquals] = [s24];
			dict[Instructions.IfStrictEquals] = [s24];
			dict[Instructions.IfStrictNotEquals] = [s24];
			dict[Instructions.IfTrue] = [s24];
			dict[Instructions.IncrementLocal] = [u30];
			dict[Instructions.IncrementLocalInteger] = [u30];
			dict[Instructions.InitProperty] = [multiname];
			dict[Instructions.IsType] = [multiname];
			dict[Instructions.Jump] = [s24];
			dict[Instructions.Kill] = [u30];
			dict[Instructions.LookUpSwitch] = notSupportedInstructionHandler;
			dict[Instructions.NewArray] = [u30];
			dict[Instructions.NewCatch] = notSupportedInstructionHandler;
			dict[Instructions.NewClass] = [clazz];
			dict[Instructions.NewFunction] = [MethodInfo];
			dict[Instructions.NewObject] = [u30];
			dict[Instructions.PushByte] = [u8];
			dict[Instructions.PushDouble] = [double];
			dict[Instructions.PushInt] = [integer];
			dict[Instructions.PushNamespace] = [Namespace];
			dict[Instructions.PushShort] = [u30];
			dict[Instructions.PushString] = [string];
			dict[Instructions.PushUInt] = [uInteger];
			dict[Instructions.SetLocal] = [u30];
			dict[Instructions.SetGlobalSlot] = [u30];
			dict[Instructions.SetProperty] = [multiname];
			dict[Instructions.SetSlot] = [u30];
			dict[Instructions.SetSuper] = [multiname];

			return dict;
		}
		
		private static function notSupportedInstructionHandler(instruction : Array) : void
		{
			throw new IllegalOperationError("Operation (" + instruction[0] + ") not supported");
		}
	}
}
