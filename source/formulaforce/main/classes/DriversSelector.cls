public inherited sharing class DriversSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
			Driver__c.Id,
			Driver__c.Name,
			Driver__c.FIA_Super_License__c,
			Driver__c.Team__c,
            Driver__c.Active__c,
            Driver__c.Nationality__c,
            Driver__c.TwitterHandle__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Driver__c.sObjectType;
	}

	public List<Driver__c> selectByTeam(Set<Id> teamIds) {
		return (List<Driver__c>)
			Database.query(
				newQueryFactory().
					setCondition('Team__c in :teamIds').
					toSOQL());
	}
}