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
            System.Debug('No Constructors returned from Data Cloud');
        }            
    }
}