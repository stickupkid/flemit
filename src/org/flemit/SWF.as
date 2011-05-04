package org.flemit
{
	import org.flemit.tags.ITag;
	
	public class SWF
	{

		private var _header : SWFHeader;

		private var _tags : Vector.<ITag>;

		public function SWF(header : SWFHeader, tags : Vector.<ITag>)
		{
			_header = header;
			_tags = tags;
		}

		public function get header() : SWFHeader { return _header; }

		public function get tags() : Vector.<ITag> { return _tags; }
	}
}