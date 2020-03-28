public class WarehouseCalloutServiceMock implements HttpCalloutMock{
    String responseBodyString = '[{"_id":"55d66226726b611100aaf741","replacement":false,"quantity":5,"name":"Generator 1000 kW","maintenanceperiod":365,"lifespan":120,"cost":5000,"sku":"100003"},{"_id":"55d66226726b611100aaf742","replacement":true,"quantity":183,"name":"Cooling Fan","maintenanceperiod":0,"lifespan":0,"cost":300,"sku":"100004"}]';

    public WarehouseCalloutServiceMock() {
        //no action
    }

    public HTTPResponse respond(HTTPRequest reqObj) {
        HttpResponse resObj = new HttpResponse();
        resObj.setHeader('Content-Type', 'application/json');
        resObj.setStatusCode(200);
        resObj.setStatus('OK');
        resObj.setBody(responseBodyString);

        return resObj;
    }
}