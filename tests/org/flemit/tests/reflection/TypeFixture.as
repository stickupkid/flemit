package org.flemit.tests.reflection
{
	import asunit.asserts.assertNotNull;
	import asunit.asserts.assertTrue;

	import org.flemit.reflection.Type;
	
	public class TypeFixture
	{
		public function TypeFixture()
		{
		}
		
		[Test]
		public function test_getType_XML_supported() : void
		{
			var xml : XML = new XML();
			
			var type : Type = Type.getType(xml);
			
			assertNotNull(type);
		}
		
		[Test]
		public function test_class_support() : void 
		{
			var classType : Type = Type.getType(Class);
			var fixtureType : Type = Type.getType(TypeFixture);
			
			var ret : Boolean = classType.isAssignableFrom(fixtureType);
			
			assertTrue(ret);
		}

	}
}