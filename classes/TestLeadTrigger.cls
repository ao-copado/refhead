@isTest
private class TestLeadTrigger {

    @isTest static void LeadTriggertest() {
    	
        Lead l = new Lead (LastName = 'Test', Company = 'Copado');
        insert l;
 	}
}