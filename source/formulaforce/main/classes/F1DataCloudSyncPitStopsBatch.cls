public class F1DataCloudSyncPitStopsBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    private List<SObject> recordsToProcess;
    private F1DataCloudUpsertService.UpsertConfig config;
    private List<F1DataCloudUpsertService.UpsertResult> batchResults;
    
    public F1DataCloudSyncPitStopsBatch(List<SObject> records, F1DataCloudUpsertService.UpsertConfig upsertConfig) {
        this.recordsToProcess = records;
        this.config = upsertConfig;
        this.batchResults = new List<F1DataCloudUpsertService.UpsertResult>();
    }

    public Iterable<SObject> start(Database.BatchableContext BC) {
        return recordsToProcess;
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> batch) {

        List<F1_Pit_Stop__dlm> dataCloudPitStops = new List<F1_Pit_Stop__dlm>();
        List<Pit_Stop__c> dataCloudPitStopsToUpsert = new List<Pit_Stop__c>();

        dataCloudPitStops.addAll((List<F1_Pit_Stop__dlm>)batch);
        
        // convert to Pit Stop records
        for (F1_Pit_Stop__dlm f1PitStop : dataCloudPitStops) {

                Pit_Stop__c newPitStop = new Pit_Stop__c(
                    Data_Cloud_Id__c = f1PitStop.external_id__c,
                    Duration__c = f1PitStop.duration__c,
                    Lap__c = f1PitStop.lap__c,
                    Milliseconds__c = f1PitStop.milliseconds__c,
                    Stop__c = f1PitStop.STOP__c,
                    Time__c = f1PitStop.time__c,
                    temp_driver__c = Integer.valueOf(f1PitStop.driverid__c).toString(),
                    temp_raceid_c__c = Integer.valueOf(f1PitStop.raceid__c).toString()
                );
                // Race__c
                // Driver__c
                // Link to existing Race using External ID relationship
                /*if(!String.isBlank(Integer.valueOf(f1PitStop.raceid__c).toString())) {
                    Race__c race = new Race__c();
                    race.Data_Cloud_Id__c = Integer.valueOf(f1PitStop.raceid__c).toString();
                    newPitStop.Race__r = race; // This creates the relationship link
                }
                // Link to existing Driver using External ID relationship
                if(!String.isBlank(Integer.valueOf(f1PitStop.driverid__c).toString())) {
                    Driver__c driver = new Driver__c();
                    driver.Data_Cloud_Id__c = Integer.valueOf(f1PitStop.driverid__c).toString();
                    newPitStop.Driver__r = driver; // This creates the relationship link
                }*/
                dataCloudPitStopsToUpsert.add(newPitStop);
        }

        insert dataCloudPitStopsToUpsert;

        // prepare and upsert contestant records
        /*List<SObject> records = new List<SObject>();
        records.addAll(dataCloudPitStopsToUpsert);

        F1DataCloudUpsertService.UpsertResult result = F1DataCloudUpsertService.upsertRecords(records, config);
        batchResults.add(result);
        
        System.debug('Batch processed: ' + result.recordsCreated + ' created, ' + 
                    result.recordsUpdated + ' updated, ' + result.recordsFailed + ' failed'); */
    }
    
    public void finish(Database.BatchableContext BC) {
        // Summarize results
        Integer totalCreated = 0;
        Integer totalUpdated = 0;
        Integer totalFailed = 0;
        
        for (F1DataCloudUpsertService.UpsertResult result : batchResults) {
            totalCreated += result.recordsCreated;
            totalUpdated += result.recordsUpdated;
            totalFailed += result.recordsFailed;

            if (result.recordsFailed > 0) {
                for (F1DataCloudUpsertService.UpsertError error : result.errors) {
                    System.debug('Error: ' + error.errorCode + ' ' + error.errorMessage);
                    System.debug('Error record: ' + error.recordIdentifier);
                }
            }
        }
        
        System.debug('Pit Stops Batch upsert completed - Created: ' + totalCreated + 
                    ', Updated: ' + totalUpdated + ', Failed: ' + totalFailed);
        
        // Send notification email if needed
        if (totalFailed > 0) {
            sendErrorNotification(totalFailed);    
        }
    }
    
    private void sendErrorNotification(Integer failedRecords) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[]{'stephenmoss@brooke.global'});
        email.setSubject('Contestant Batch Upsert Errors Detected');
        email.setPlainTextBody('The contestant batch upsert operation completed with ' + failedRecords + ' failed records.');
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    }
}