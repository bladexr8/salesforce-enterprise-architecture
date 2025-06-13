public class DuplicateIdChecker {
    
    public static void checkPitStopIds() {
        System.Debug(LoggingLevel.DEBUG,'Checking PitStop DMO external ids... Getting Ids from Data Cloud...');

        List<F1_Pit_Stop__dlm> dataCloudPitStops = new List<F1_Pit_Stop__dlm>();

        // Get data from Data Cloud 
        for ( F1_Pit_Stop__dlm f1PitStop : [
            SELECT
                external_id__c
            FROM F1_Pit_Stop__dlm
        ]) {
            dataCloudPitStops.add(f1PitStop);
        }

        System.Debug(LoggingLevel.DEBUG, 'Retrieved ' + dataCloudPitStops.size() + ' PitStop records from Data Cloud');

        List<string> idList = new List<String>();
        // build list of strings to check for duplicates
        for(F1_Pit_Stop__dlm pc: dataCloudPitStops) {
            idList.add(pc.external_id__c);
        }

        System.Debug(LoggingLevel.DEBUG, 'Constructed ' + idList.size() + ' list of Pit Stop External ids...');

        Map<String, Integer> duplicates = StringDuplicateHandler.findDuplicates(idList);

        System.Debug(LoggingLevel.DEBUG, 'Detected ' + duplicates.size() + ' Duplicates...');

        for (String duplicateString : duplicates.keySet()) {
            System.debug('DUPLICATE: "' + duplicateString + '" appears ' + duplicates.get(duplicateString) + ' times');
        }

    } 

    public static void checkPitStopIdsFromSF() {
        System.Debug(LoggingLevel.DEBUG,'Checking PitStop external ids... Getting Ids from SF...');

        List<Pit_Stop__c> PitStops = new List<Pit_Stop__c>();

        // Get data from Data Cloud 
        for ( Pit_Stop__c f1PitStop : [
            SELECT
                Data_Cloud_Id__c
            FROM Pit_Stop__c
        ]) {
            PitStops.add(f1PitStop);
        }

        System.Debug(LoggingLevel.DEBUG, 'Retrieved ' + PitStops.size() + ' PitStop records from SF');

        List<string> idList = new List<String>();
        // build list of strings to check for duplicates
        for(Pit_Stop__c pc: PitStops) {
            idList.add(pc.Data_Cloud_Id__c);
        }

        System.Debug(LoggingLevel.DEBUG, 'Constructed ' + idList.size() + ' list of Pit Stop External ids...');

        Map<String, Integer> duplicates = StringDuplicateHandler.findDuplicates(idList);

        System.Debug(LoggingLevel.DEBUG, 'Detected ' + duplicates.size() + ' Duplicates...');

        for (String duplicateString : duplicates.keySet()) {
            System.debug('DUPLICATE: "' + duplicateString + '" appears ' + duplicates.get(duplicateString) + ' times');
        }

    } 
}