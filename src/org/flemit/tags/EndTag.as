package org.flemit.tags
{
	import org.flemit.ISWFOutput;
	
	public final class EndTag extends Tag
	{
		public static const TAG_ID : int = 0x0; 
		
		public function EndTag()
		{
			super(TAG_ID);
		}
		
		public override function writeData(output : ISWFOutput):void		
		{
		}
	}
}