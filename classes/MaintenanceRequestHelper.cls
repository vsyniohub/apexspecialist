public class MaintenanceRequestHelper {
    public static Map<Id, Decimal> reqCycles {get; set;}
    
    private static Integer getMaintenanceCycle(Id requestId) {
        if (reqCycles.get(requestId) == null) {
            return 0;
        } else {
            return Integer.valueOf(reqCycles.get(requestId));
        }
    }

    private static List<Case> getInsertCaseList(List<Case> css) {
        List<Case> newCaseList = new List<Case>(); 
        for (Case cs : css) {
            Case newCS = new Case(
                Type                = 'Routine Maintenance',
                Subject             = 'Future Routing Maintenance Request',
                Equipment__c        = cs.Equipment__c,
                Date_Reported__c    = Date.today(),
                Vehicle__c          = cs.Vehicle__c,
                Date_Due__c         = Date.today().addDays(getMaintenanceCycle(cs.Id))
            );
            newCaseList.add(newCS);
        }
        return newCaseList;
    }

    public static void createNextMaintenanceRequestWhenClosed(List<Case> closedCases) {
        Set<Id> casesSet            = new Set<Id>();
        List<Case> newCaseList      = new List<Case>();
        reqCycles                   = new Map<Id, Decimal>();

        for (Case cs : closedCases) {
            casesSet.add(cs.Id);
        }

        List<Work_Part__c> workPartsToCheck = [
            SELECT 
                Id, 
                Maintenance_Request__c, //Maintenance_Request__r.Equipment__c, Maintenance_Request__r.Vehicle__c, 
                Equipment__c, Equipment__r.Maintenance_Cycle__c
            FROM Work_Part__c
            WHERE Maintenance_Request__c in :casesSet
            ORDER BY Equipment__r.Maintenance_Cycle__c DESC
        ];
        for (Work_Part__c workp : workPartsToCheck) {
            reqCycles.put(workp.Maintenance_Request__c, workp.Equipment__r.Maintenance_Cycle__c);
            //because of order by - map will contain the least
        }
        
        newCaseList = getInsertCaseList(closedCases);

        if (!newCaseList.isEmpty()) {
            insert newCaseList;
        }
    }
    
    /*
    public static void updateWorkOrders(){
        // update workorders
    }        
    */
}