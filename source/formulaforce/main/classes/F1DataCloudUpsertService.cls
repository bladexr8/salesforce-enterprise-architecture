public with sharing class F1DataCloudUpsertService {

    // Custom Exception for upsert errors
    public class UpsertException extends Exception {}
    
    // result wrapper class for upsert operations
    public class UpsertResult {
        public Boolean success {get;set;}
        public Integer totalRecords {get;set;}
        public Integer recordsCreated {get;set;}
        public Integer recordsUpdated {get;set;}
        public Integer recordsFailed {get;set;}
        public List<UpsertError> errors {get;set;}
        public List<Id> createdRecordIds {get;set;}
        public List<Id> updatedRecordIds {get;set;}
        public String executionTIme {get;set;}

        public UpsertResult() {
            this.success = false;
            this.totalRecords = 0;
            this.recordsCreated = 0;
            this.recordsUpdated = 0;
            this.recordsFailed = 0;
            this.errors = new List<UpsertError>();
            this.createdRecordIds = new List<Id>();
            this.updatedRecordIds = new List<Id>();
        } 
    }

    // Error details for failed uosert operations
    public class UpsertError {
        public String recordIdentifier {get;set;}
        public String errorMessage {get;set;}
        public String errorCode {get;set;}
        public List<String> fields {get;set;}

        public UpsertError(String recordId, String message, String code, List<String> fieldNames) {
            this.recordIdentifier = recordId;
            this.errorMessage = message;
            this.errorCode = code;
            this.fields = fieldNames != null ? fieldNames : new List<String>();
        }
    }

    // configuration class for upsert operation
    public class UpsertConfig {
        public String objectType {get;set;}
        public String externalIdField {get;set;}
        public Boolean allOrNone {get;set;}
        public Boolean allowPartialSuccess {get;set;}
        public Boolean validateOnly {get;set;}
        public Map<String, Object> defaultValues {get;set;}

        public UpsertConfig(String objType, String extIdField) {
            this.objectType = objType;
            this.externalIdField = extIdField;
            this.allOrNone = false;
            this.allowPartialSuccess = true;
            this.validateOnly = false;
            this.defaultValues = new Map<String, Object>();
        }
    }

    // main upsert method for SObject lists
    public static UpsertResult upsertRecords(List<SObject> records, UpsertConfig config) {
        UpsertResult result = new UpsertResult();
        DateTime startTime = System.now();

        try {
            // validate inputs
            validateUpsertInputs(records, config);

            // apply default values if configured
            if (!config.defaultValues.isEmpty()) {
                applyDefaultValues(records, config.defaultValues);
            }

            // Perform the upsert operation
            Schema.SObjectField externalIdSObjectField = getExternalIdField(config.objectType, config.externalIdField);
            
            result.totalRecords = records.size();
            
            if (config.validateOnly) {
                // validation only mode
                result = performValidationOnly(records, config, externalIdSObjectField);
            } else {
                // actual upsert
                result = performUpsert(records, config, externalIdSObjectField);
            }

            result.success = (result.recordsFailed != 0) || config.allowPartialSuccess;
        } catch (Exception e) {
            result.success = false;
            result.recordsFailed = records != null ? records.size() : 0;
            result.errors.add(new UpsertError('SYSTEM', e.getMessage(), e.getTypeName(), new List<String>()));
        }

        // calculate execution time
        DateTime endTime = System.now();
        Long executionTimeMs = endTime.getTime() - startTime.getTime();
        result.executionTIme = String.valueOf(executionTimeMs) + 'ms';

        return result;
    }

    // simplified upsert method with just object type and external ID field
    public static UpsertResult upsertRecordsSimple(List<SObject> records, String objectType, String externalIdField) {
        UpsertConfig config = new UpsertConfig(objectType, externalIdField);
        return upsertRecords(records, config);
    }

    // upsert method for Contact records using Email as the external ID
    public static UpsertResult upsertContacts(List<Contact> contacts) {
        UpsertConfig config = new UpsertConfig('Contact', 'Email');
        List<SObject> records = new List<SObject>();
        records.addAll(contacts);
        return upsertRecords(records, config);
    }

    // upsert method for Circuit records using Data Cloud Id as the external ID
    public static UpsertResult upsertCircuits(List<Circuit__c> circuits) {
        UpsertConfig config = new UpsertConfig('Circuit__c', 'Data_Cloud_Id__c');
        List<SObject> records = new List<SObject>();
        records.addAll(circuits);
        return upsertRecords(records, config);
    }

    // upsert method for Team (Constructor) records using Data Cloud Id as the external ID
    public static UpsertResult upsertTeams(List<Team__c> teams) {
        UpsertConfig config = new UpsertConfig('Team__c', 'Data_Cloud_Id__c');
        List<SObject> records = new List<SObject>();
        records.addAll(teams);
        return upsertRecords(records, config);
    }

    // upsert method for Season records using Year as the external ID
    public static UpsertResult upsertSeasons(List<Season__c> seasons) {
        UpsertConfig config = new UpsertConfig('Season__c', 'Year__c');
        List<SObject> records = new List<SObject>();
        records.addAll(seasons);
        return upsertRecords(records, config);
    }

    // upsert method for Driver records using Data Cloud Id as the external ID
    public static UpsertResult upsertDrivers(List<Driver__c> drivers) {
        UpsertConfig config = new UpsertConfig('Driver__c', 'Data_Cloud_Id__c');
        List<SObject> records = new List<SObject>();
        records.addAll(drivers);
        return upsertRecords(records, config);
    }

    // upsert method for Driver records using Data Cloud Id as the external ID
    public static UpsertResult upsertRaces(List<Race__c> races) {
        UpsertConfig config = new UpsertConfig('Race__c', 'Data_Cloud_Id__c');
        List<SObject> records = new List<SObject>();
        records.addAll(races);
        return upsertRecords(records, config);
    }

    // batch insert for large datasets
    public static List<UpsertResult> upsertRecordsBatch(List<SObject> records, UpsertConfig config, Integer batchSize) {
        List<UpsertResult> results = new List<UpsertResult>();
        if (batchSize <= 0) {
            batchSize = 200;    // default batch size
        }

        // Process records in batches
        for (Integer i=0; i < records.size(); i += batchSize) {
            Integer endIndex = Math.min(i + batchSize, records.size());
            List<SObject> batch = new List<SObject>();
            for (Integer j=i; j < endIndex; j++) {
                batch.add(records[j]);
            }

            UpsertResult result = upsertRecords(batch, config);
            results.add(result);
        }

        return results;
    }

    // perform the actual database upsert operation
    private static UpsertResult performUpsert(List<SObject> records, UpsertConfig config, Schema.SObjectField externalIdField) {
        UpsertResult result = new UpsertResult();

        Database.UpsertResult[] upsertResults = Database.upsert(records, externalIdField, config.allOrNone);

        // process results
        for (Integer i=0; i < upsertResults.size(); i++) {
            Database.UpsertResult upsertResult = upsertResults[i];
            SObject record = records[i];
            if (upsertResult.isSuccess()) {
                if (upsertResult.isCreated()) {
                    result.recordsCreated++;
                    result.createdRecordIds.add(upsertResult.getId());
                } else {
                    result.recordsUpdated++;
                    result.updatedRecordIds.add(upsertResult.getId());
                }
            } else {
                result.recordsFailed++;
                String recordIdentifier = getRecordIdentifier(record, config.externalIdField);
                for (Database.Error error : upsertResult.getErrors()) {
                    List<String> fieldNames = new List<String>();
                    if (error.getFields() != null) {
                        for (String field : error.getFields()) {
                            fieldNames.add(field);
                        }
                    }
                    result.errors.add(new UpsertError(
                        recordIdentifier,
                        error.getMessage(),
                        error.getStatusCode().name(),
                        fieldNames
                    ));
                }
            }    
        }
        return result;
    }

    /**
     * Perform validation-only operation
     */
    private static UpsertResult performValidationOnly(List<SObject> records, UpsertConfig config, Schema.SObjectField externalIdField) {
        UpsertResult result = new UpsertResult();
        
        try {
            // Create a savepoint for rollback
            Savepoint sp = Database.setSavepoint();
            
            // Perform upsert and then rollback
            Database.UpsertResult[] upsertResults = Database.upsert(records, externalIdField, false);
            
            // Rollback the transaction
            Database.rollback(sp);
            
            // Process validation results
            for (Integer i = 0; i < upsertResults.size(); i++) {
                Database.UpsertResult upsertResult = upsertResults[i];
                SObject record = records[i];
                
                if (upsertResult.isSuccess()) {
                    // Would be created or updated
                    if (upsertResult.isCreated()) {
                        result.recordsCreated++;
                    } else {
                        result.recordsUpdated++;
                    }
                } else {
                    result.recordsFailed++;
                    String recordIdentifier = getRecordIdentifier(record, config.externalIdField);
                    
                    for (Database.Error error : upsertResult.getErrors()) {
                        List<String> fieldNames = new List<String>();
                        if (error.getFields() != null) {
                            for (String field : error.getFields()) {
                                fieldNames.add(field);
                            }
                        }
                        
                        result.errors.add(new UpsertError(
                            recordIdentifier,
                            error.getMessage(),
                            error.getStatusCode().name(),
                            fieldNames
                        ));
                    }
                }
            }
            
        } catch (Exception e) {
            result.recordsFailed = records.size();
            result.errors.add(new UpsertError('VALIDATION', e.getMessage(), e.getTypeName(), new List<String>()));
        }
        
        return result;
    }

    /**
     * Validate upsert inputs
     */
    private static void validateUpsertInputs(List<SObject> records, UpsertConfig config) {
        if (records == null || records.isEmpty()) {
            throw new UpsertException('Records list cannot be null or empty');
        }
        
        if (String.isBlank(config.objectType)) {
            throw new UpsertException('Object type must be specified');
        }
        
        if (String.isBlank(config.externalIdField)) {
            throw new UpsertException('External ID field must be specified');
        }
        
        // Check if all records are of the same type
        String expectedType = config.objectType;
        for (SObject record : records) {
            if (record.getSObjectType().getDescribe().getName() != expectedType) {
                throw new UpsertException('All records must be of type: ' + expectedType);
            }
        }
        
        // Validate external ID field exists and has values
        validateExternalIdValues(records, config.externalIdField);
    }

    /**
     * Validate that external ID field exists and has values
     */
    private static void validateExternalIdValues(List<SObject> records, String externalIdField) {
        for (SObject record : records) {
            Object externalIdValue = record.get(externalIdField);
            if (externalIdValue == null || String.valueOf(externalIdValue).trim() == '') {
                throw new UpsertException('External ID field "' + externalIdField + '" cannot be null or empty');
            }
        }
    }

    /**
     * Get SObjectField for external ID
     */
    private static Schema.SObjectField getExternalIdField(String objectType, String fieldName) {
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectType);
        if (sObjectType == null) {
            throw new UpsertException('Invalid object type: ' + objectType);
        }
        
        Map<String, Schema.SObjectField> fieldsMap = sObjectType.getDescribe().fields.getMap();
        Schema.SObjectField field = fieldsMap.get(fieldName);
        
        if (field == null) {
            throw new UpsertException('Field "' + fieldName + '" does not exist on object "' + objectType + '"');
        }
        
        return field;
    }

    /**
     * Get record identifier for error reporting
     */
    private static String getRecordIdentifier(SObject record, String externalIdField) {
        Object externalIdValue = record.get(externalIdField);
        if (externalIdValue != null) {
            return String.valueOf(externalIdValue);
        }
        
        if (record.Id != null) {
            return record.Id;
        }
        
        return 'Unknown';
    }

    /**
     * Apply default values to records
     */
    private static void applyDefaultValues(List<SObject> records, Map<String, Object> defaultValues) {
        for (SObject record : records) {
            for (String fieldName : defaultValues.keySet()) {
                Object currentValue = record.get(fieldName);
                if (currentValue == null) {
                    record.put(fieldName, defaultValues.get(fieldName));
                }
            }
        }
    }

    /**
     * Get upsert statistics for monitoring
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getUpsertStatistics(Integer days) {
        Map<String, Object> stats = new Map<String, Object>();
        
        try {
            // Query recent upsert operations from logs or custom objects
            // This is a placeholder - implement based on your logging strategy
            stats.put('totalOperations', 0);
            stats.put('successfulOperations', 0);
            stats.put('failedOperations', 0);
            stats.put('recordsProcessed', 0);
            
        } catch (Exception e) {
            stats.put('error', e.getMessage());
        }
        
        return stats;
    }

} // end F1DataCloudUpsertService