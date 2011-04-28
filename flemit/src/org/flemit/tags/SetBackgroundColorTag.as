package org.flemit.tags
{
	import org.flemit.ISWFOutput;
	import org.flemit.Tag;
	
	
	public final class SetBackgroundColorTag extends Tag
	{
		public static const TAG_ID : int = 0x9;
		
		private var _red : int;
		
		private var _green : int;
		
		private var _blue : int;
		
		public function SetBackgroundColorTag(red : int = 0, green : int = 0, blue : int = 0)
		{
			super(TAG_ID);
			
			if(red < 0)
				throw new ArgumentError('Red can not be less than 0.');
			if(green < 0)
				throw new ArgumentError('Green can not be less than 0.');
			if(blue < 0)
				throw new ArgumentError('Blue can not be less than 0.');	
			
			_red = red;
			_green = green;
			_blue = blue;
		}

		public override function writeData(output:ISWFOutput):void		
		{
			output.writeUI8(_red);
			output.writeUI8(_green);
			output.writeUI8(_blue);
		}
		
		public function get red() : int { return _red; }
		public function set red(value : int) : void { _red = value; }
		
		public function get green() : int { return _green; }
		public function set green(value : int) : void { _green = value; }
		
		public function get blue() : int { return _blue; }
		public function set blue(value : int) : void { _blue = value; }
	}
}