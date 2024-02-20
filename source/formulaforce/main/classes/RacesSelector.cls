public inherited sharing class RacesSelector extends fflib_SObjectSelector {
    
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Race__c.Id,
			Race__c.Name
			//Race__c.Status__c
		};
	}

	public Schema.SObjectType getSObjectType() {
		return Race__c.sObjectType;
	}

	public List<Race__c> selectById(Set<Id> raceIds) {
		return (List<Race__c>) selectSObjectsById(raceIds);
	}

	public List<Race__c> selectByIdWithContestants(Set<Id> raceIds) {
		fflib_QueryFactory racesQueryFactory = newQueryFactory();
		fflib_QueryFactory contestantsSubQueryFactory =
			new ContestantsSelector().addQueryFactorySubselect(racesQueryFactory);          
		return (List<Race__c>) Database.query(
			racesQueryFactory.setCondition('Id in :raceIds').toSOQL());
	}

	public List<Race__c> selectAllForCurrentYear() {
        String currentYear = '2016'; // Hard coded to match sample data included in Chatper 9
        return (List<Race__c>) Database.query(
            newQueryFactory().setCondition('Season__r.Name = :currentYear').toSOQL());
	}
}