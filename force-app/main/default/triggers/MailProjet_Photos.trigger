trigger MailProjet_Photos on Projet__c (after update)
{
    Set<Id> Ids = new Set<Id>();
    
    for (Projet__c proj: Trigger.new)
    {
        Projet__c oldproj = Trigger.oldMap.get(proj.Id);
        if (oldproj.email_projet__c != proj.email_projet__c)
            Ids.add(proj.Id);
    }
    
    List<Photo__c> child = (Ids.size()>0 ? [SELECT Id, Projet__c, email_projet__c from Photo__c where Projet__c in :Ids] : new List<Photo__c>());
    List<Photo__c> newchild = new List<Photo__c>();
    
    for (Projet__c proj2: Trigger.new)
    {
        for (Photo__c photo: child)
        {
            if (photo.Projet__c == proj2.Id && photo.Email_projet__c != proj2.email_projet__c)
            {
                photo.Email_projet__c = proj2.email_projet__c;
                newchild.add(photo);
            }
        }
    }
    if (newchild.isEmpty() == false)
        update newchild;
    
    /*// old code ==> List<Photo__c> child = [SELECT Id, Projet__c, email_projet__c from Photo__c where Projet__c = :Ids];
    List<Photo__c> child = (Ids.size()>0 ? [SELECT Id, Projet__c, email_projet__c from Photo__c where Projet__c = :Ids] : new List<Photo__c>());
    List<Photo__c> newchild = new List<Photo__c>();
    
    for (Projet__c proj2: Trigger.new)
    {
        for (Photo__c photo: child)
        {
            if (photo.Email_projet__c != proj2.email_projet__c)
            {
                photo.Email_projet__c = proj2.email_projet__c;
                newchild.add(photo);
            }
        }
        if (newchild.isEmpty() == false)
            update newchild;
    }*/
}