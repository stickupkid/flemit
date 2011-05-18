package org.flemit.bytecode
{
	import org.flemit.reflection.*;
	
	
	public interface IByteCodeLayoutBuilder
	{
		function registerType(type : Type) : void;
		
		function createLayout() : IByteCodeLayout;
		
		function dispose() : void;
	}
}