package org.flemit.tags
{
	import org.flemit.ISWFOutput;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public interface ITag
	{
		
		function writeData(output : ISWFOutput) : void;
		
		function get tagID() : int;

		function get length() : int;
	}
}
