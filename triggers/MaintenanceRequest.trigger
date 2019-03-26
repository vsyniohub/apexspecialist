trigger MaintenanceRequest on Case (before update, after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        Set<Id> closedMRs = new Set<Id>();
        //MaintenanceRequestHelper.createNextMaintenanceRequestWhenClosed
    }
    // call MaintenanceRequestHelper.updateWorkOrders  
}