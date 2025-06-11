/**
 * Batch class for processing large upsert operations
 */
public class F1DataCloudSyncTeamStandingsBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    private List<SObject> recordsToProcess;
    private F1DataCloudUpsertService.UpsertConfig config;
    private List<F1DataCloudUpsertService.UpsertResult> batchResults;
    
    public F1DataCloudSyncTeamStandingsBatch(List<SObject> records, F1DataCloudUpsertService.UpsertConfig upsertConfig) {
        this.recordsToProcess = records;
        this.config = upsertConfig;
        this.batchResults = new List<F1DataCloudUpsertService.UpsertResult>();
    }
    
    public Iterable<SObject> start(Database.BatchableContext BC) {
        return recordsToProcess;
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> batch) {

        List<F1_Constructor_Standing__dlm> dataCloudConstructorStandings = new List<F1_Constructor_Standing__dlm>();
        List<Team_Standing__c> dataCloudTeamStandingsToUpsert = new List<Team_Standing__c>();

        dataCloudConstructorStandings.addAll((List<F1_Constructor_Standing__dlm>)batch);
        
        // convert to Team Standing records
        for (F1_Constructor_Standing__dlm f1ConstStanding : dataCloudConstructorStandings) {
                Team_Standing__c newStanding = new Team_Standing__c(
                    Data_Cloud_Id__c = Integer.valueOf(f1ConstStanding.constructorstandingsid__c).toString(),
                    Championship_Points__c = f1ConstStanding.points__c,
                    Position__c = f1ConstStanding.position__c,
                    Position_Text__c = f1ConstStanding.positiontext__c,
                    Wins__c = f1ConstStanding.wins__c
                );
                // Race__c
                // Team__c
                // Link to existing Race using External ID relationship
                if(!String.isBlank(Integer.valueOf(f1ConstStanding.raceid__c).toString())) {
                    Race__c race = new Race__c();
                    race.Data_Cloud_Id__c = Integer.valueOf(f1ConstStanding.raceid__c).toString();
                    newStanding.Race__r = race; // This creates the relationship link
                }
                // Link to existing Team using External ID relationship
                if(!String.isBlank(Integer.valueOf(f1ConstStanding.constructorid__c).toString())) {
                    Team__c team = new Team__c();
                    team.Data_Cloud_Id__c = Integer.valueOf(f1ConstStanding.constructorid__c).toString();
                    newStanding.Team__r = team; // This creates the relationship link
                }
                dataCloudTeamStandingsToUpsert.add(newStanding);
        }

        // prepare and upsert contestant records
        List<SObject> records = new List<SObject>();
        records.addAll(dataCloudTeamStandingsToUpsert);

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
        
        System.debug('Contestant Batch upsert completed - Created: ' + totalCreated + 
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