public class F1DataCloudSyncQualifyingBatch implements Database.Batchable<SObject>, Database.Stateful  {
    
     private List<SObject> recordsToProcess;
    private F1DataCloudUpsertService.UpsertConfig config;
    private List<F1DataCloudUpsertService.UpsertResult> batchResults;
    
    public F1DataCloudSyncQualifyingBatch(List<SObject> records, F1DataCloudUpsertService.UpsertConfig upsertConfig) {
        this.recordsToProcess = records;
        this.config = upsertConfig;
        this.batchResults = new List<F1DataCloudUpsertService.UpsertResult>();
    }

    public Iterable<SObject> start(Database.BatchableContext BC) {
        return recordsToProcess;
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> batch) {

        List<F1_Qualifying__dlm> dataCloudQuals = new List<F1_Qualifying__dlm>();
        List<Qualifying__c> dataCloudQualsToUpsert = new List<Qualifying__c>();

        dataCloudQuals.addAll((List<F1_Qualifying__dlm>)batch);
        
        // convert to Pit Stop records
        for (F1_Qualifying__dlm f1Qual : dataCloudQuals) {

                Qualifying__c newQual = new Qualifying__c(
                    Data_Cloud_Id__c = Integer.valueOf(f1Qual.qualifyid__c).toString(),
                    Number__c = f1Qual.number__c,
                    Position__c = f1Qual.position__c,
                    Qualifying_1_Time__c = f1Qual.q1__c,
                    Qualifying_2_Time__c = f1Qual.q2__c,
                    Qualifying_3_Time__c = f1Qual.q3__c
                );
                // Race__c
                // Driver__c
                // Team__c
                // Link to existing Race using External ID relationship
                if(!String.isBlank(Integer.valueOf(f1Qual.raceid__c).toString())) {
                    Race__c race = new Race__c();
                    race.Data_Cloud_Id__c = Integer.valueOf(f1Qual.raceid__c).toString();
                    newQual.Race__r = race; // This creates the relationship link
                }
                // Link to existing Driver using External ID relationship
                if(!String.isBlank(Integer.valueOf(f1Qual.driverid__c).toString())) {
                    Driver__c driver = new Driver__c();
                    driver.Data_Cloud_Id__c = Integer.valueOf(f1Qual.driverid__c).toString();
                    newQual.Driver__r = driver; // This creates the relationship link
                }
                // Link to existing Team using External ID relationship
                if(!String.isBlank(Integer.valueOf(f1Qual.constructorid__c).toString())) {
                    Team__c team = new Team__c();
                    team.Data_Cloud_Id__c = Integer.valueOf(f1Qual.constructorid__c).toString();
                    newQual.Team__r = team; // This creates the relationship link
                }
                dataCloudQualsToUpsert.add(newQual);
        }

        // prepare and upsert contestant records
        List<SObject> records = new List<SObject>();
        records.addAll(dataCloudQualsToUpsert);

        F1DataCloudUpsertService.UpsertResult result = F1DataCloudUpsertService.upsertRecords(records, config);
        batchResults.add(result);
        
        System.debug('Batch processed: ' + result.recordsCreated + ' created, ' + 
                    result.recordsUpdated + ' updated, ' + result.recordsFailed + ' failed'); 
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