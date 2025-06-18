@isTest
public class F1LapTimeControllerTest {
    
    @isTest
    static void testGetLapTimes() {
        // Note: You'll need to create test data for your DMO
        // This is a basic structure - adapt based on your DMO setup
        
        Test.startTest();
        
        // Test with valid race ID
        List<F1_Lap_Time__dlm> result = F1LapTimeController.getLapTimes('test-race-id');
        
        // Test with null race ID
        List<F1_Lap_Time__dlm> emptyResult = F1LapTimeController.getLapTimes(null);
        System.assertEquals(0, emptyResult.size(), 'Should return empty list for null race ID');
        
        // Test with blank race ID
        List<F1_Lap_Time__dlm> blankResult = F1LapTimeController.getLapTimes('');
        System.assertEquals(0, blankResult.size(), 'Should return empty list for blank race ID');
        
        Test.stopTest();
        
        // Add assertions based on your test data
        Assert.isNotNull(result, 'Result should not be null');
    }
}