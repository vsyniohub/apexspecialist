public with sharing class WarehouseCalloutService {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    private static String sendRequest() {
        HttpRequest req = new HttpRequest();

        req.setMethod('GET');
        req.setEndpoint(WAREHOUSE_URL);

        HttpResponse res = new Http().send(req);

        return res.getBody();
    }

    private static void upsertEquipment(List<WarehouseCalloutService.EquipmentResponse> res) {
        List<Product2> equipment = new List<Product2>();
        
        for (WarehouseCalloutService.EquipmentResponse er : res) {
            equipment.add(
                new Product2(
                    Replacement_Part__c     = true,
                    Cost__c                 = er.cost,
                    Current_Inventory__c    = er.quantity,
                    Maintenance_Cycle__c    = er.maintenanceperiod,
                    Lifespan_Months__c      = er.lifespan,
                    Name                    = er.Name,
                    Warehouse_SKU__c        = er.sku
                )
            );
        } //for end
        if (!equipment.isEmpty()) {
            upsert equipment Warehouse_SKU__c;
        }
    }
    
    /*public WarehouseCalloutService() {
        runWarehouseEquipmentSync();
    }*/

    @future(callout = true)
    public static void runWarehouseEquipmentSync(){
        String stringResponse = sendRequest();
        
        stringResponse = stringResponse.replace('_id', 'id'); //let's move to function

        List<WarehouseCalloutService.EquipmentResponse> res = 
            (List<WarehouseCalloutService.EquipmentResponse>) JSON.deserialize(stringResponse, List<WarehouseCalloutService.EquipmentResponse>.class);

        upsertEquipment(res);
    }

    public class EquipmentResponse {
        public String sku; 
        public String id;
        public String name;

        public Boolean placement;
        
        public Integer quantity;
        public Integer maintenanceperiod;
        public Integer lifespan;

        public Decimal cost;
        
    }
}