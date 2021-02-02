trigger Mail_Intermediation on Projet__c (after update)
{
    Set<Id> Ids = new Set<Id>();
    
    for (Projet__c proj: Trigger.new)
    {
        Projet__c oldproj = Trigger.oldMap.get(proj.Id);
        if (oldproj.email_projet__c != proj.email_projet__c)
            Ids.add(proj.Id);
    }
    
    List<Intermediation__c> child = (Ids.size()>0 ? [SELECT Id, Projet__c, Email_mise_en_relation__c from Intermediation__c where Projet__c in :Ids] : new List<Intermediation__c>());

    List<Intermediation__c> newchild = new List<Intermediation__c>();
    
    for (Projet__c proj2: Trigger.new)
    {
        for (Intermediation__c inter: child)
        {
            if ((inter.Email_mise_en_relation__c != proj2.email_projet__c) && (inter.Projet__c == proj2.Id))
            {
                inter.Email_mise_en_relation__c = proj2.email_projet__c;
                newchild.add(inter);
            }
        }
    }
    if (newchild.isEmpty() == false)
        update newchild;

   /*// old code ==> List<Intermediation__c> child = [SELECT Id, Projet__c, Email_mise_en_relation__c from Intermediation__c where Projet__c = :Ids];
   List<Intermediation__c> child = (Ids.size()>0 ? [SELECT Id, Projet__c, Email_mise_en_relation__c from Intermediation__c where Projet__c = :Ids] : new List<Intermediation__c>());

    List<Intermediation__c> newchild = new List<Intermediation__c>();
    
    for (Projet__c proj2: Trigger.new)
    {
        for (Intermediation__c inter: child)
        {
            if ((inter.Email_mise_en_relation__c != proj2.email_projet__c) && (inter.Projet__c == proj2.Id))
            {
                inter.Email_mise_en_relation__c = proj2.email_projet__c;
                newchild.add(inter);
            }
        }
        if (newchild.isEmpty() == false)
            update newchild;
    }*/
}