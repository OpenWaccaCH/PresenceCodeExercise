@isTest
public class ContactPaymentsControllerTest {
    private static Contact contact1;
    private static Contact contact2;

    private static Project__c project1;
    private static Project__c project2;

    @isTest
    private static void createUpdateDeletePayments(){
        loadProjects();
        loadContacts();

        Test.startTest();
        Payment__c payment1 = new Payment__c(Project__c = project1.Id, Contact__c = contact1.Id, Payment_Amount__c = 100, Payment_Date__c = Date.today());
        Payment__c payment2 = new Payment__c(Project__c = project1.Id, Contact__c = contact2.Id, Payment_Amount__c = 1000, Payment_Date__c = Date.today());
        
        // Check handling insert
        ContactPaymentsController.savePayments(new List<Payment__c>{payment1, payment2});
        List<Payment__c> checkPayments = [select Id from Payment__c];
        System.assertEquals(2, checkPayments.size());

        // Check handing insert and update
        payment1.Payment_Amount__c = 400;
        Payment__c payment3 = new Payment__c(Project__c = project2.Id, Contact__c = contact2.Id, Payment_Amount__c = 1000, Payment_Date__c = Date.today());
        ContactPaymentsController.savePayments(new List<Payment__c>{payment1, payment3});
        checkPayments = [select Id from Payment__c];
        System.assertEquals(3, checkPayments.size());

        // Check handing delete
        ContactPaymentsController.deletePayment(payment2.Id);
        checkPayments = [select Id from Payment__c];
        System.assertEquals(2, checkPayments.size());

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
    }

    // Load Contacts that were created by TestSetup
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
    // Load Projects that were created by TestSetup
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
}