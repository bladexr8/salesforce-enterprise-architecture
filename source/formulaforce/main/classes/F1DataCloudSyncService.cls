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
                    Name = f1Race.name__c,
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
        }

        // set up the Upsert Config
        F1DataCloudUpsertService.UpsertConfig batchClassConfig = new F1DataCloudUpsertService.UpsertConfig('Contestant__c', 'Data_Cloud_Id__c');

        // execute the batch
        F1DataCloudSyncContestantsBatch batchJob = new F1DataCloudSyncContestantsBatch(dataCloudRaceResults, batchClassConfig);
        Id batchJobId = Database.executeBatch(batchJob, 200);
        System.Debug('Contestants Sync Batch Added to queue: ' + batchJobId);
    

       /* List<F1_Race_Result__dlm> dataCloudRaceResults = new List<F1_Race_Result__dlm>();
        List<Contestant__c> dataCloudContestantsToUpsert = new List<Contestant__c>();

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
        }

        // Build list of Contestant objects to upsert
        if (dataCloudRaceResults.size() > 0) {
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

            // perform the upsert
            F1DataCloudUpsertService.UpsertResult result = F1DataCloudUpsertService.upsertContestants(dataCloudContestantsToUpsert);
            System.Debug('Created: ' + result.recordsCreated + ' Updated: ' + result.recordsUpdated + ' Failed: ' + result.recordsFailed);
        } else {
            System.Debug('No Race Results returned from Data Cloud');
        }   */         
    }
}