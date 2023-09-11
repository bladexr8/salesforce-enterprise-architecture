public class ContestantService {
    
    public static void awardChampionshipPoints(Set<Id> contestantIds) {

        // Apply championship points to selected contestants
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        awardChampionshipPoints(uow, new ContestantsSelector().selectById(contestantIds));
        uow.commitWork();
    }

    public static void awardChampionshipPoints(fflib_ISObjectUnitOfWork uow, List<Contestant__c> contestants) {

        // Apply championship points to given contestants
        Map<Integer, ChampionshipPoint__mdt> pointsByTrackPosition = 
            new ChampionshipPointsSelector().selectAllByTrackPosition();
        for (Contestant__c contestant : contestants) {
            // determine points to award for given position
            ChampionshipPoint__mdt pointsForPostion = 
                pointsByTrackPosition.get(Integer.valueOf(contestant.RacePosition__c));
            if (pointsForPostion != null) {
                // Apply points and register for update with uow
                contestant.ChampionshipPoints__c = pointsForPostion.PointsAwarded__c;
                uow.registerDirty(contestant);
            }
        }
    }

    public static void retireFromRace(List<RaceRetirement> retirements) {
        throw new ContestantServiceException('Not implemented');
    }

    public class RaceRetirement {
        public Id contestantId;
        public String reason;
    }
}