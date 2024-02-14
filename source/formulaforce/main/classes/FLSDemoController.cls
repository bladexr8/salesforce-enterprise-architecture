public with sharing class FLSDemoController {

    public Race__c Race {get;set;}

    public String Status { get { return Race.Status__c }}

    public String FastestLapBy { get { return Race.FastestLapBy__c}}

    public FLSDemoController() {
        Race = [SELECT Status__c, FastestLapBy__c FROM Race__c LIMIT 1];
    }

    @AuraEnabled
    public static Race__c getRace(Id raceId) {
        return [SELECT Status__c, FastestLapBy__c FROM Race WHERE Id = :raceId];
    }
}