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
    public class UpsertOptions {
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
    }

} // end F1DataCloudUpsertService