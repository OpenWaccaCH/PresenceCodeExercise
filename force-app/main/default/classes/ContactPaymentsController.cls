public with sharing class ContactPaymentsController {
    @AuraEnabled()
    public static void savePayments(List<Payment__c> payments) { 
        Database.upsert(payments);
    }   
    @AuraEnabled()
    public static void deletePayment(Id paymentId) { 
        Database.delete(paymentId);
    } 
}