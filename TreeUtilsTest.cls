@IsTest
private class TreeUtilsTest {
    @IsTest
    static void testFlattenTreeWithAdversarialData() {
        // Construct a deeply nested and adversarially structured JSON-like map
        Map<String, Object> testNode = new Map<String, Object>();
        Map<String, Object> level1 = new Map<String, Object>();
        Map<String, Object> level2 = new Map<String, Object>();
        Map<String, Object> level3 = new Map<String, Object>();

        // Nested structure
        level3.put('key', 'value');
        level2.put('nested', level3);
        level1.put('inner', level2);
        testNode.put('root', level1);

        // Array with nested maps inside
        List<Object> mixedList = new List<Object>();
        Map<String, Object> arrayObj1 = new Map<String, Object>();
        arrayObj1.put('a', 'b');
        Map<String, Object> arrayObj2 = new Map<String, Object>();
        arrayObj2.put('c', new Map<String, Object>{'d' => 'e'});
        mixedList.add(arrayObj1);
        mixedList.add(arrayObj2);
        testNode.put('arrayField', mixedList);

        // Start test
        TreeUtils.flattenTreeSingle(testNode);

        // Basic asserts: check that flattened keys exist
        System.assertEquals('value', testNode.get('root.inner.nested.key'));
        System.assertEquals('b', testNode.get('arrayField[0].a'));
        System.assertEquals('e', testNode.get('arrayField[1].c.d'));
    }
}
