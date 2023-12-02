public inherited sharing class TeamsSelector extends fflib_SObjectSelector {
	
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
			Team__c.Id,
			Team__c.Name,
			Team__c.Testing_Distance__c,
            Team__c.Active_Since__c,
            Team__c.Home_Base__c,
            Team__c.Nationality__c,
            Team__c.Team_Boss__c
		};
	}

	public Schema.SObjectType getSObjectType() {
		return Team__c.sObjectType;
	}
}