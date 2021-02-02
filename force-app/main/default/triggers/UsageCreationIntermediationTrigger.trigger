trigger UsageCreationIntermediationTrigger on Intermediation__c (after update) 
{
    //List<List<String>> intermediationIdsList = new List<List<String>>();
    //List<List<String>> intermediationIdsList = new List<List<String>>{new String[]{}};
    List<String> intermediationIdsList = new List<String>();
       
    integer n = 0, i = 0;
    for (Intermediation__c record1 : Trigger.new)
    {
        Intermediation__c oldIntermed = Trigger.oldMap.get(record1.Id);
        if ((record1.IsModified__c == true) && (record1.Date_de_s_lection__c !=NULL) && (record1.IsModified__c != oldIntermed.IsModified__c))
        {     
               //if (n==0) {intermediationIdsList[i] = new String[]{};}
               //intermediationIdsList[i][n] = record1.Id;
               intermediationIdsList.add(record1.Id);
               n++;
               if (n>=50) {
                System.debug('>>>>>>> liste intermediations = ' + intermediationIdsList);
                //if (intermediationIdsList[i].size()>0){
                if (intermediationIdsList.size()>0){
                    System.debug('UsageCreationIntermediationTrigger intermediationIdsList' + ' No: '+ i +' size: '+ intermediationIdsList.size());
                    UsageCreationClass.AppelZuora(intermediationIdsList);
                    intermediationIdsList.clear();
                }
                i++; n = 0;
              }
        }
    }

    if (intermediationIdsList.size()>0){
        System.debug('UsageCreationIntermediationTrigger intermediationIdsList' + ' No: '+ i +' size: '+ intermediationIdsList.size());
        UsageCreationClass.AppelZuora(intermediationIdsList);
    }    
}