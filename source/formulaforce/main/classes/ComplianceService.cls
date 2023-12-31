public with sharing class ComplianceService {
    
    /**
	* Provides general support to verify compliance in the application
	**/
    public static void verify(Set<Id> recordIds) {
        // Dynamically create Domain class instance for these records
        fflib_IDomain domain = Application.Domain.newInstance(recordIds);

        if (domain instanceOf ICompliant) {
            // Ask the domain class to verify it's compliance
            ICompliant compliantDomain = (ICompliant) domain;
            List<VerifyResult> verifyResults = compliantDomain.verifyCompliance();
            if (verifyResults != null) {
                // Check for failed compliances
                List<VerifyResult> failedCompliances = new List<VerifyResult>();
                for (VerifyResult verifyResult : verifyResults) {
                    if (!verifyResult.passed) {
                        failedCompliances.add(verifyResult);
                    }
                }
                if (failedCompliances.size() > 0) {
                    throw new ComplianceException('Complaince failures found.', failedCompliances);
                }
            }
            return;
        }
        throw new ComplianceException('Unable to verify compliance.', null);
    }
    
    /**
     * Custom exception class providing details of the compliance failures
     */
    public class ComplianceException extends Exception {
        public List<VerifyResult> failures {get; private set;}

        public ComplianceException(String message, List<VerifyResult> failures) {
            this(message);
            this.failures = failures;
        }	
    }

    /** 
	 * Interface used to execute compliance checking logic in each domain class
	 **/
	public interface ICompliant {
		List<VerifyResult> verifyCompliance();
	}

	/**
	 * Results of a compliance verification for a given record
	 **/
	public class VerifyResult {
		public Id recordId;
		public String complianceCode;
		public Boolean passed;
		public String failureReason;
	}
}

