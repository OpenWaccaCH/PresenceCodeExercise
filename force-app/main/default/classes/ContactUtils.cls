public class ContactUtils {
    public static List<Contact> calculatePaymentFields(Set<Id> contactIds){
        Map<Id, Contact> calculatedContacts = new Map<Id, Contact>();
        List<AggregateResult> AggregateContacts = [select Contact__c, Sum(Payment_Amount__c) amount, max(Payment_Date__c) maxDate 
                                                    from Payment__c 
                                                    where Contact__c in :contactIds 
                                                    group by Contact__c];
        for(AggregateResult aggr : AggregateContacts){             
            Contact calcContact = new Contact(); 
            calcContact.Id = (Id)aggr.get('Contact__c'); 
            calcContact.Most_Recent_Payment__c = (Date)aggr.get('maxDate'); 
            calcContact.Total_Payments__c = (decimal)aggr.get('amount');
            calculatedContacts.put(calcContact.Id, calcContact);
        } 

        // For any Contacts that had their last payment deleted they won't 
        // show up in the aggregate results so we need to set their Total_Payments__c to null
        for(Id contactId : contactIds){
            if(!calculatedContacts.keySet().contains(contactId)){
                calculatedContacts.put(contactId, new Contact(Id=contactId, Total_Payments__c=null, Most_Recent_Payment__c = null));
            }
        }
        
        return calculatedContacts.values();
    }
}