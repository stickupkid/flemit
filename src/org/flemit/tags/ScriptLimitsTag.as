package org.flemit.tags
{
	import org.flemit.ISWFOutput;
	import org.flemit.Tag;
	
	
	public final class ScriptLimitsTag extends Tag
	{
		public static const TAG_ID : int = 0x41;
		
		private var _maxRecursionDepth : int;
		
		private var _scriptTimeoutSeconds : int;
		
		public function ScriptLimitsTag(	maxRecursionDepth : int = 1000, 
											scriptTimeoutSeconds : int = 60
											)
		{
			super(TAG_ID);
			
			_maxRecursionDepth = maxRecursionDepth;
			_scriptTimeoutSeconds = scriptTimeoutSeconds;
		}
		
		public override function writeData(output : ISWFOutput):void		
		{
			output.writeUI16(_maxRecursionDepth);
			output.writeUI16(_scriptTimeoutSeconds);
		}
		
		public function get maxRecursionDepth() : int { return _maxRecursionDepth; }
		public function set maxRecursionDepth(value : int) : void { _maxRecursionDepth = value; }
		
		public function get scriptTimeoutSeconds() : int { return _scriptTimeoutSeconds; }
		public function set scriptTimeoutSeconds(value : int) : void 
		{ 
			_scriptTimeoutSeconds = value; 
		}
	}
}