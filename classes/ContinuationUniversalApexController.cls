/* *********************************************
 * Class to implement Continuation
 * Documentation 
 * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_continuation_overview.htm
 * ********************************************* */
public class ContinuationUniversalApexController {
    private final static String URLName 			    = 'ResponserURL';
    private final static String continuationName        = 'GEOContinuationFolder';
    private final static String GETMethod               = 'GET';
    private final static String methodNameProcess       = 'processResponse';
    private final static Integer continuationTimeout    = 40;
    
    public String requestLabel;
    public String result {get; set;}

    /* *********************************************
     * Method Name: getContinuationDataFromGeo - creates Continuation and enqueues it
     * Parameters: no
     * Returns: Object
     * ********************************************* */
    public Object getContinuationDataFromGeo() {
        Continuation con = new Continuation(continuationTimeout);
        con.continuationMethod = methodNameProcess;
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(getSetting(URLName) + getSetting(continuationName));
        req.setMethod(GETMethod);        
        
        this.requestLabel = con.addHttpRequest(req);
        this.result = null;

        System.debug('Sent To: ' + getSetting(URLName) + getSetting(continuationName));
        System.debug('Request Label : ' + this.requestLabel);

        return con;
    }

    /* *********************************************
     * Method Name: processResponse - parses Continuation resoponse
     * Parameters: no
     * Returns: Object
     * ********************************************* */
    public Object processResponse() {   
      HttpResponse response = Continuation.getResponse(this.requestLabel);
      this.result = response.getBody();
      
      System.debug('Result : ' + result);
      return null;
    }
    
    /* *********************************************
     * Method Name: getSetting - retrieves Custom Setting Value__c
     * Parameters: String - custom Setting Name
     * Returns: String
     * ********************************************* */
    private static String getSetting(String settingName) {
        if (IntegrationSettings__c.getInstance(settingName) != null) {
        	return IntegrationSettings__c.getInstance(settingName).Value__c;    
        } else {
            return null;
        }
    }
}