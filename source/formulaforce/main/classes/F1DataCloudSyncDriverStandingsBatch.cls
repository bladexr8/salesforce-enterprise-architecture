public class F1DataCloudSyncDriverStandingsBatch implements Database.Batchable<SObject>, Database.Stateful {

    private List<SObject> recordsToProcess;
    private F1DataCloudUpsertService.UpsertConfig config;
    private List<F1DataCloudUpsertService.UpsertResult> batchResults;
    
    public F1DataCloudSyncDriverStandingsBatch(List<SObject> records, F1DataCloudUpsertService.UpsertConfig upsertConfig) {
        this.recordsToProcess = records;
        this.config = upsertConfig;
        this.batchResults = new List<F1DataCloudUpsertService.UpsertResult>();
    }

    public Iterable<SObject> start(Database.BatchableContext BC) {
        return recordsToProcess;
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> batch) {

        List<F1_Driver_Standing__dlm> dataCloudDriverStandings = new List<F1_Driver_Standing__dlm>();
        List<Driver_Standing__c> dataCloudDriverStandingsToUpsert = new List<Driver_Standing__c>();

        dataCloudDriverStandings.addAll((List<F1_Driver_Standing__dlm>)batch);
        
        // convert to Team Standing records
        for (F1_Driver_Standing__dlm f1DriverStanding : dataCloudDriverStandings) {
                Driver_Standing__c newStanding = new Driver_Standing__c(
                    Data_Cloud_Id__c = Integer.valueOf(f1DriverStanding.driverstandingsid__c).toString(),
                    Championship_Points__c = f1DriverStanding.points__c,
                    Position__c = f1DriverStanding.position__c,
                    Position_Text__c = f1DriverStanding.positiontext__c,
                    Wins__c = f1DriverStanding.wins__c
                );
                // Race__c
                // Driver__c
                // Link to existing Race using External ID relationship
                if(!String.isBlank(Integer.valueOf(f1DriverStanding.raceid__c).toString())) {
                    Race__c race = new Race__c();
                    race.Data_Cloud_Id__c = Integer.valueOf(f1DriverStanding.raceid__c).toString();
                    newStanding.Race__r = race; // This creates the relationship link
                }
                // Link to existing Driver using External ID relationship
                if(!String.isBlank(Integer.valueOf(f1DriverStanding.driverid__c).toString())) {
                    Driver__c driver = new Driver__c();
                    driver.Data_Cloud_Id__c = Integer.valueOf(f1DriverStanding.driverid__c).toString();
                    newStanding.Driver__r = driver; // This creates the relationship link
                }
                dataCloudDriverStandingsToUpsert.add(newStanding);
        }

        // prepare and upsert contestant records
        List<SObject> records = new List<SObject>();
        records.addAll(dataCloudDriverStandingsToUpsert);

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
        
        System.debug('Team Standings Batch upsert completed - Created: ' + totalCreated + 
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