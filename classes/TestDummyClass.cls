@isTest
private class TestDummyClass {

    @isTest static void DummyTest() {
        DummyClass dc = new DummyClass();
     	System.assert(dc.DummyMethod());   
    }
}