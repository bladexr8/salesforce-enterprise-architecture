// Endpoint for this client stub
const URL = '/api/insights/';
let insights = {};

/**
 * Simple client stub for the /api/insights API
 */
export const getInsights = async () =>
{
    console.log('***Executing getInsights...');
    fetch(URL)
        .then((response) => {
            //console.log('***Received Response***');
            //console.log(response);
            if (!response.ok) { throw new Error('No response from server'); }
            return response.json();
        })
        .then((result) => {
            insights = result;
            console.log('**Returning Insights***');
            console.log(insights);
            return insights;
        });
}
    