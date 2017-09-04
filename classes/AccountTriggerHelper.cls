public class AccountTriggerHelper {

    public static void createDescription (List<Account> Lacc) {
        
        for (Account acc: Lacc) {
            acc.Description = acc.Name + ' Qlik';
        }
    }
    
    public static void methodNotCoveredAtAll1() {
        System.Debug('This code is never reached.');
        System.Debug('And takes down the code coverage.');
    }
    
    public static void methodNotCoveredAtAll2() {
        System.Debug('This code is never reached.');
        System.Debug('And takes down the code coverage.');
    }
    
    public static void methodNotCoveredAtAll3() {
        System.Debug('This code is never reached.');
        System.Debug('And takes down the code coverage.');
        //New comment
    }
}