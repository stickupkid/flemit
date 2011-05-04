package org.flemit.tags
{
	import org.flemit.ISWFOutput;
	import org.flemit.bytecode.IByteCodeLayout;

	import flash.utils.ByteArray;
	
	
	/**
	 * Represents an AVM2 bytecode tag
	 */	
	public final class DoABCTag extends Tag
	{
		public static const TAG_ID : int = 0x52;
		
		private static const FLAGS_NONE : int = 0x0;
		
		private var _layout : IByteCodeLayout;
		
		private var _name : String;
		
		public function DoABCTag(name : String, layout : IByteCodeLayout)
		{
			super(TAG_ID);
			
			_layout = layout;
			_name = name;
		}
		
		public override function writeData(output : ISWFOutput):void
		{
			const flags : uint = getFlags();
			
			// flags
			output.writeUI32(flags);
			
			// name
			output.writeString(_name);
			
			const byteArray : ByteArray = new ByteArray();
			
			_layout.write(byteArray);
			
			byteArray.position = 0;			
			output.writeBytes(byteArray, 0, byteArray.bytesAvailable);
		}
		
		private function getFlags() : uint
		{
			return FLAGS_NONE;
		}
	}
}