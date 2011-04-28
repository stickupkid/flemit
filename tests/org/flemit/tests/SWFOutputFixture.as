package org.flemit.tests
{
	import asunit.asserts.assertEquals;

	import org.flemit.SWFOutput;
	import org.flemit.tests.util.ByteArrayUtil;

	import flash.utils.ByteArray;
	
	public class SWFOutputFixture
	{
		private var buffer : ByteArray;
		private var output : SWFOutput;
		
		public function SWFOutputFixture()
		{
		}
		
		[Before]
		public function setupTestData():void
		{
			buffer = new ByteArray();
			output = new SWFOutput(buffer);
		}
		
		[Test]
		public function testWriteString() : void
		{
			output.writeString("a");
			assertEquals("Unexpected data written to output", "6100", getBufferString());
			
			output.writeString("test string");
			assertEquals("Unexpected data written to output", "7465737420737472696E6700", getBufferString());
		}
		
		[Test]
		public function testWriteSI8() : void
		{
			output.writeSI8(1);
			assertEquals("Unexpected data written to output", "01", getBufferString());
			
			output.writeSI8(128);
			assertEquals("Unexpected data written to output", "80", getBufferString());
			
			output.writeSI8(255);
			assertEquals("Unexpected data written to output", "FF", getBufferString());
			
			output.writeSI8(256);
			assertEquals("Unexpected data written to output", "00", getBufferString());
		}
		
		[Test]
		public function testWriteSI16() : void
		{
			output.writeSI16(1);
			assertEquals("Unexpected data written to output", "0100", getBufferString());
			
			output.writeSI16(256);
			assertEquals("Unexpected data written to output", "0001", getBufferString());
			
			output.writeSI16(-256);
			assertEquals("Unexpected data written to output", "00FF", getBufferString());
			
			output.writeSI16(65535);
			assertEquals("Unexpected data written to output", "FFFF", getBufferString());
			
			output.writeSI16(65536);
			assertEquals("Unexpected data written to output", "0000", getBufferString());
		}
		
		[Test]
		public function testWriteSI32() : void
		{
			output.writeSI32(1);
			assertEquals("Unexpected data written to output", "01000000", getBufferString());
			
			output.writeSI32(256);
			assertEquals("Unexpected data written to output", "00010000", getBufferString());
			
			output.writeSI32(65535);
			assertEquals("Unexpected data written to output", "FFFF0000", getBufferString());
			
			output.writeSI32(-65534);
			assertEquals("Unexpected data written to output", "0200FFFF", getBufferString());
			
			output.writeSI32(65536);
			assertEquals("Unexpected data written to output", "00000100", getBufferString());
			
			output.writeSI32(16777215);
			assertEquals("Unexpected data written to output", "FFFFFF00", getBufferString());
		}
		
		[Test]
		public function testWriteUI8() : void
		{
			output.writeUI8(1);
			assertEquals("Unexpected data written to output", "01", getBufferString());
			
			output.writeUI8(128);
			assertEquals("Unexpected data written to output", "80", getBufferString());
			
			output.writeUI8(255);
			assertEquals("Unexpected data written to output", "FF", getBufferString());
			
			output.writeUI8(256);
			assertEquals("Unexpected data written to output", "00", getBufferString());
		}
		
		[Test]
		public function testWriteUI16() : void
		{
			output.writeUI16(1);
			assertEquals("Unexpected data written to output", "0100", getBufferString());
			
			output.writeUI16(256);
			assertEquals("Unexpected data written to output", "0001", getBufferString());
			
			output.writeUI16(65535);
			assertEquals("Unexpected data written to output", "FFFF", getBufferString());
			
			output.writeUI16(65536);
			assertEquals("Unexpected data written to output", "0000", getBufferString());
		}
		
		[Test]
		public function testWriteUI32() : void
		{
			output.writeUI32(1);
			assertEquals("Unexpected data written to output", "01000000", getBufferString());
			
			output.writeUI32(256);
			assertEquals("Unexpected data written to output", "00010000", getBufferString());
			
			output.writeUI32(65535);
			assertEquals("Unexpected data written to output", "FFFF0000", getBufferString());
			
			output.writeUI32(65536);
			assertEquals("Unexpected data written to output", "00000100", getBufferString());
			
			output.writeUI32(16777215);
			assertEquals("Unexpected data written to output", "FFFFFF00", getBufferString());
		}
		
		[Test]
		public function testWriteBytes() : void
		{
			var tempBuffer : ByteArray = new ByteArray();
			tempBuffer.writeByte(0x01);
			tempBuffer.writeByte(0x02);
			tempBuffer.writeByte(0x03);
			tempBuffer.writeByte(0x04);
			tempBuffer.writeByte(0x05);
			tempBuffer.writeByte(0x06);
			
			output.writeBytes(tempBuffer, 3, 2);
			
			assertEquals("Unexpected data written to output", "0405", getBufferString());
		}
		
		[Test]
		public function testWriteBits() : void
		{
			output.writeBit(true);
			output.writeBit(false);
			output.writeBit(true);
			output.writeBit(false);
			output.writeBit(true);
			output.writeBit(false);
			output.writeBit(true);
			output.writeBit(false);
			// expect auto-align after 8 bits
			
			assertEquals("Unexpected data written to output", "AA", getBufferString());
		}
		
		[Test]
		public function testAlign() : void
		{
			output.writeBit(true);
			output.writeBit(false);
			output.writeBit(true);
			output.writeBit(false);
			output.align();
			output.writeBit(true);
			output.writeBit(false);
			output.writeBit(true);
			output.writeBit(false);
			// < 8 bits needs an align() to be committed
			
			assertEquals("Unexpected data written to output", "A0", getBufferString());
			
			output.writeBit(true);
			output.writeBit(false);
			output.writeBit(true);
			output.writeBit(false);
			output.align();
			output.writeBit(true);
			output.writeBit(false);
			output.writeBit(true);
			output.writeBit(false);
			output.align();
			
			assertEquals("Unexpected data written to output", "A0A0", getBufferString());
		}
		
		/**
		 * Tests that non-bit operations should flush any pending bit operations 
		 * out before writing their own data
		 */
		[Test]
		public function testAutoAlign() : void
		{
			testAutoAlignInternal(output.writeSI8, [127], "7F");
			testAutoAlignInternal(output.writeSI16, [1234], "D204");
			testAutoAlignInternal(output.writeSI32, [123456], "40E20100");
			testAutoAlignInternal(output.writeUI8, [255], "FF");
			testAutoAlignInternal(output.writeUI16, [1234], "D204");
			testAutoAlignInternal(output.writeUI32, [123456], "40E20100");
			
			var tempBuffer : ByteArray = new ByteArray();
			tempBuffer.writeByte(0x01);
			tempBuffer.writeByte(0x02);
			tempBuffer.writeByte(0x03);
			testAutoAlignInternal(output.writeBytes, [tempBuffer], "010203");

		}
		
		private function testAutoAlignInternal(func : Function, args : Array, expectedOutput : String) : void
		{
			output.writeBit(true);
			output.writeBit(false);
			output.writeBit(true);
			output.writeBit(false);
			
			func.apply(NaN, args);
			
			assertEquals("Unexpected data written to output", "A0" + expectedOutput, getBufferString());
		}
		
		private function getBufferString() : String
		{
			buffer.position = 0;
			var str : String = ByteArrayUtil.toString(buffer);
			
			buffer = new ByteArray();
			output = new SWFOutput(buffer);
			
			return str;
		}

	}
}