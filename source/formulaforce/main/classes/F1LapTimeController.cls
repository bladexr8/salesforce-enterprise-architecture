// Apex Controller to supply lap times data to the 
// f1LapTimes LWC
public with sharing class F1LapTimeController {
    
    @AuraEnabled(cacheable=true)
    public static List<F1_Lap_Time__dlm> getLapTimes(String raceId) {
        try {
            if (String.isBlank(raceId)) {
                return new List<F1_Lap_Time__dlm>();
            }

            Integer raceIdInt = Integer.valueOf(raceId);
            
            // Query the Data Cloud DMO
            // Note: The exact syntax may vary based on your Data Cloud setup
            List<F1_Lap_Time__dlm> lapTimes = [
                SELECT 
                    Id,
                    driver_name__c,
                    lap__c,
                    milliseconds__c,
                    position__c,
                    raceid__c,
                    time__c
                FROM F1_Lap_Time__dlm
                WHERE raceid__c = :raceIdInt
                ORDER BY driver_name__c ASC, lap__c ASC
                LIMIT 3000
            ];
            
            return lapTimes;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving lap times: ' + e.getMessage());
        }
    }
}