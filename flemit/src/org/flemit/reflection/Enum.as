package org.flemit.reflection
{
	import org.flemit.util.DescribeTypeUtil;

	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	public final class Enum
	{
		
		private static var _index : Dictionary = new Dictionary(true);
		
		public function Enum()
		{
		}
		
		private static function indexEnum(enumClass : Class) : Dictionary
		{
			if (_index[enumClass] == null)
			{
				const dict : Dictionary = new Dictionary(false);
				
				for each(var constNode : XML in DescribeTypeUtil.describe(enumClass)..constant)
				{
					const fieldName : String = constNode.@name.toString();
					
					dict[enumClass[fieldName]] = fieldName;
				}
								
				_index[enumClass] = dict;
			}			
			
			return _index[enumClass] as Dictionary;
		}
		
		public static function getNames(enumClass : Class) : Array
		{
			const dict : Dictionary = indexEnum(enumClass);
			const names : Array = [];
			
			for each (var name : String in dict)  
			{
				names.push(name);
			}
			
			return names;
		}
		
		public static function getName(enumClass : Class, value : Object) : String
		{
			const dict : Dictionary = indexEnum(enumClass);
			
			if (dict[value] == null)
				throw new ArgumentError(getQualifiedClassName(enumClass) + 
										" does not define a name with value: " + value);
			
			return dict[value] as String;
		}
		
		public static function isDefined(enumClass : Class, value : Object) : Boolean
		{
			const dict : Dictionary = indexEnum(enumClass);
			return (dict[value] != null);
		}
	}
}