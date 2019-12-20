@isTest
public with sharing class DocumentsSharedWithAPusersTest {
    @IsTest
    static void methodName(){
        
        Test.startTest();
        Group g = new Group();
        g.Name = 'test';
        insert g;

        DocumentsSharedWithAPusers.getSharings();
        Test.stopTest();
        
    }

}