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
}