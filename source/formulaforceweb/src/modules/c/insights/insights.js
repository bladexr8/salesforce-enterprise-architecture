import { LightningElement } from 'lwc';
import { getInsights } from 'stubs/insights'; 

export default class Insights extends LightningElement {

    // Component state and bindings
    insight = {
        "latestResults": {
        "race": "Singapore",
        "winner": "Max Verstappen"
        },
        "championShipPrediction": {
        "first": "Max Verstappen",
        "firstAccuracy": "(89%)",
        "second": "Sergio Perez",
        "secondAccuracy": "(60%)",
        "third": "Lando Norris",
        "thirdAccuracy": "(50%)"
        },
        "partnerStatus": {
        "name": "Salesforce.com",
        "level": "Gold",
        "seasonCoverage": 80
        }
     };
    loginButtonLabel = '';
    insightsLoaded = false;

    // Call /api/insights API once the component is loaded
    async connectedCallback() {
        //this.insight = await getInsights();
        //console.log('**Received Insights**');
        //console.log(this.insight);
        this.loginButtonLabel = this.insight.partnerStatus ? 'Partner Logout' : 'Partner Login';
        this.insightsLoaded = true;
        /*getInsights().then((result) => {
            this.insight = result;
            this.loginButtonLabel = this.insight.partnerStatus ? 'Partner Logout' : 'Partner Login';
            this.insightsLoaded = true;
        });*/
    }

    // Handles partner login and logout navigation (server side redirects return the user to main page)
    handlePartnerLogin(event) {
        var loginUrl = this.insight.partnerStatus !=null ? '/oauth2/logout' : 'oauth2/auth';
        window.location.href = loginUrl;
    }
}