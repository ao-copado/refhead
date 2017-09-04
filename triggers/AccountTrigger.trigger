trigger AccountTrigger on Account (before insert) {
    
    if (Trigger.isInsert) {
    	AccountTriggerHelper.createDescription(trigger.new);
    }
    else {
        //Silly code to take coverage down
        List<Account> accs = [SELECT Id FROM Account LIMIT 1];
        accs = [SELECT Id FROM Account LIMIT 1];
        accs = [SELECT Id FROM Account LIMIT 1];
    }
}