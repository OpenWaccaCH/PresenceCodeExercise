@isTest
public class ProjectPaymentsControllerTest {
    private static Contact contact1;
    private static Contact contact2;

    private static Project__c project1;
    private static Project__c project2;
    
    private static Payment__c payment11;
    private static Payment__c payment12;
    private static Payment__c payment21;
    private static Payment__c payment22;

    @isTest
    private static void testQuerying(){
        loadProjects();

        Test.startTest();
        List<ProjectPaymentsController.ContactWrapper> queryResults = ProjectPaymentsController.getProjectPayments(project1.Id);

        // Check that the query results contain the number of records we're expecting
        System.assertEquals(2, queryResults.size());
        Integer assertionsConfirmed = 0;
        for(ProjectPaymentsController.ContactWrapper wrapper : queryResults){
            System.assertEquals(2, wrapper.contactRecord.Payments__r.size());
            assertionsConfirmed += 1;
        }
        System.assertEquals(2, assertionsConfirmed);

        queryResults = ProjectPaymentsController.getProjectPayments(project2.Id);

        // Check that the query results contain the number of records we're expecting
        System.assertEquals(2, queryResults.size());
        assertionsConfirmed = 0;
        for(ProjectPaymentsController.ContactWrapper wrapper : queryResults){
            System.assertEquals(2, wrapper.contactRecord.Payments__r.size());
            assertionsConfirmed += 1;
        }
        System.assertEquals(2, assertionsConfirmed);
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

    // Load project records that were created by TestSetup
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