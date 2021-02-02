/**
* @author Leila BOUAIFEL
* @date 15/03/2019
* Si les échéances des tâches du process d'onboarding sont dépassé, alors la VF Onboarding_Process se modifie en conséquence 
*/
public with sharing class EcheanceOnboardingDepassee {
    
   public Account acc {get;set;}
   public List<Task> OnboardingTasks {get;set;}
   public boolean OnboardingValue7 {get;set;}
   public boolean OnboardingValue15 {get;set;}
   public boolean OnboardingValue30 {get;set;}
   public boolean OnboardingValue45 {get;set;}
   public boolean OnboardingValue60 {get;set;}
   public boolean OnboardingValue150 {get;set;}
   public boolean OnboardingValue270 {get;set;} 
       
   public EcheanceOnboardingDepassee(ApexPages.StandardController con){
    acc = (Account) con.getRecord(); 
       Onboarding_Process_Value();     
} 
   
	//Get Onboarding Tasks in the past 
		public void Onboarding_Process_Value() {
		system.debug('acc.Id '+acc.Id); 
    	List<Task>	tasks= [SELECT id, Echeance_Onboarding_depasse__c, Accountid FROM task WHERE Echeance_Onboarding_depasse__c != null and accountid =:acc.Id];
                    
    	system.debug('tasks '+tasks);       
        for(Task task : tasks){ system.debug('task.Echeance_Onboarding_depasse__c '+task.Echeance_Onboarding_depasse__c);
                               
            if (task.Echeance_Onboarding_depasse__c == -7 ) OnboardingValue7=true;  
            if (task.Echeance_Onboarding_depasse__c == -15 ) OnboardingValue15=true;
            if (task.Echeance_Onboarding_depasse__c == -30 ) OnboardingValue30=true;
            if (task.Echeance_Onboarding_depasse__c == -45 ) OnboardingValue45=true;
            if (task.Echeance_Onboarding_depasse__c == -60 ) OnboardingValue60=true;
            if (task.Echeance_Onboarding_depasse__c == -150 ) OnboardingValue150=true;
            if (task.Echeance_Onboarding_depasse__c == -270 ) OnboardingValue270=true; 
                                
  		}
       system.debug('OnboardingValue30 '+OnboardingValue30); 
       system.debug('OnboardingValue15 '+OnboardingValue15);      
	} 
          
}