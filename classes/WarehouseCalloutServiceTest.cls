@isTest
private class WarehouseCalloutServiceTest {
    private static List<Product2> getProducts() {
        return ([
            SELECT 
                Id, 
                Replacement_Part__c, 
                Cost__c, 
                Current_Inventory__c,
                Maintenance_Cycle__c,
                Lifespan_Months__c, 
                Name,
                Warehouse_SKU__c 
            FROM Product2]);
    }

    private static HTTPResponse getResponse() {
        HttpRequest reqObj = new HttpRequest();

        reqObj.setMethod('GET');
        reqObj.setEndpoint('https://somesampleurl.some');
        
        Http h = new Http();

        HttpResponse resObj = h.send(reqObj);

        return resObj;
    }

    @isTest public static void testCallout() {
        List<Product2> equipmentToAssertNoData = new List<Product2>();
        List<Product2> equipmentToAssertWithData = new List<Product2>();
        Test.startTest();
        //equipmentToAssertNoData = getProducts();
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        WarehouseCalloutService.runWarehouseEquipmentSync();
        System.debug(equipmentToAssertNoData);
        Test.stopTest();

        equipmentToAssertWithData = getProducts();
        System.debug(equipmentToAssertWithData);
        System.assertEquals(2, equipmentToAssertWithData.size());
        System.assertEquals(0, equipmentToAssertNoData.size());
        
        for (Integer i = 0; i < equipmentToAssertWithData.size(); i++) {
            System.assertNotEquals(false, equipmentToAssertWithData[i].Replacement_Part__c);
            System.assertNotEquals(0,     equipmentToAssertWithData[i].Cost__c);
            System.assertNotEquals(null,  equipmentToAssertWithData[i].Current_Inventory__c);
            System.assertNotEquals(null,  equipmentToAssertWithData[i].Warehouse_SKU__c);
            System.assertNotEquals(null,  equipmentToAssertWithData[i].Maintenance_Cycle__c);
            System.assertNotEquals(null,  equipmentToAssertWithData[i].Lifespan_Months__c);
            System.assertNotEquals(null,  equipmentToAssertWithData[i].Name);
        }
    }
}