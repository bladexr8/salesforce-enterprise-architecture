public with sharing class F1DataCloudSyncService {
    
    // sync F1 Circuits
    public static void syncCircuits() {

        List<F1_Circuit__dlm> dataCloudCircuits = new List<F1_Circuit__dlm>();
        List<Circuit__c> dataCloudCircuitsToUpsert = new List<Circuit__c>();

        // Get data from Data Cloud 
        dataCloudCircuits = [
            SELECT
                circuitid__c,
                circuitref__c,
                name__c,
                location__c,
                country__c,
                lat__c,
                lng__c,
                alt__c,
                url__c
            FROM F1_Circuit__dlm
        ];

        // Build list of Circuit objects to upsert
        if (dataCloudCircuits.size() > 0) {
            for (F1_Circuit__dlm f1Circuit : dataCloudCircuits) {
                Circuit__c newCircuit = new Circuit__c(
                    Data_Cloud_Id__c = Integer.valueOf(f1Circuit.circuitid__c).toString(),
                    Circuit_Reference__c = f1Circuit.circuitref__c,
                    name = f1Circuit.name__c,
                    Country__c = f1Circuit.country__c,
                    Circuit_Location__c = f1Circuit.location__c,
                    Circuit_Geo_Location__latitude__s = f1Circuit.lat__c,
                    Circuit_Geo_Location__longitude__s = f1Circuit.lng__c,
                    Altitude__c = f1Circuit.alt__c,
                    Circuit_URL__c = f1Circuit.url__c
                );
                dataCloudCircuitsToUpsert.add(newCircuit);
            }

            // perform the upsert
            F1DataCloudUpsertService.UpsertResult result = F1DataCloudUpsertService.upsertCircuits(dataCloudCircuitsToUpsert);
            System.Debug('Created: ' + result.recordsCreated + ' Updated: ' + result.recordsUpdated + ' Failed: ' + result.recordsFailed);
        } else {
            System.Debug('No Circuits returned from Data Cloud');
        }            
    }

    // sync F1 Teams (Constructors)
    public static void syncTeams() {

        List<F1_Constructor__dlm> dataCloudConstructors = new List<F1_Constructor__dlm>();
        List<Team__c> dataCloudConstructorsToUpsert = new List<Team__c>();

        // Get data from Data Cloud 
        dataCloudConstructors = [
            SELECT
                constructorid__c,
                constructorRef__c,
                name__c,
                nationality__c,
                url__c
            FROM F1_Constructor__dlm
        ];

        // Build list of Circuit objects to upsert
        if (dataCloudConstructors.size() > 0) {
            for (F1_Constructor__dlm f1Constructor : dataCloudConstructors) {
                Team__c newTeam = new Team__c(
                    Data_Cloud_Id__c = Integer.valueOf(f1Constructor.constructorid__c).toString(),
                    Team_Reference__c = f1Constructor.constructorRef__c,
                    name = f1Constructor.name__c,
                    Team_Nationality__c = f1Constructor.nationality__c,
                    URL__c = f1Constructor.url__c
                );
                dataCloudConstructorsToUpsert.add(newTeam);
            }

            // perform the upsert
            F1DataCloudUpsertService.UpsertResult result = F1DataCloudUpsertService.upsertTeams(dataCloudConstructorsToUpsert);
            System.Debug('Created: ' + result.recordsCreated + ' Updated: ' + result.recordsUpdated + ' Failed: ' + result.recordsFailed);
        } else {
            System.Debug('No Constructors returned from Data Cloud');
        }            
    }

    // sync Seasons
    public static void syncSeasons() {

        List<F1_Season__dlm> dataCloudSeasons = new List<F1_Season__dlm>();
        List<Season__c> dataCloudSeasonsToUpsert = new List<Season__c>();

        // Get data from Data Cloud 
        dataCloudSeasons = [
            SELECT
                year__c,
                url__c
            FROM F1_Season__dlm
        ];

        // Build list of Circuit objects to upsert
        if (dataCloudSeasons.size() > 0) {
            for (F1_Season__dlm f1Season : dataCloudSeasons) {
                Season__c newSeason = new Season__c(
                    Year__c = Integer.valueOf(f1Season.year__c).toString(),
                    name = Integer.valueOf(f1Season.year__c).toString() + ' Formula 1 Season',
                    URL__c = f1Season.url__c
                );
                dataCloudSeasonsToUpsert.add(newSeason);
            }

            // perform the upsert
            F1DataCloudUpsertService.UpsertResult result = F1DataCloudUpsertService.upsertSeasons(dataCloudSeasonsToUpsert);
            System.Debug('Created: ' + result.recordsCreated + ' Updated: ' + result.recordsUpdated + ' Failed: ' + result.recordsFailed);
        } else {
            System.Debug('No Seasons returned from Data Cloud');
        }            
    }

    // sync F1 Drivers
    public static void syncDrivers() {

        List<F1_Driver__dlm> dataCloudDrivers = new List<F1_Driver__dlm>();
        List<Driver__c> dataCloudDriversToUpsert = new List<Driver__c>();

        // Get data from Data Cloud 
        dataCloudDrivers = [
            SELECT
                code__c,
                dob__c,
                driverid__c,
                driverRef__c,
                forename__c,
                nationality__c,
                number__c,
                surname__c,
                url__c
            FROM F1_Driver__dlm
        ];

        // Build list of Driver objects to upsert
        if (dataCloudDrivers.size() > 0) {
            for (F1_Driver__dlm f1Driver : dataCloudDrivers) {
                Driver__c newDriver = new Driver__c(
                    Data_Cloud_Id__c = Integer.valueOf(f1Driver.driverid__c).toString(),
                    Date_of_Birth__c = f1Driver.dob__c,
                    Driver_Code__c = f1Driver.code__c,
                    Driver_Reference__c = f1Driver.driverRef__c,
                    name = f1Driver.forename__c + ' ' + f1Driver.surname__c,
                    Driver_Nationality__c = f1Driver.nationality__c,
                    Driver_Number__c = (f1Driver.number__c != null) ? Integer.valueOf(f1Driver.number__c).toString() : '',
                    URL__c = f1Driver.url__c
                );
                dataCloudDriversToUpsert.add(newDriver);
            }

            // perform the upsert
            F1DataCloudUpsertService.UpsertResult result = F1DataCloudUpsertService.upsertDrivers(dataCloudDriversToUpsert);
            System.Debug('Created: ' + result.recordsCreated + ' Updated: ' + result.recordsUpdated + ' Failed: ' + result.recordsFailed);
        } else {
            System.Debug('No Drivers returned from Data Cloud');
        }            
    }

    // sync F1 Races
    public static void syncRaces() {

        List<F1_Race__dlm> dataCloudRaces = new List<F1_Race__dlm>();
        List<Race__c> dataCloudRacesToUpsert = new List<Race__c>();

        // Get data from Data Cloud 
        dataCloudRaces = [
            SELECT
                circuitid__c,
                date__c,
                fp1_date__c,
                fp1_time__c,
                fp2_date__c,
                fp2_time__c,
                fp3_date__c,
                fp3_time__c,
                name__c,
                quali_date__c,
                quali_time__c,
                raceid__c,
                round__c,
                sprint_date__c,
                sprint_time__c,
                time__c,
                url__c,
                year__c
            FROM F1_Race__dlm
        ];

        // Build list of Race objects to upsert
        if (dataCloudRaces.size() > 0) {
            for (F1_Race__dlm f1Race : dataCloudRaces) {
                Race__c newRace = new Race__c(
                    Data_Cloud_Id__c = Integer.valueOf(f1Race.raceid__c).toString(),
                    Free_Practice_1_Date__c = f1Race.fp1_date__c,
                    Free_Practice_1_Time__c = f1Race.fp1_time__c,
                    Free_Practice_2_Date__c = f1Race.fp2_date__c,
                    Free_Practice_2_Time__c = f1Race.fp2_time__c,
                    Free_Practice_3_Date__c = f1Race.fp3_date__c,
                    Free_Practice_3_Time__c = f1Race.fp3_time__c,
                    Qualifying_Date__c = f1Race.quali_date__c,
                    Qualifying_Time__c = f1Race.quali_time__c,
                    Race_Date__c = f1Race.date__c,
                    Name = Integer.valueOf(f1Race.year__c).toString() + ' ' + f1Race.name__c,
                    Race_Time__c = f1Race.time__c,
                    Race_URL__c = f1Race.url__c,
                    Round__c = f1Race.round__c,
                    Sprint_Date__c = f1Race.sprint_date__c,
                    Sprint_Time__c = f1Race.sprint_time__c
                );
                // Link to existing Circuit using External ID relationship
                if(!String.isBlank(Integer.valueOf(f1Race.raceId__c).toString())) {
                    Circuit__c circuit = new Circuit__c();
                    circuit.Data_Cloud_Id__c = Integer.valueOf(f1Race.circuitid__c).toString();
                    newRace.Circuit__r = circuit; // This creates the relationship link
                }
                // Link to existing Season using External ID relationship
                if(!String.isBlank(Integer.valueOf(f1Race.year__c).toString())) {
                    Season__c season = new Season__c();
                    season.year__c = Integer.valueOf(f1Race.year__c).toString();
                    newRace.Season__r = season; // This creates the relationship link
                }
                dataCloudRacesToUpsert.add(newRace);
            }

            // perform the upsert
            F1DataCloudUpsertService.UpsertResult result = F1DataCloudUpsertService.upsertRaces(dataCloudRacesToUpsert);
            System.Debug('Created: ' + result.recordsCreated + ' Updated: ' + result.recordsUpdated + ' Failed: ' + result.recordsFailed);
        } else {
            System.Debug('No Constructors returned from Data Cloud');
        }            
    }

    // sync F1 Race Results (Contestants)
    public static void syncContestants() {

        List<F1_Race_Result__dlm> dataCloudRaceResults = new List<F1_Race_Result__dlm>();
        List<List<F1_Race_Result__dlm>> dataCloudBatchesToUpsert = new List<List<F1_Race_Result__dlm>>();
        Integer batchSize = 5000;

        // Get data from Data Cloud 
        for ( F1_Race_Result__dlm f1Result : [
            SELECT
                constructorid__c,
                driverid__c,
                fastestlap__c,
                fastestlapspeed__c,
                fastestlaptime__c,
                finishing_status__c,
                grid__c,
                laps__c,
                milliseconds__c,
                number__c,
                points__c,
                position__c,
                positionorder__c,
                positiontext__c,
                raceid__c,
                race_round__c,
                race_year__c,
                resultid__c
            FROM F1_Race_Result__dlm
        ]) {
            dataCloudRaceResults.add(f1Result);

            // increment a batch
            if (dataCloudRaceResults.size() > batchSize) {
                dataCloudBatchesToUpsert.add(dataCloudRaceResults);
                dataCloudRaceResults = new List<F1_Race_Result__dlm>();
            }
        }

        // last batch (if required)
        if (dataCloudRaceResults.size() > 0) {
            dataCloudBatchesToUpsert.add(dataCloudRaceResults);
            // preserve memory
            dataCloudRaceResults = new List<F1_Race_Result__dlm>();
        }

        System.Debug(LoggingLevel.DEBUG, 'Retrieved and Generated ' + dataCloudBatchesToUpsert.size() + ' Race Result Batches from Data Cloud');

        // set up the Upsert Config
        F1DataCloudUpsertService.UpsertConfig batchClassConfig = new F1DataCloudUpsertService.UpsertConfig('Contestant__c', 'Data_Cloud_Id__c');

        // Submit the Batches
        for (List<F1_Race_Result__dlm> batch : dataCloudBatchesToUpsert) {
            System.Debug(LoggingLevel.DEBUG, 'Batch Count: ' + batch.size() + ' Submitting...');
            F1DataCloudSyncContestantsBatch batchJob = new F1DataCloudSyncContestantsBatch(batch, batchClassConfig);
            Id batchJobId = Database.executeBatch(batchJob, 200);
            System.Debug(LoggingLevel.DEBUG, 'Contestants Sync Batch Added to queue: ' + batchJobId);
        }       
    }

    // sync F1 Constructor Standings (Team Standings)
    public static void syncTeamStandings() {

        List<F1_Constructor_Standing__dlm> dataCloudConstStandings = new List<F1_Constructor_Standing__dlm>();
        List<List<F1_Constructor_Standing__dlm>> dataCloudBatchesToUpsert = new List<List<F1_Constructor_Standing__dlm>>();
        Integer batchSize = 5000;

        // Get data from Data Cloud 
        for ( F1_Constructor_Standing__dlm f1ConstStanding : [
            SELECT
                constructorid__c,
                constructorstandingsid__c,
                points__c,
                position__c,
                positiontext__c,
                raceid__c,
                wins__c
            FROM F1_Constructor_Standing__dlm
        ]) {
            dataCloudConstStandings.add(f1ConstStanding);

            // increment a batch
            if (dataCloudConstStandings.size() > batchSize) {
                dataCloudBatchesToUpsert.add(dataCloudConstStandings);
                dataCloudConstStandings = new List<F1_Constructor_Standing__dlm>();
            }
        }

        // last batch (if required)
        if (dataCloudConstStandings.size() > 0) {
            dataCloudBatchesToUpsert.add(dataCloudConstStandings);
            // preserve memory
            dataCloudConstStandings = new List<F1_Constructor_Standing__dlm>();
        }

        System.Debug(LoggingLevel.DEBUG, 'Retrieved and Generated ' + dataCloudBatchesToUpsert.size() + ' Constructor Standing Batches from Data Cloud');

        // set up the Upsert Config
        F1DataCloudUpsertService.UpsertConfig batchClassConfig = new F1DataCloudUpsertService.UpsertConfig('Team_Standing__c', 'Data_Cloud_Id__c');

        // Submit the Batches
        for (List<F1_Constructor_Standing__dlm> batch : dataCloudBatchesToUpsert) {
            System.Debug(LoggingLevel.DEBUG, 'Batch Count: ' + batch.size() + ' Submitting...');
            F1DataCloudSyncTeamStandingsBatch batchJob = new F1DataCloudSyncTeamStandingsBatch(batch, batchClassConfig);
            Id batchJobId = Database.executeBatch(batchJob, 200);
            System.Debug(LoggingLevel.DEBUG, 'Team Standings Sync Batch Added to queue: ' + batchJobId);
        }       
    }

    // sync F1 Constructor Results (Team Results)
    public static void syncTeamResults() {

        List<F1_Constructor_Result__dlm> dataCloudConstResults = new List<F1_Constructor_Result__dlm>();
        List<List<F1_Constructor_Result__dlm>> dataCloudBatchesToUpsert = new List<List<F1_Constructor_Result__dlm>>();
        Integer batchSize = 5000;

        // Get data from Data Cloud 
        for ( F1_Constructor_Result__dlm f1ConstResult : [
            SELECT
                constructorid__c,
                constructorresultsid__c,
                points__c,
                raceid__c,
                status__c
            FROM F1_Constructor_Result__dlm
        ]) {
            dataCloudConstResults.add(f1ConstResult);

            // increment a batch
            if (dataCloudConstResults.size() > batchSize) {
                dataCloudBatchesToUpsert.add(dataCloudConstResults);
                dataCloudConstResults = new List<F1_Constructor_Result__dlm>();
            }
        }

        // last batch (if required)
        if (dataCloudConstResults.size() > 0) {
            dataCloudBatchesToUpsert.add(dataCloudConstResults);
            // preserve memory
            dataCloudConstResults = new List<F1_Constructor_Result__dlm>();
        }

        System.Debug(LoggingLevel.DEBUG, 'Retrieved and Generated ' + dataCloudBatchesToUpsert.size() + ' Constructor Result Batches from Data Cloud');

        // set up the Upsert Config
        F1DataCloudUpsertService.UpsertConfig batchClassConfig = new F1DataCloudUpsertService.UpsertConfig('Team_Result__c', 'Data_Cloud_Id__c');

        // Submit the Batches
        for (List<F1_Constructor_Result__dlm> batch : dataCloudBatchesToUpsert) {
            System.Debug(LoggingLevel.DEBUG, 'Batch Count: ' + batch.size() + ' Submitting...');
            F1DataCloudSyncTeamResultsBatch batchJob = new F1DataCloudSyncTeamResultsBatch(batch, batchClassConfig);
            Id batchJobId = Database.executeBatch(batchJob, 200);
            System.Debug(LoggingLevel.DEBUG, 'Team Results Sync Batch Added to queue: ' + batchJobId);
        }       
    }


    // sync Driver Standings
    public static void syncDriverStandings() {

        List<F1_Driver_Standing__dlm> dataCloudDriverStandings = new List<F1_Driver_Standing__dlm>();
        List<List<F1_Driver_Standing__dlm>> dataCloudBatchesToUpsert = new List<List<F1_Driver_Standing__dlm>>();
        Integer batchSize = 5000;

        // Get data from Data Cloud 
        for ( F1_Driver_Standing__dlm f1ConstStanding : [
            SELECT
                driverid__c,
                driverstandingsid__c,
                points__c,
                position__c,
                positiontext__c,
                raceid__c,
                wins__c
            FROM F1_Driver_Standing__dlm
        ]) {
            dataCloudDriverStandings.add(f1ConstStanding);

            // increment a batch
            if (dataCloudDriverStandings.size() > batchSize) {
                dataCloudBatchesToUpsert.add(dataCloudDriverStandings);
                dataCloudDriverStandings = new List<F1_Driver_Standing__dlm>();
            }
        }

        // last batch (if required)
        if (dataCloudDriverStandings.size() > 0) {
            dataCloudBatchesToUpsert.add(dataCloudDriverStandings);
            // preserve memory
            dataCloudDriverStandings = new List<F1_Driver_Standing__dlm>();
        }

        System.Debug(LoggingLevel.DEBUG, 'Retrieved and Generated ' + dataCloudBatchesToUpsert.size() + ' Driver Standing Batches from Data Cloud');

        // set up the Upsert Config
        F1DataCloudUpsertService.UpsertConfig batchClassConfig = new F1DataCloudUpsertService.UpsertConfig('Driver_Standing__c', 'Data_Cloud_Id__c');

        // Submit the Batches
        for (List<F1_Driver_Standing__dlm> batch : dataCloudBatchesToUpsert) {
            System.Debug(LoggingLevel.DEBUG, 'Batch Count: ' + batch.size() + ' Submitting...');
            F1DataCloudSyncDriverStandingsBatch batchJob = new F1DataCloudSyncDriverStandingsBatch(batch, batchClassConfig);
            Id batchJobId = Database.executeBatch(batchJob, 500);
            System.Debug(LoggingLevel.DEBUG, 'Driver Standings Sync Batch Added to queue: ' + batchJobId);
        }       
    }


    // sync Pit Stops
    public static void syncPitStops() {

        List<F1_Pit_Stops__dlm> dataCloudPitStops = new List<F1_Pit_Stops__dlm>();
        List<List<F1_Pit_Stops__dlm>> dataCloudBatchesToUpsert = new List<List<F1_Pit_Stops__dlm>>();
        Integer batchSize = 5000;

        // Get data from Data Cloud 
        for ( F1_Pit_Stops__dlm f1PitStop : [
            SELECT
                driverid__c,
                duration__c,
                external_id__c,
                lap__c,
                milliseconds__c,
                raceid__c,
                STOP__c,
                time__c
            FROM F1_Pit_Stops__dlm
        ]) {
            dataCloudPitStops.add(f1PitStop);

            // increment a batch
            if (dataCloudPitStops.size() > batchSize) {
                dataCloudBatchesToUpsert.add(dataCloudPitStops);
                dataCloudPitStops = new List<F1_Pit_Stops__dlm>();
            }
        }

        // last batch (if required)
        if (dataCloudPitStops.size() > 0) {
            dataCloudBatchesToUpsert.add(dataCloudPitStops);
            // preserve memory
            dataCloudPitStops = new List<F1_Pit_Stops__dlm>();
        }

        System.Debug(LoggingLevel.DEBUG, 'Retrieved and Generated ' + dataCloudBatchesToUpsert.size() + ' Pit Stop Batches from Data Cloud');

        // set up the Upsert Config
        F1DataCloudUpsertService.UpsertConfig batchClassConfig = new F1DataCloudUpsertService.UpsertConfig('Pit_Stop__c', 'Data_Cloud_Id__c');

        // Submit the Batches
        for (List<F1_Pit_Stops__dlm> batch : dataCloudBatchesToUpsert) {
            System.Debug(LoggingLevel.DEBUG, 'Batch Count: ' + batch.size() + ' Submitting...');
            F1DataCloudSyncPitStopsBatch batchJob = new F1DataCloudSyncPitStopsBatch(batch, batchClassConfig);
            Id batchJobId = Database.executeBatch(batchJob, 500);
            System.Debug(LoggingLevel.DEBUG, 'Pit Stop Sync Batch Added to queue: ' + batchJobId);
        }       
    }

    // sync Qualifying
    public static void syncQualifying() {

        List<F1_Qualifying__dlm> dataCloudQuals = new List<F1_Qualifying__dlm>();
        List<List<F1_Qualifying__dlm>> dataCloudBatchesToUpsert = new List<List<F1_Qualifying__dlm>>();
        Integer batchSize = 5000;

        // Get data from Data Cloud 
        for ( F1_Qualifying__dlm f1Qual : [
            SELECT
                constructorid__c,
                driverid__c,
                number__c,
                position__c,
                q1__c,
                q2__c,
                q3__c,
                qualifyid__c,
                raceid__c
            FROM F1_Qualifying__dlm
        ]) {
            dataCloudQuals.add(f1Qual);

            // increment a batch
            if (dataCloudQuals.size() > batchSize) {
                dataCloudBatchesToUpsert.add(dataCloudQuals);
                dataCloudQuals = new List<F1_Qualifying__dlm>();
            }
        }

        // last batch (if required)
        if (dataCloudQuals.size() > 0) {
            dataCloudBatchesToUpsert.add(dataCloudQuals);
            // preserve memory
            dataCloudQuals = new List<F1_Qualifying__dlm>();
        }

        System.Debug(LoggingLevel.DEBUG, 'Retrieved and Generated ' + dataCloudBatchesToUpsert.size() + ' Qualifting Batches from Data Cloud');

        // set up the Upsert Config
        F1DataCloudUpsertService.UpsertConfig batchClassConfig = new F1DataCloudUpsertService.UpsertConfig('Qualifying__c', 'Data_Cloud_Id__c');

        // Submit the Batches
        for (List<F1_Qualifying__dlm> batch : dataCloudBatchesToUpsert) {
            System.Debug(LoggingLevel.DEBUG, 'Batch Count: ' + batch.size() + ' Submitting...');
            F1DataCloudSyncQualifyingBatch batchJob = new F1DataCloudSyncQualifyingBatch(batch, batchClassConfig);
            Id batchJobId = Database.executeBatch(batchJob, 500);
            System.Debug(LoggingLevel.DEBUG, 'Qualifting Sync Batch Added to queue: ' + batchJobId);
        }       
    }
}