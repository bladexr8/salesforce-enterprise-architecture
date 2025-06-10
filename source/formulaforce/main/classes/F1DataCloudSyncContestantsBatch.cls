
/**
 * Batch class for processing large upsert operations
 */
public class F1DataCloudSyncContestantsBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    private List<SObject> recordsToProcess;
    private F1DataCloudUpsertService.UpsertConfig config;
    private List<F1DataCloudUpsertService.UpsertResult> batchResults;
    
    public F1DataCloudSyncContestantsBatch(List<SObject> records, F1DataCloudUpsertService.UpsertConfig upsertConfig) {
        this.recordsToProcess = records;
        this.config = upsertConfig;
        this.batchResults = new List<F1DataCloudUpsertService.UpsertResult>();
    }
    
    public Iterable<SObject> start(Database.BatchableContext BC) {
        /*string query = 'SELECT ' +
                        'constructorid__c, driverid__c, fastestlap__c, fastestlapspeed__c, fastestlaptime__c, ' +
                        'finishing_status__c, grid__c, laps__c, milliseconds__c, number__c, points__c,' +
                        'position__c, positionorder__c, positiontext__c, raceid__c, race_round__c, race_year__c, ' +
                        'resultid__c FROM F1_Race_Result__dlm';
        return Database.getQueryLocator(query);*/
        return recordsToProcess;
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> batch) {

        List<F1_Race_Result__dlm> dataCloudRaceResults = new List<F1_Race_Result__dlm>();
        List<Contestant__c> dataCloudContestantsToUpsert = new List<Contestant__c>();

        dataCloudRaceResults.addAll((List<F1_Race_Result__dlm>)batch);
        
        // convert to contestant records
        for (F1_Race_Result__dlm f1RaceResult : dataCloudRaceResults) {
                Contestant__c newContestant = new Contestant__c(
                    Data_Cloud_Id__c = Integer.valueOf(f1RaceResult.resultid__c).toString(),
                    Car_Number__c = (f1RaceResult.number__c != null) ? Integer.valueOf(f1RaceResult.number__c).toString() : '',
                    ChampionshipPoints__c = f1RaceResult.points__c,
                    Driver_Number__c = f1RaceResult.number__c,
                    Fastest_Lap__c = f1RaceResult.fastestlap__c,
                    Fastest_Lap_Speed__c = f1RaceResult.fastestlapspeed__c,
                    Fastest_Lap_Time__c = f1RaceResult.fastestlaptime__c,
                    Finishing_Status__c = f1RaceResult.finishing_status__c,
                    GridPosition__c = f1RaceResult.grid__c,
                    Laps_Completed__c = f1RaceResult.laps__c,
                    RacePosition__c = f1RaceResult.position__c,
                    Race_Position_Text__c = f1RaceResult.positiontext__c,
                    Race_Position_Order__c = f1RaceResult.positionorder__c,
                    Race_Round__c = f1RaceResult.race_round__c,
                    RaceTime__c = f1RaceResult.milliseconds__c
                );
                
                // Link to existing Driver using External ID relationship
                if(!String.isBlank(Integer.valueOf(f1RaceResult.driverId__c).toString())) {
                    Driver__c driver = new Driver__c();
                    driver.Data_Cloud_Id__c = Integer.valueOf(f1RaceResult.driverid__c).toString();
                    newContestant.Driver__r = driver; // This creates the relationship link
                }
                // Link to existing Race using External ID relationship
                if(!String.isBlank(Integer.valueOf(f1RaceResult.raceid__c).toString())) {
                    Race__c race = new Race__c();
                    race.Data_Cloud_Id__c = Integer.valueOf(f1RaceResult.raceid__c).toString();
                    newContestant.Race__r = race; // This creates the relationship link
                }
                // Link to existing Season using External ID relationship
                if(!String.isBlank(Integer.valueOf(f1RaceResult.race_year__c).toString())) {
                    Season__c season = new Season__c();
                    season.Year__c = Integer.valueOf(f1RaceResult.race_year__c).toString();
                    newContestant.Race_Season__r = season; // This creates the relationship link
                }
                // Link to existing Team using External ID relationship
                if(!String.isBlank(Integer.valueOf(f1RaceResult.constructorid__c).toString())) {
                    Team__c team = new Team__c();
                    team.Data_Cloud_Id__c = Integer.valueOf(f1RaceResult.constructorid__c).toString();
                    newContestant.Team__r = team; // This creates the relationship link
                }
                dataCloudContestantsToUpsert.add(newContestant);
        }

        // prepare and upsert contestant records
        List<SObject> records = new List<SObject>();
        records.addAll(dataCloudContestantsToUpsert);

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