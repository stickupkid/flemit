package org.flemit
{
	import org.flemit.tags.ITag;

	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.IDataOutput;
	
	
	public class SWFWriter
	{
		// Right now I can't be bothered implementing framesize, framework or framecount
		private var _hardCodedHeader : Array = [0x78, 0x00, 0x04, 0xE2, 0x00, 0x00, 0x0E, 
												0xA6, 0x00, 0x00, 0x18, 0x01, 0x00];
		
		private var _compress : Boolean = false;
		
		private var _tagDataBuffer : ByteArray;
		
		private var _tagDataWriter : SWFOutput;
		
		public function SWFWriter()
		{
			_tagDataBuffer = new ByteArray();
			_tagDataWriter = new SWFOutput(_tagDataBuffer);
		}
		
		public function write(output : IDataOutput, header : SWFHeader, tags : Vector.<ITag>) : void
		{
			output.endian = Endian.BIG_ENDIAN;
			
			const buffer : ByteArray = new ByteArray();
			
			const bufferOutput : ISWFOutput = new SWFOutput(buffer);
			writeInternal(bufferOutput, header, tags);
			
			buffer.position = 0;
			
			const PRE_HEADER_SIZE : int = 8; // FWS[VERSION][FILESIZE]
			
			// FileSize is uncompressed
			const fileSize : int = buffer.bytesAvailable + PRE_HEADER_SIZE;
			const swfOutput : ISWFOutput = new SWFOutput(output);
			
			if (_compress)
			{
				buffer.compress();
				
				swfOutput.writeUI8("C".charCodeAt(0));
			}
			else swfOutput.writeUI8("F".charCodeAt(0));
			
			swfOutput.writeUI8("W".charCodeAt(0));
			swfOutput.writeUI8("S".charCodeAt(0));
			swfOutput.writeUI8(header.version);
			
			swfOutput.writeUI32(fileSize);

			buffer.position = 0;
			output.writeBytes(buffer, 0, buffer.bytesAvailable);
		}
		
		private function writeInternal(	output : ISWFOutput, 
										header : SWFHeader, 
										tags : Vector.<ITag>
										) : void
		{
			// TODO: Write the actual header here
			for each(var byte : int in _hardCodedHeader)
				output.writeUI8(byte);
			
			const total : int = tags.length;
			for(var i : int = 0; i<total; i++)
				writeTag(output, tags[i]);
		}
		
		private function writeTag(output : ISWFOutput, tag : ITag) : void
		{
			_tagDataBuffer.position = 0;
			
			tag.writeData(_tagDataWriter);
			
			const tagLength : uint = _tagDataBuffer.position;
			if (tagLength >= 63)
			{
				output.writeUI16( (tag.tagID << 6) | 0x3F );
				output.writeUI32( tagLength ); 
			}
			else output.writeUI16( (tag.tagID << 6) | tagLength );
			
			_tagDataBuffer.position = 0;
			
			if (tagLength > 0) output.writeBytes(_tagDataBuffer, 0, tagLength);
		}
				
		public function get compress() : Boolean { return _compress; }
		public function set compress(value : Boolean) : void { _compress = value; }
	}
}