trigger MaintenanceRequest on Case (before update, after update) {
    /* *****
     * MaintenanceRequestBatch bt = new MaintenanceRequestBatch(closedMRs);
     * Database.executeBatch(bt, 50);
     * *****/
    if (Trigger.isAfter && Trigger.isUpdate) {
        Set<Id> closedMRs           = new Set<Id>(); //used when batch needed
        List<Case> closedMRsList    = new List<Case>();

        for (Case cs : Trigger.new) {
            if (cs.Status == 'Closed' && (cs.Type == 'Repair' || cs.Type == 'Routine Maintenance')) {
                closedMRs.add(cs.Id);
                closedMRsList.add(cs);
            }
        }
        if (!closedMRs.isEmpty()) {
            MaintenanceRequestHelper.createNextMaintenanceRequestWhenClosed(closedMRsList);
        } 
    }
    // call MaintenanceRequestHelper.updateWorkOrders  
}