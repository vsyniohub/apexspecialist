@isTest
private class MaintenanceRequestHelperTest {
    public final static Integer BATCH_MAXIMUM = 300;

    @testSetup 
    public static void setupSamples() {
        List<Product2> products      = new List<Product2>();
        List<Vehicle__c> vehicles    = new List<Vehicle__c>();
        List<Work_Part__c> workParts = new List<Work_Part__c>();
        List<Case> casesListDML      = new List<Case>();

        for (Integer i = 0; i < BATCH_MAXIMUM; i++) {
            Product2 product = new Product2(
                Name                  = 'Sample' + i,
                Replacement_Part__c   = true,
                Maintenance_Cycle__c  = 3,
                IsActive              = true,
                LifeSpan_Months__c    = 1
            );
            products.add(product);
        }
        insert products;

        for (Integer i = 0; i < BATCH_MAXIMUM; i++) {
            Vehicle__c vehicle = new Vehicle__c(
                  Model__c  = 'Some Model',
                  Name      = 'Name' + i
            );
            vehicles.add(vehicle);
        }
        insert vehicles;

        for (Integer i = 0; i < BATCH_MAXIMUM; i++) {
            casesListDML.add(new Case(
                Subject         = 'Some' + i,
                Type            = 'Routine Maintenance',
                Priority        = 'High',
                Vehicle__c      = vehicles[i].Id,
                Equipment__c    = products[i].Id
            ));
        }
        insert casesListDML;

        for (Integer i = 0; i < BATCH_MAXIMUM; i++) {
            workParts.add(new Work_Part__c(
                Maintenance_Request__c = casesListDML[i].Id,
                Equipment__c           = products[i].Id
            ));
        }
        insert workParts;
    }

    @isTest
    public static void testTrigger() {
        Integer vechicleMatch = 0;
        Integer equipmentMatch = 0;

        List<Product2> equipmentDML = [SELECT Id, Maintenance_Cycle__c FROM Product2];
        for (Product2 pr : equipmentDML) {
            pr.Maintenance_Cycle__c = Decimal.valueOf(
                Math.random() * 10
            ).round(System.RoundingMode.CEILING);
        }
        update equipmentDML;

        List<Case> casesListDML = [SELECT Id, Status from Case where Status = 'New' LIMIT 300];
        for (Case cs : casesListDML) {
            cs.Status = 'Closed';
        }
        update casesListDML;     

        List<Case> caseAssertList              = [
            SELECT Id, Date_Reported__c, Status, Vehicle__c , Equipment__c
            FROM Case where Status = 'New'
        ];
        Map<Id, Product2> equipmentAssertList  = new Map<Id, Product2>([SELECT Id FROM Product2 order by Name ASC]);
        Map<Id, Vehicle__c> vehicleAssertList  = new Map<Id, Vehicle__c>([SELECT Id FROM Vehicle__c order by NAME ASC]);
        System.debug(equipmentAssertList);
        System.assertEquals(BATCH_MAXIMUM, caseAssertList.size());

        for (Integer i = 0; i < caseAssertList.size(); i++) {
            System.assertEquals('New', caseAssertList[i].Status);
            System.assertEquals(date.today(), caseAssertList[i].Date_Reported__c);
            System.debug(caseAssertList[i].Equipment__c);

            if (equipmentAssertList.keySet().contains(caseAssertList[i].Equipment__c)) {
                equipmentAssertList.remove(caseAssertList[i].Equipment__c);
                equipmentMatch++;
            }
            if (vehicleAssertList.keySet().contains(caseAssertList[i].Vehicle__c)) {
                vehicleAssertList.remove(caseAssertList[i].Vehicle__c);
                vechicleMatch++;
            }
        }

        System.assertEquals(BATCH_MAXIMUM, equipmentMatch);
        System.assertEquals(BATCH_MAXIMUM, vechicleMatch);
    }
    
    @isTest
    public static void testTriggerNegative() {    
        List<Case> casesListDML = [SELECT Id, Type from Case];
        for (Case cs : casesListDML) {
            cs.Type = 'Other';
        }
        update casesListDML;

        for (Case cs : casesListDML) {
            cs.Status = 'Closed';
        }
        update casesListDML; 

        System.assert([SELECT COUNT() FROM Case where Status = 'New'] == 0);
    }
    
    @isTest
    public static void testTriggerWithZeroes() {    
        List<Work_Part__c> workPars = [SELECT Id from Work_Part__c LIMIT :BATCH_MAXIMUM];
        delete workPars;

        List<Case> casesListDML = [SELECT Id, Status from Case where Status = 'New' LIMIT :BATCH_MAXIMUM];

        for (Case cs : casesListDML) {
            cs.Status = 'Closed';
        }
        update casesListDML; 

        System.assert([SELECT COUNT() FROM Case where Status = 'New'] == BATCH_MAXIMUM);
    }
}