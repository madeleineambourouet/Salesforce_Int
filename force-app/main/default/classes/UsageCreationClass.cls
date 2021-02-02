//08/06/2018 Mofidied by Qiuyan Liu, optimization project's foncitonalities, update error message on another object instead of updating Intermediation__c itself
public class UsageCreationClass
{
    
    @future(callout = true)
    public static void AppelZuora(list<string> listeintegrationids)
    {
        List<Exception_Control__c> ecList = new List<Exception_Control__c>();
        List<Intermediation__c> intermediationsList = [SELECT Contact__r.MobilePhone,Contact__r.Email,Contact__r.name,ID_COMPETENCE__c,Id,Professionnel__c, CreatedDate, Projet__r.Particulier__r.Name, Projet__r.Code_postal__r.Name FROM Intermediation__c WHERE Id IN :listeintegrationids];
        // Liste des noms des references des mises en relation
        List<String> nameCompetenceList = new List<String>();
        
        List<Intermediation__c> intermediationsToUpdateList = new List<Intermediation__c>();
        for (Intermediation__c inter : intermediationsList)
            nameCompetenceList.add(inter.ID_COMPETENCE__c);

        List<Zuora__CustomerAccount__c> billingaccount = [select Zuora__AccountNumber__c, Zuora__Account__c from Zuora__CustomerAccount__c where Zuora__Account__c in (select Professionnel__c from Intermediation__c)];
        List<Reference__c> Reference = [SELECT Id, Name, Key__c, Libelle__c, Libelle_2__c, Libelle_3__c, code__c from Reference__c where key__c in: nameCompetenceList];
        List<Reference__c> Rateplan = [SELECT Id, Name, Key__c, Libelle__c, code__c from Reference__c where key__c = 'RATEPLAN'];
        
        if ((intermediationsList.size()>0) && (billingaccount.size()>0)) 
        {        
            List<Zuora.zObject> usagelist= new List<Zuora.zObject>();
            for (Intermediation__c intermed : intermediationsList)
            {
                for (Zuora__CustomerAccount__c custom : billingaccount)
                {
                    if (intermed.Professionnel__c==custom.Zuora__Account__c)
                    {
                        Zuora.zObject res = new Zuora.zObject('Usage');
                        res.setValue('AccountNumber', custom.Zuora__AccountNumber__c);
                        res.setValue('StartDateTime', string.valueof(system.today())+'T00:00:00');
                        String Rateplan_str = (Rateplan != null && Rateplan.size() > 0 && Rateplan[0].key__c == 'RATEPLAN' ? Rateplan[0].Libelle__c : 'JE SUIS JUSTE UN TEST');
                        res.setValue('UOM', (Reference != null && Reference.size() > 0 && Rateplan[0].Libelle__c == Reference[0].Libelle_2__c ? Reference[0].Libelle_3__c : ''));
                        res.setValue('Quantity', 1);
                        String Geocat_str = intermed.Contact__r.name + ' ' + '[' + intermed.Contact__r.MobilePhone + '/' + intermed.Contact__r.Email + ']';
                        res.setValue('ContactGeocat__c',Geocat_str);
                        res.setValue('Description', (Reference != null && Reference.size() > 0 ? Reference[0].Libelle__c : ''));
                        res.setValue('ClientPart__c',intermed.Projet__r.Particulier__r.Name);
                        res.setValue('CodePostalPart__c',intermed.Projet__r.Code_postal__r.Name);
                        usagelist.add(res);
                    } 
                }
            }
            
            Zuora.zApi zuoraapi = ZuoraUtilities.zuoraApiAccess();
            List<Zuora.zApi.SaveResult> saveresultlist = ZuoraUtilities.createZuoraObjects(zuoraApi,usagelist);
            system.debug('>>>>>>>>>>>> saveresultlist :' + saveresultlist);
            system.debug(ZuoraUtilities.analyzeSaveResult(saveresultlist.get(0)));
            
            Integer n = 0;
            for (Zuora.zApi.SaveResult saveResult : saveresultlist)
            {
                if (ZuoraUtilities.analyzeSaveResult(saveResult).size()>0) {
                    Exception_Control__c ec = new Exception_Control__c(Objet__c='Intermediation__c', Record_Id__c=intermediationsList.get(n).Id, Function_Name__c='UsageCreationClass', ErrorMSG__c='Erreur : ' + String.join(ZuoraUtilities.analyzeSaveResult(saveResult), '/'));
                    ecList.add(ec);
                }
                /*Intermediation__c intermedToUpdate = new Intermediation__c(Id = intermediationsList.get(n).Id,
                                                                           resultatEnvoiZuora__c= (ZuoraUtilities.analyzeSaveResult(saveResult).size()>0 ? ZuoraUtilities.analyzeSaveResult(saveResult)[0] : 'OK'));
                Intermediation__c intermedToUpdate = new Intermediation__c(Id = intermediationsList.get(n).Id,
                                                                           resultatEnvoiZuora__c= (ZuoraUtilities.analyzeSaveResult(saveResult).size()>0 ? String.join(ZuoraUtilities.analyzeSaveResult(saveResult), '/') : 'OK'));
                intermediationsToUpdateList.add(intermedToUpdate);
                system.debug('>>>>>>>>>>>> intermedToUpdate :' + intermedToUpdate); */
                n++;
            }
        }
        if (ecList.size() > 0) {
            insert ecList;
        }
        //update intermediationsToUpdateList;
    }    
}