/**
* @author Charles Howard
* @date 2020
*
* @description Utility class for the Payment__c object that includes trigger handlers
* and utility functions for calculating things on related records
*/

public with sharing class PaymentUtils {
    /* Trigger Handlers */
    public static void handleBeforeInsert(){}
    public static void handleBeforeUpdate(){}
    public static void handleBeforeDelete(){}

    /**
    * @description
    */
    public static void handleAfterInsert(){
        // Collect the list of referenced Projects and Contacts that need to be recalculated
        Set<Id> projectsForRecalc = new Set<Id>();
        Set<Id> contactsForRecalc = new Set<Id>();
        for(Payment__c payment : (List<Payment__c>) Trigger.new)
        {
            projectsForRecalc.add(payment.Project__c);
            contactsForRecalc.add(payment.Contact__c);
        }

        // Make the call to recalculate and update related Project and Contacts
        updateRelatedRecords(projectsForRecalc, contactsForRecalc);
    }

    /**
    * @description
    */
    public static void handleAfterUpdate(){
        // For any updates to Project, Contact, Amount or Date
        // Collect the list of referenced Projects and Contacts that need to be recalculated
        Set<Id> projectsForRecalc = new Set<Id>();
        Set<Id> contactsForRecalc = new Set<Id>();
        for(Payment__c payment : (List<Payment__c>) Trigger.new)
        {
            // Compare the new version of the Payment to the old version and add Contacts
            // and Projects to Id Sets to update, based on the changes that were made
            Payment__c oldPayment = (Payment__c) Trigger.oldMap.get(payment.Id);
            // Project Change
            if(oldPayment.Project__c != payment.Project__c){
                projectsForRecalc.add(oldPayment.Project__c);
                projectsForRecalc.add(payment.Project__c);
            }
            // Contact Change
            if(oldPayment.Contact__c != payment.Contact__c){
                contactsForRecalc.add(oldPayment.Contact__c);
                contactsForRecalc.add(payment.Contact__c);
            }
            // Payment Amount Change
            if(oldPayment.Payment_Amount__c != payment.Payment_Amount__c){
                projectsForRecalc.add(payment.Project__c);
                contactsForRecalc.add(payment.Contact__c);
            }
            // Payment Date Change
            if(oldPayment.Payment_Date__C != payment.Payment_Date__C){
                contactsForRecalc.add(payment.Contact__c);
            }
        }

        // Make the call to recalculate and update related Project and Contacts
        updateRelatedRecords(projectsForRecalc, contactsForRecalc);
    }

    /**
    * @description
    */
    public static void handleAfterDelete(){
        // Collect the list of referenced Projects and Contacts that need to be recalculated
        Set<Id> projectsForRecalc = new Set<Id>();
        Set<Id> contactsForRecalc = new Set<Id>();
        for(Payment__c payment : (List<Payment__c>) Trigger.old)
        {
            projectsForRecalc.add(payment.Project__c);
            contactsForRecalc.add(payment.Contact__c);
        }

        // Make the call to recalculate and update related Project and Contacts
        updateRelatedRecords(projectsForRecalc, contactsForRecalc);
    }

    /**
    * @description
    */
    public static void handleAfterUndelete(){
        // Collect the list of referenced Projects and Contacts that need to be recalculated
        Set<Id> projectsForRecalc = new Set<Id>();
        Set<Id> contactsForRecalc = new Set<Id>();
        for(Payment__c payment : (List<Payment__c>) Trigger.new)
        {
            projectsForRecalc.add(payment.Project__c);
            contactsForRecalc.add(payment.Contact__c);
        }

        // Make the call to recalculate and update related Project and Contacts
        updateRelatedRecords(projectsForRecalc, contactsForRecalc);
    }

    /* Helper Methods */

    /**
    * @description 
    * @param projectsToRecalc
    * @param contactsToRecalc
    */
    private static void updateRelatedRecords(Set<Id> projectsToRecalc, Set<Id> contactsToRecalc){
        // Call helper methods to calculate Payment fields on related Projects and Contacts
        List<Project__c> projectsToUpdate = ProjectUtils.calculatePaymentFields(projectsToRecalc);
        List<Contact> contactsToUpdate = ContactUtils.calculatePaymentFields(contactsToRecalc);
        
        Database.update(projectsToUpdate);
        Database.update(contactsToUpdate);
        
    }
}