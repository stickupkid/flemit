package org.flemit.tags
{
	import org.flemit.ISWFOutput;
	
	
	public final class FileAttributesTag extends Tag
	{
		public static const TAG_ID : int = 0x45; 
		
		private var _useDirectBlit : Boolean = false;
		private var _useGPU : Boolean = false;
		private var _hasMetadata : Boolean = false;
		private var _actionScript3 : Boolean = true;
		private var _useNetwork : Boolean = true;
		
		private var _outputOrder : Array = [
			"reserved", "useDirectBlit", "useGPU", "hasMetadata", 
			"actionScript3", "reserved", "useNetwork", "reserved", 
			"reserved", "reserved", "reserved", "reserved", 
			"reserved", "reserved", "reserved", "reserved", 
			"reserved", "reserved", "reserved", "reserved",
			"reserved", "reserved", "reserved", "reserved", 
			"reserved", "reserved", "reserved", "reserved", 
			"reserved", "reserved", "reserved"
			];
		
		public function FileAttributesTag(	useDirectBlit : Boolean, 
											useGPU : Boolean, 
											hasMetadata : Boolean, 
											actionScript3 : Boolean, 
											useNetwork : Boolean)
		{
			super(TAG_ID);
			
			_useDirectBlit = useDirectBlit;
			_useGPU = useGPU;
			_hasMetadata = hasMetadata;
			_actionScript3 = actionScript3;
			_useNetwork = useNetwork;
		}
		
		public override function writeData(output : ISWFOutput):void		
		{
			for each(var prop : String in _outputOrder)
			{
				if(hasOwnProperty(prop))
					output.writeBit(this[prop] as Boolean);
				else
					output.writeBit(false);
			}
				
			output.align();
		}
		
		public function get useDirectBlit() : Boolean { return _useDirectBlit; }
		public function set useDirectBlit(value : Boolean) : void { _useDirectBlit = value; }
		
		public function get useGPU() : Boolean { return _useGPU; }
		public function set useGPU(value : Boolean) : void { _useGPU = value; }
		
		public function get hasMetadata() : Boolean { return _hasMetadata; }
		public function set hasMetadata(value : Boolean) : void { _hasMetadata = value; }
		
		public function get actionScript3() : Boolean { return _actionScript3; }
		public function set actionScript3(value : Boolean) : void { _actionScript3 = value; }
		
		public function get useNetwork() : Boolean { return _useNetwork; }
		public function set useNetwork(value : Boolean) : void { _useNetwork = value; }
	}
}