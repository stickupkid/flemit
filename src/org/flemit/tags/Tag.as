package org.flemit.tags
{
	import org.flemit.ISWFOutput;

	import flash.errors.IllegalOperationError;

	public class Tag implements ITag
	{

		private var _tagID : int;

		private var _length : int;

		public function Tag(tagID : int, length : int = 0)
		{
			if(isNaN(tagID))
				throw new ArgumentError("Tag id can not be null or NaN");
			if(length < 0)
				throw new ArgumentError("Tag length should not be less than 0");
			
			_tagID = tagID;
			_length = length;
		}
		
		public function writeData(output : ISWFOutput) : void
		{
			throw new IllegalOperationError("Not implemented");
		}
		
		public function get tagID() : int {	return _tagID; }

		public function get length() : int { return _length; }
	}
}