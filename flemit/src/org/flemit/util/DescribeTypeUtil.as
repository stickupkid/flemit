package org.flemit.util
{
	import flash.utils.describeType;
	import flash.utils.Dictionary;
	/**
	 * @author Simon Richardson - simon@ustwo.co.uk
	 */
	public final class DescribeTypeUtil
	{
		public static const _descriptions : Dictionary = new Dictionary();
		
		public static function describe(item : *) : XML
		{
			if(null != _descriptions[item])
				return _descriptions[item];
			
			_descriptions[item] = describeType(item);
			return _descriptions[item];
		}
	}
}
