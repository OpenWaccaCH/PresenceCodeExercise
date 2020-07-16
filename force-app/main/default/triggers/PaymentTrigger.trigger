trigger PaymentTrigger on Payment__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(trigger.isBefore){
        if(trigger.isInsert)
            PaymentUtils.handleBeforeInsert();
        else if(trigger.isUpdate)
            PaymentUtils.handleBeforeUpdate();
        else if(trigger.isDelete)
            PaymentUtils.handleBeforeDelete();
    }
    else if(trigger.isAfter){
        if(trigger.isInsert)
            PaymentUtils.handleAfterInsert();
        else if(trigger.isUpdate)
            PaymentUtils.handleAfterUpdate();
        else if(trigger.isDelete)
            PaymentUtils.handleAfterDelete();
        else if(trigger.isUndelete)
            PaymentUtils.handleAfterUndelete();
    }
}