public class SeasonController {
    
    public SeasonController(ApexPages.StandardController stdController) {

    }

    public PageReference sendNewsleter() {
        SeasonService.issueNewsLetters(null);

        return null;
    }
}