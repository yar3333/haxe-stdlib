import stdlib.Utf8;

class Test extends haxe.unit.TestCase
{
    static function main()
	{
		var r = new haxe.unit.TestRunner();
		r.add(new Test());
		r.run();
	}
	
	function test_utf8()
	{
		assertEquals("a&amp;b", Utf8.htmlEscape("a&b"));
		assertEquals("abc", Utf8.htmlEscape("abc"));
		assertEquals("ab&quot;c", Utf8.htmlEscape("ab\"c"));
		assertEquals("a\nb", Utf8.htmlEscape("a\nb"));
		assertEquals("a&#xA;b", Utf8.htmlEscape("a\nb", "\n"));
	}
}