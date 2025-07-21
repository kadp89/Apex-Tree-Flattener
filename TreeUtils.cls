public with sharing class TreeUtils {
    public TreeUtils() {

    }
    /* 
     * A function which flattens all nested data into nestedTree[n].get(key), preserving relationships in dot notation
     * @param nestedTree is a List<Object> containing one or more Map<String,Object>
     * @return void
     * Side Effects: mutates its parameter in place
     * Constraints: asynchronous calls require a helper function; all data must be in tree format; 
     *              strongly suggest first transforming the results of a deserializeUntyped() call
     *              to be a list of root nodes, each root node an independent object without any 
     *              encapsulating closure... in other words, strip metadata manually and pass in
     *              the tree yourself; logic for detecting metadata fields across unstandardized
     *              JSON formats is incredibly odious and I couldn't find an elegant way to solve 
     *              for all possible metadata configurations programmatically
     */
    public static void flattenTree(List<Object> nestedTree) {
        if (nestedTree == null || nestedTree.isEmpty()) return;
        final String DOT = '.';
        for (Object o : nestedTree) {
            List<Object> stackPointer = new List<Object>();
            List<Object> stackData = new List<Object>();
            // pathHolder invariant:
            // - always ends with DOT if not empty
            // - keys are appended with DOT between levels
            // - during descent: append key, then DOT
            // - during ascent: truncate via two substringBeforeLast(DOT) calls
            // - maximally resource-efficient; chosen over stack for handling arbitrarily-large datasets
            // - pathHolder logic is VERY FRAGILE and difficult to reason about ex nihilo
            String pathHolder = '';
            // SEE ABOVE COMMENT; HERE BE DRAGONS
            String curKey;
            Map<String,Object> rootNode = (Map<String,Object>) o;
            List<String> rootKeys = new List<String>(rootNode.keySet());
            stackPointer.add(rootNode);
            stackData.add(rootKeys);
            while (!(stackPointer.isEmpty())) {
                Boolean ascendFlag = false;
                Object curVal;
                if (!stackData.isEmpty() && !((List<String>)stackData[0]).isEmpty()) {
                    curKey = ((List<String>)stackData[0]).remove(0);
                    curVal = ((Map<String,Object>)stackPointer[0])?.get(curKey);
                    pathHolder += curKey;
                    ascendFlag = false;
                } else {
                    ascendFlag = true;
                }
                if (curVal instanceof Map<String,Object>) {
                    stackPointer.add(0, curVal);
                    stackData.add(0, new List<String>(((Map<String,Object>)stackPointer[0]).keySet()));
                    pathHolder += DOT;
                    if (stackPointer.size() == 1) 
                        rootNode.remove(curKey);
                }
                /* 
                 * This is a somewhat ugly hack; if an array is detected:
                 *  - iterate through array
                 *  - for each element, append to pathHolder an array format and index ([i])
                 *  - store in putString
                 *  - put putString to the root node and add to root keyset
                 *  - from there, the main logic can handle all permutations
                 */
                else if (curVal instanceof List<Object>) {
                    List<Object> curList = (List<Object>) curVal;
                    for(Integer i = curList.size(); --i >= 0; i += 0) {
                        String putString = pathHolder + '[' + i + ']'; // parent.child[i] or parent.child[n][m]...[i]
                        rootNode.put(putString, curList[i]);
                        rootKeys.add(putString);
                        curList.remove(i);
                    }
                }
                if (!(curVal instanceof Map<String,Object>)) {
                    if (stackPointer.size() == 1) 
                        pathHolder = '';
                    else { 
                        if (curVal != null && !(curVal instanceof List<Object>) && !(curVal instanceof Map<String,Object>)) 
                            rootNode.put(pathHolder, curVal);
                        pathHolder = pathHolder.substringBeforeLast(DOT) + DOT;
                    }
                }
                if (ascendFlag) {
                    stackPointer.remove(0);
                    stackData.remove(0); 
                    // Ascending trims one level of key + trailing DOT (e.g., from "a.b.c." to "a.b.")
                    pathHolder = pathHolder.substringBeforeLast(DOT).substringBeforeLast(DOT) + DOT;
                    if (stackPointer.size() == 1) 
                        pathHolder = '';
                }
            }
        }
    }
    public static void flattenTreeSingle(Map<String, Object> singleNode) {
        if (singleNode == null) 
            return;
        List<Object> singletonList = new List<Object>{ singleNode };
        flattenTree(singletonList);
    }
}