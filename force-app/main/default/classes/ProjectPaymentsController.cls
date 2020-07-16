public with sharing class ProjectPaymentsController {
    @AuraEnabled(Cacheable=true)
    public static List<ContactWrapper> getProjectPayments(Id projectId) {
        // To avoid querying all of the Contacts in the system, collect the list of 
        // Contacts that have made a payment to the Project in preparation for a
        // second query with the structure that we'll send back to the Component
        Set<Id> referencedContactIds = new Set<Id>();
        for(Payment__c payment : [select Id, Contact__c from Payment__c where Project__c = :projectId]){
            referencedContactIds.add(payment.Contact__c);
        }

        // Now query just the Contacts that have made a payment to the Project and wrap them for sending to 
        List<ContactWrapper> wrapperList = new List<ContactWrapper>();
        for(Contact contact : [SELECT Id, Name, Total_Payments__c, Most_Recent_Payment__c, 
                                (select Id, Name, Payment_Amount__c, Payment_Date__c from Payments__r order by Payment_Date__c desc) 
                                from Contact 
                                where Id in :referencedContactIds])
        {
            wrapperList.add(new ContactWrapper(contact));
        }

        return wrapperList;
    }

    public class ContactWrapper {
        @AuraEnabled
        public Contact contactRecord;
        @AuraEnabled
        public List<Payment__c> paymentRecords;

        public ContactWrapper(Contact contactRecord){
            this.contactRecord = contactRecord;
            this.paymentRecords = new List<Payment__c>();
            for(Payment__c payment : contactRecord.Payments__r){
                this.paymentRecords.add(payment);
            }
        }
    }
}