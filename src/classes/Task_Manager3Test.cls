@isTest
private with sharing class Task_Manager3Test {
    public Task_Manager3Test() { }

    @isTest
    static void test_loadVars() {
        test.startTest();
           Task_Manager3 tm3 = new Task_Manager3();
           String t = Task_Manager3.RELATED_TO_MAP_JSON;
           t = Task_Manager3.ALLOWED_STATUSES_JSON;
           t = Task_Manager3.ALLOWED_PRIORITIES_JSON;
           t = Task_Manager3.AVAIL_ASSIGNED_TO_TYPES_JSON;
           t = Task_Manager3.AVAIL_WHO_TYPES_JSON;
           Integer i = Task_Manager3.AUTOCOMPLETE_MIN_LENGTH_JSON;
        test.stopTest();
    }

    @isTest
    static void test_getUserPhoto() {
        test.startTest();
           Task_Manager3.getUserPhoto();
           Task_Manager3.getTaskList();
           Task_Manager3.getManagerId();
           Task_Manager3.getUserName();
        test.stopTest();
    }

    @isTest
    static void test_gettaskList() {
        test.startTest();
            Task_Manager3.enableBenchmarking = true;
            Account acct = new Account();
            acct.name = 'Rene Test';
            insert acct;
            Task t = new Task();
            t.Subject = 'Test';
            t.OwnerId = UserInfo.getUserId();
            t.Status = 'Not Started';
            t.Priority = 'Normal';
            t.WhatId = acct.Id;
            insert t;
            Task_Manager3.getObjectTypeById(t.Id);
        test.stopTest();
    }

    @isTest
    static void test_getRelatedObjects() {
        test.startTest();
            Task_Manager3.AUTOCOMPLETE_MIN_LENGTH = 1;
            Task_Manager3.enableBenchmarking = true;
            Account acct = new Account();
            acct.name = 'Rene Test';
            insert acct;
            Account acct2 = new Account();
            acct2.name = 'Gene Test';
            insert acct2;
            Account acct3 = new Account();
            acct3.name = 'Iron Man Test';
            insert acct3;
            Account acct4 = new Account();
            acct4.name = 'Iron Man2 Test';
            insert acct4;
            Task_Manager3.getRelatedObjects(null, 'Tes');
            Task_Manager3.getRelatedObjects('Relationship', null);
            Task_Manager3.getRelatedObjects('Relationship', 'Iron');
            Task_Manager3.getRelatedObjects('Relationship', 'Test');
            Task_Manager3.getRelatedObjects('Lead', 'Test');
        test.stopTest();
    }

    @isTest
    static void test_getUserTasks() {
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard User'
            LIMIT 1
        ];

        User u              = new User();
        u.Alias             = 'Task1';
        u.Email             = 'standarduser@testorg.com';
        u.EmailEncodingKey  = 'UTF-8';
        u.LastName          = 'Testing';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey      = 'en_US';
        u.ProfileId         =  p.Id;
        u.TimeZoneSidKey    = 'America/Los_Angeles';
        u.UserName          = 'standarduser@GRC_Risk.com';
        insert u;

        Lead l        = new Lead();
        l.FirstName   = 'Test Lead Name';
        l.Email       = 'test@Lead.com';
        l.LastName    = 'Test Lead Last Name';
        l.company     = 'Test Co' ;
        l.LeadSource  = 'Idea Bank-New User Registration';
        l.Description = 'Test Lead';
        insert l;
        
        Account a  = new Account();
        a.Name     = 'TestAccount01';
        a.Industry = 'Veterinary';
        insert a;

        Account a2  = new Account();
        a2.Name     = 'TestAccount02';
        a2.Industry = 'Veterinary';
        insert a2;
        
        Contact c         = new Contact();
        c.LastName        = 'Testing1';
        c.AccountId       = a.Id;
        insert c;

        Contact c2         = new Contact();
        c2.LastName        = 'Testing2';
        c2.AccountId       = a2.Id;
        insert c2;

        test.startTest();
            System.runAs(u) {
                Task t = new Task();
                t.Subject = 'Test';
                t.OwnerId = u.Id;
                t.Status = 'Not Started';
                t.Priority = 'Normal';
                t.WhoId = c.Id;
                Task_Manager3.createTask(JSON.serialize(t), new List<Id> { c2.Id });

                Task t2 = new Task();
                t2.Subject = 'Test';
                t2.OwnerId = UserInfo.getUserId();
                t2.Status = 'Not Started';
                t2.Priority = 'Normal';
                insert t2;
                Task_Manager3.getUserTasks(UserInfo.getUserId(),'Not Started');
                Task_Manager3.getUserTasks(null,null);
            }
        test.stopTest();
    }

    @isTest
    static void test_createTask() {
        test.startTest();
            Task_Manager3.enableBenchmarking = true;

            Account accInd = new account();
            accInd.name    = 'individual';
            insert accInd;

            Contact c = new Contact();
            //c.LLC_BI__Type__c = 'Prospect';
            c.LastName = 'Joe';
            c.Account = accInd;
            insert c;

            Task t = new Task();
            t.Subject = 'Test';
            t.OwnerId = UserInfo.getUserId();
            t.Status = 'Not Started';
            t.Priority = 'Normal';
            t.WhatId = accInd.Id;
            Task_Manager3.createTask(JSON.serialize(t), new List<Id> {c.Id});

            Task t2 = new Task();
            t2.Subject = 'Test';
            t2.OwnerId = UserInfo.getUserId();
            t2.Status = 'Not Started';
            t2.Priority = 'Normal';
            t2.ActivityDate = Date.newInstance(1960, 2, 17);
            Task_Manager3.createTask(JSON.serialize(t2), new List<Id>());
        test.stopTest();
    }

    @isTest
    static void test_updateTask() {

        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name LIKE 'Standard User'
            LIMIT 1
        ];

        User u              = new User();
        u.Alias             = 'Task1';
        u.Email             = 'standarduser@testorg.com';
        u.EmailEncodingKey  = 'UTF-8';
        u.LastName          = 'Testing';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey      = 'en_US';
        u.ProfileId         =  p.Id;
        u.TimeZoneSidKey    = 'America/Los_Angeles';
        u.UserName          = 'standarduser@GRC_Risk.com';
        insert u;

        Lead l        = new Lead();
        l.FirstName   = 'Test Lead Name';
        l.Email       = 'test@Lead.com';
        l.LastName    = 'Test Lead Last Name';
        l.company     = 'Test Co' ;
        l.LeadSource  = 'Idea Bank-New User Registration';
        l.Description = 'Test Lead';
        insert l;

        Account a  = new Account();
        a.Name     = 'TestAccount01';
        a.Industry = 'Veterinary';
        insert a;

        Account a2  = new Account();
        a2.Name     = 'TestAccount02';
        a2.Industry = 'Veterinary';
        insert a2;
        
        Contact c         = new Contact();
        c.LastName        = 'Testing1';
        c.AccountId       = a.Id;
        insert c;

        Contact c2         = new Contact();
        c2.LastName        = 'Testing2';
        c2.AccountId       = a2.Id;
        insert c2;
        test.startTest();
            Task_Manager3.enableBenchmarking = true;
            Task t = new Task();
            t.Subject = 'Test';
            t.OwnerId = UserInfo.getUserId();
            t.Status = 'Not Started';
            t.Priority = 'Normal';
            insert t;
            t.subject = '2';
            t.WhoId = c.Id;
            t.ActivityDate = Date.newInstance(1960, 2, 17);
            Task_Manager3.updateTask(JSON.serialize(t), new List<Id> {c2.Id});
            Task_Manager3.updateTask(JSON.serialize(t), new List<Id>());
        test.stopTest();
    }

    @isTest
    static void test_deleteTaskById() {
        test.startTest();
            Task_Manager3.enableBenchmarking = true;
            Task t = new Task();
            t.Subject = 'Test';
            t.OwnerId = UserInfo.getUserId();
            t.Status = 'Not Started';
            t.Priority = 'Normal';
            insert t;
            Task_Manager3.deleteTaskById(t.Id);
        test.stopTest();
    }

    @isTest
    static void test_getAvailUser() {
        test.startTest();
        Task_Manager3.enableBenchmarking = true;
            Profile p = [
                SELECT Id
                FROM Profile
                WHERE Name = 'Standard User'
                LIMIT 1
            ];
            User u              = new User();
            u.Alias             = 'Task1';
            u.Email             = 'standarduser@testorg.com';
            u.EmailEncodingKey  = 'UTF-8';
            u.LastName          = 'Testing';
            u.LanguageLocaleKey = 'en_US';
            u.LocaleSidKey      = 'en_US';
            u.ProfileId         =  p.Id;
            u.TimeZoneSidKey    = 'America/Los_Angeles';
            u.UserName          = 'standarduser@GRC_Risk.com';
            User u2              = new User();
            u2.Alias             = 'Test';
            u2.Email             = 'standarduser1@testorg.com';
            u2.EmailEncodingKey  = 'UTF-8';
            u2.LastName          = 'TaskTest';
            u2.LanguageLocaleKey = 'en_US';
            u2.LocaleSidKey      = 'en_US';
            u2.ProfileId         =  p.Id;
            u2.TimeZoneSidKey    = 'America/Los_Angeles';
            u2.UserName          = 'standarduser1@GRC_Risk.com';
            insert u;
            insert u2;
            Task_Manager3.getAvailUser('User', 'test');
            Task_Manager3.getAvailUser('Cat', 'test');
            Task_Manager3.getUserType('LOB Standard User');
        test.stopTest();
    }
}