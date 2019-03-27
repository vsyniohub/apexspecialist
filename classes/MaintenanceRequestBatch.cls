global with sharing class MaintenanceRequestBatch implements Database.Batchable<Case> {
    Set<Id> caseIds = new Set<Id>();
    
    public MaintenanceRequestBatch(Set<Id> caseIds) {
        this.caseIds = caseIds;
    }
    public Iterable<Case> start(Database.BatchableContext bc) {
        return [SELECT Id, Equipment__c, Vehicle__c from Case where Id in :caseIds];
    }
    public void execute(Database.BatchableContext bc, List<Case> scp)  {
        MaintenanceRequestHelper.createNextMaintenanceRequestWhenClosed(scp);
    }
    public void finish(Database.BatchableContext bc) {

    }
}