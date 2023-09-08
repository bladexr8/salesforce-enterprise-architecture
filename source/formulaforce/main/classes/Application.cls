public class Application {
    
    // Configure and create the UnitOfWorkFactory for this Application
    public static final fflib_Application.UnitOfWorkFactory UnitOfWork = 
        new fflib_Application.UnitOfWorkFactory(
            new List<SObjectType> {
                Driver__c.SObjectType,
                Season__c.SObjectType,
                Race__c.SObjectType,
                Contestant__c.SObjectType
            }
        );

    // Configure and create the ServiceFactory for this Application
    public static final fflib_Application.ServiceFactory Service = 
        new Application.ServiceFactory(
            new Map<Type, Type> {
                IRaceService.class => RaceServiceImpl.class
            }
        );

    // Configure and create the SelectorFactory for this Application
    public static final fflib_Application.SelectorFactory Selector = 
        new fflib_Application.SelectorFactory(
            new Map<SObjectType, Type> {
                // Opportunity.SObjectType => OpportunitiesSelector.class
            }
        )
}