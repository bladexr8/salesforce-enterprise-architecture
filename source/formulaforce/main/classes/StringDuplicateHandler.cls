public class StringDuplicateHandler {
    
    /**
     * Method to identify duplicate strings in a list
     * @param stringList - List of strings to check for duplicates
     * @return Map<String, Integer> - Map containing duplicate strings and their counts
     */
    public static Map<String, Integer> findDuplicates(List<String> stringList) {
        Set<String> seenStrings = new Set<String>();
        Map<String, Integer> duplicates = new Map<String, Integer>();
        
        for (String currentString : stringList) {
            if (currentString != null) { // Handle null values
                if (seenStrings.contains(currentString)) {
                    // String is a duplicate
                    if (duplicates.containsKey(currentString)) {
                        duplicates.put(currentString, duplicates.get(currentString) + 1);
                    } else {
                        duplicates.put(currentString, 2); // First time we identify it as duplicate
                    }
                } else {
                    seenStrings.add(currentString);
                }
            }
        }
        
        return duplicates;
    }
}
