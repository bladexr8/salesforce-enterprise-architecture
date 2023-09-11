public inherited sharing class RaceServiceImpl implements IRaceService {
    
    public Map<Id, List<RaceServiceResults.ProvisionalResult>> calculateProvisionResults(Set<Id> raceIds) {           
        throw new RaceServiceException('Not implemented');
    }

    public void applyRaceResults(Map<Id, List<RaceServiceResults.ProvisionalResult>> provisionalResultsByRaceId) {
        throw new RaceServiceException('Not implemented');
    }

    public void awardChampionshipPoints(Set<Id> raceIds) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        // Query Races and contestants and bulkify list of all contestants
        List<Contestant__c> contestants = new List<Contestant__c>();
        for (Race__c race : new RacesSelector().selectByIdWithContetstants(raceIds)) {
            contestants.addAll(race.Contestants__r);
        }

        // Delegate to contestant service
        ContestantService.awardChampionshipPoints(uow, contestants);

        // Commit work
        uow.commitWork();
    }
}