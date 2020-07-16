public class ProjectUtils {
    public static List<Project__c> calculatePaymentFields(Set<Id> projectIds){
        Map<Id, Project__c> calculatedProjects = new Map<Id, Project__c>();
        List<AggregateResult> AggregateContacts = [select Project__c, Sum(Payment_Amount__c) amount 
                                                    from Payment__c 
                                                    where Project__c in :projectIds 
                                                    group by Project__c];
        for(AggregateResult aggr : AggregateContacts){             
            Project__c calcProject = new Project__c(); 
            calcProject.Id = (Id)aggr.get('Project__c'); 
            calcProject.Total_Payments__c = (decimal)aggr.get('amount');
            calculatedProjects.put(calcProject.Id, calcProject);
        }
        
        // For any Projects that had their last payment deleted they won't 
        // show up in the aggregate results so we need to set their Total_Payments__c to null
        for(Id projectId : projectIds){
            if(!calculatedProjects.keySet().contains(projectId)){
                calculatedProjects.put(projectId, new Project__c(Id=projectId, Total_Payments__c=null));
            }
        }
        
        return calculatedProjects.values();
    }
}