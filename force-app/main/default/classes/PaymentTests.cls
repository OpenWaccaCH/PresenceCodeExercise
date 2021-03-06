@isTest
public class PaymentTests {
    private static Contact contact1;
    private static Contact contact2;

    private static Project__c project1;
    private static Project__c project2;
    
    private static Payment__c payment11;
    private static Payment__c payment12;
    private static Payment__c payment21;
    private static Payment__c payment22;

    @IsTest
    private static void testPaymentCalculations(){
        loadData();
        
        Test.startTest();
        // Verify results from initial insert
        System.assertEquals(1123, project1.Total_Payments__c);
        System.assertEquals(12345, project2.Total_Payments__c);
        System.assertEquals(11000, contact1.Total_Payments__c);
        System.assertEquals(2468, contact2.Total_Payments__c);
        System.assertEquals(Date.today(), contact1.Most_Recent_Payment__c);
        System.assertEquals(Date.today().addDays(-2), contact2.Most_Recent_Payment__c);

        // Update Payments then check results
        payment11.Contact__c = contact2.Id;
        payment12.Project__c = project1.Id;
        payment21.Payment_Amount__c = 11235;
        payment22.Payment_Date__c = Date.today();
        Database.update(new List<Payment__c>{payment12, payment21, payment11, payment22});

        // Get Contact and Project records for checking results of update
        loadContacts();
        loadProjects();
        System.assertEquals(22235, project1.Total_Payments__c);
        System.assertEquals(2345, project2.Total_Payments__c);
        System.assertEquals(10000, contact1.Total_Payments__c);
        System.assertEquals(14580, contact2.Total_Payments__c);
        System.assertEquals(Date.today().addDays(-30), contact1.Most_Recent_Payment__c);
        System.assertEquals(Date.today(), contact2.Most_Recent_Payment__c);

        // Delete records to create a state where one Contact has no payments, and one Project has no payments
        Database.delete(new List<Payment__c>{payment12, payment22});
        loadContacts();
        loadProjects();
        System.assertEquals(12235, project1.Total_Payments__c);
        System.assertEquals(null, project2.Total_Payments__c);
        System.assertEquals(null, contact1.Total_Payments__c);
        System.assertEquals(12235, contact2.Total_Payments__c);
        System.assertEquals(null, contact1.Most_Recent_Payment__c);
        System.assertEquals(Date.today(), contact2.Most_Recent_Payment__c);

        // Undelete records to create a state where one Contact has no payments, and one Project has no payments
        Database.undelete(new List<Payment__c>{payment12, payment22});
        loadContacts();
        loadProjects();
        System.assertEquals(22235, project1.Total_Payments__c);
        System.assertEquals(2345, project2.Total_Payments__c);
        System.assertEquals(10000, contact1.Total_Payments__c);
        System.assertEquals(14580, contact2.Total_Payments__c);
        System.assertEquals(Date.today().addDays(-30), contact1.Most_Recent_Payment__c);
        System.assertEquals(Date.today(), contact2.Most_Recent_Payment__c);
        
        Test.stopTest();
        
    }

    @TestSetup
    static void makeData(){
        contact1 = new Contact(FirstName = 'Test', LastName = 'Person1');
        contact2 = new Contact(FirstName = 'Test', LastName = 'Person2');
        Database.insert(new List<Contact>{contact1, contact2});
    
        project1 = new Project__c(Name = 'Test Project1');
        project2 = new Project__c(Name = 'Test Project2');
        Database.insert(new List<Project__c>{project1, project2});
        
        payment11 = new Payment__c(Contact__c = contact1.Id, Project__c = project1.Id, Payment_Amount__c = 1000, Payment_Date__c = Date.today());
        payment12 = new Payment__c(Contact__c = contact1.Id, Project__c = project2.Id, Payment_Amount__c = 10000, Payment_Date__c = Date.today().addDays(-30));
        payment21 = new Payment__c(Contact__c = contact2.Id, Project__c = project1.Id, Payment_Amount__c = 123, Payment_Date__c = Date.today().addDays(-2));
        payment22 = new Payment__c(Contact__c = contact2.Id, Project__c = project2.Id, Payment_Amount__c = 2345, Payment_Date__c = Date.today().addDays(-31));
        Database.insert(new List<Payment__c>{payment11, payment12, payment21, payment22});
    }

    // Loads all of the Data generated by makeData() into static record instances
    private static void loadData(){
        loadContacts();
        loadProjects();
        loadPayments();
    }
    private static void loadContacts(){
        // Clearing out static record instances so this method can be re-called 
        // for checking results throughout unit tests
        contact1 = null;
        contact2 = null;
        for(Contact contact : [select Id, FirstName, LastName, Total_Payments__c, Most_Recent_Payment__c from Contact]){
            if(contact.LastName == 'Person1') contact1 = contact;
            else if(contact.LastName == 'Person2') contact2 = contact;
        }
    }
    private static void loadProjects(){
        // Clearing out static record instances so this method can be re-called 
        // for checking results throughout unit tests
        project1 = null;
        project2 = null;
        for(Project__c project : [select Id, Name, Total_Payments__c from Project__c]){
            if(project.Name == 'Test Project1') project1 = project;
            else if(project.Name == 'Test Project2') project2 = project;
        }
    }
    private static void loadPayments(){
        // Clearing out static record instances so this method can be re-called 
        // for checking results throughout unit tests
        payment11 = null;
        payment12 = null;
        payment21 = null;
        payment22 = null;
        for(Payment__c payment : [select Id, Name, Project__c, Contact__c, Payment_Amount__c, Payment_Date__c from Payment__c]){
            if(payment.Contact__c == contact1.Id && payment.Project__c == project1.Id) payment11 = payment;
            else if(payment.Contact__c == contact1.Id && payment.Project__c == project2.Id) payment12 = payment;
            else if(payment.Contact__c == contact2.Id && payment.Project__c == project1.Id) payment21 = payment;
            else if(payment.Contact__c == contact2.Id && payment.Project__c == project2.Id) payment22 = payment;
        }
    }
}