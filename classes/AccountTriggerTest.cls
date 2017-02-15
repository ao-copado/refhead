@isTest
public class AccountTriggerTest {
	
    static TestMethod void checkDefaults() {
        
        Account acc = new Account (Name = 'No Test');
        
        insert acc;
        
        //acc = [SELECT Name FROM Account LIMIT 1];

        //System.assertEquals('Copado Test', acc.Name);
    }
}