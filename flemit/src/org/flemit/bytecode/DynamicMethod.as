package org.flemit.bytecode
{
	import org.flemit.reflection.MethodInfo;
	
	
	public final class DynamicMethod
	{
		private var _method : MethodInfo;
		
		private var _maxStack : int = 0;
		
		private var _minScope : int = 0;
		
		private var _maxScope : int = 0;
		
		private var _maxLocal : int = 0;
		
		private var _instructionSet : Array;
		
		public function DynamicMethod(
										method : MethodInfo, 
										maxStack : int, 
										maxLocal : int, 
										minScope : int, 
										maxScope : int, 
										instructions : Array
										)
		{
			_method = method;
			_minScope = minScope;
			_maxScope = maxScope;
			_maxLocal = maxLocal;
			_maxStack = maxStack;
			
			_instructionSet = instructions;
		}
		
		public function get instructionSet() : Array { return _instructionSet; }
		
		public function get method() : MethodInfo { return _method; }
		
		public function get maxStack() : int { return _maxStack; } 
		
		public function get minScope() : int { return _minScope; } 
		
		public function get maxScope() : int { return _maxScope; } 
		
		public function get maxLocal() : int { return _maxLocal; } 
	}
}