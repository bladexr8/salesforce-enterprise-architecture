public with sharing class ContestantController {

    @AuraEnabled
    public static void awardPoints(Id contestandId) {
        try {
            ContestantService.awardChampionshipPoints(new Set<Id> { contestandId });
        } catch (Exception e) {
            Application.throwAuraHandledException(e);
        }        
    }
}