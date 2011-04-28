package org.flemit.util
{
	import org.flemit.reflection.MethodInfo;
	import org.flemit.reflection.ParameterInfo;
	
	public final class MethodUtil
	{
		
		public static function getRequiredArgumentCount(method :  MethodInfo) : uint
		{
			const total : int = method.parameters.length;
			for (var i : int = 0; i<total; i++)
			{
				const param : ParameterInfo = method.parameters[i];
				if (param.optional)
					return i;
			}
			return total;
		}
	}
}