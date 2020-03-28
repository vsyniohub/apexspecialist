/* *********************************************
 * Global Class exposed in ORG's Site to be able to receive anonymous responses
 * @author me
 * ********************************************* */
@RestResource(urlMapping='/continuation')
global class ContinuationSimulator {
    private static String contentType       = 'Content-Type';
    private static String applicationJSON   = 'application/json';
    private static Integer maxBeforeLimit   = 9900;

    /* *********************************************
     * HTTP GET implemented
     * Method Name: doGet
     * Parameters: no
     * Returns: void
     * ********************************************* */
	@HttpGet
    global static void doGet() {
        RestContext.response.addHeader(contentType, applicationJSON);
        Long startTime  = DateTime.now().getTime();
        Long finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < maxBeforeLimit) {
            finishTime = DateTime.now().getTime();
        }
        System.debug('Done for ' + startTime + ' to ' + finishTime);
        RestContext.response.responseBody = Blob.valueOf('{"startTime": "' + startTime + '", "endTime": "' + finishTime + '"}');
    }
}