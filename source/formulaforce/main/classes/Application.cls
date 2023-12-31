public class Application {
    
    // Configure and create the UnitOfWorkFactory for this Application
    public static final Application.UnitOfWorkFactory UnitOfWork = 
        new Application.UnitOfWorkFactory(
            new List<SObjectType> {
                Driver__c.SObjectType,
                Team__c.SObjectType,
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
                Team__c.SObjectType => TeamsSelector.class,
                Race__c.SObjectType => RacesSelector.class,
                Car__c.SObjectType => CarsSelector.class,
                Driver__c.SObjectType => DriversSelector.class,
                Contestant__c.SObjectType => ContestantsSelector.class
            }
        );

    // Configure and create the DomainFactory for this Application
    public static final fflib_Application.DomainFactory Domain =
            new fflib_Application.DomainFactory(
                Application.Selector,
                // Map SObjectType to Domain Class Constructors
                new Map<SObjectType, Type> {
                    Team__c.SObjectType => Teams.Constructor.class,
                    Race__c.SObjectType => Races.Constructor.class,
                    Car__c.SObjectType => Cars.Constructor.class,
                    Driver__c.SObjectType => Drivers.Constructor.class,
                    Contestant__c.SObjectType => Contestants.Constructor.class
                }
            );

    // Customised Unit of Work factory defaults to user mode with option to revert to system mode
    public class UnitOfWorkFactory extends fflib_Application.UnitOfWorkFactory {
        public UnitOfWorkFactory(List<SObjectType> objectTypes) {
            super(objectTypes);
        }
        public override fflib_ISObjectUnitOfWork newInstance() {
            return newInstance(AccessLevel.USER_MODE);
        }
        public fflib_ISObjectUnitOfWork newInstance(AccessLevel accessLevel) {
            return newInstance(new UnifOfWorkDMLWithAccessLevel(accessLevel));
        }
    }

    public class UnifOfWorkDMLWithAccessLevel extends fflib_SObjectUnitOfWork.SimpleDML {
        private AccessLevel accessLevel;
        public UnifOfWorkDMLWithAccessLevel(AccessLevel accessLevel) {
            this.accessLevel = accessLevel;
        }
        public override void dmlInsert(List<SObject> objList)
        {
            Database.insert(objList, accessLevel);
        }
        public override void dmlUpdate(List<SObject> objList)
        {
            Database.update(objList, accessLevel);
        }
        public override void dmlDelete(List<SObject> objList)
        {
            Database.delete(objList, accessLevel);
        }
    }

    
    // Customised Service factory to support developer overrides via Custom Metadata
    private class ServiceFactory extends fflib_Application.ServiceFactory {
        
        private Map<String, String> servicesByClassName = new Map<String, String>();

        public ServiceFactory(Map<Type, Type> serviceInterfaceTypeByServiceImplType) {
            super(serviceInterfaceTypeByServiceImplType);

            // Map of overriden services defined by the developer in this org
            for (Service__mdt serviceOverride : Service__mdt.getAll().values()) {
                servicesByClassName.put(
                    serviceOverride.NamespacePrefix + '.' + serviceOverride.DeveloperName,
                    serviceOverride.ApexClass__c
                );
            }
        }

        public override Object newInstance(Type serviceInterfaceType) {

            // Has the developer overriden the Service implementation in their org?
            if (!Test.isRunningTest() && servicesByClassName.containsKey(serviceInterfaceType.getName())) {
                String overridenServiceImpl = servicesByClassName.get(serviceInterfaceType.getName());
                return Type.forName(overridenServiceImpl).newInstance();
            }

            // Default service factory returns mocked or registered default implementation
            return super.newInstance(serviceInterfaceType);
        } 
    }

    /**
    * Utility method to throw Application exceptions to Lightning Components
    **/
    public static void throwAuraHandledException(Exception e) {
        String message = e.getMessage();
        AuraHandledException error = new AuraHandledException(message);
        error.setMessage(message);  // ensure Apex tests can assert the error message value
        throw error;
    }
}