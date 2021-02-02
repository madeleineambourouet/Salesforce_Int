/**
* @author Hassan Dakhcha
* @date 06/01/2020
* @description Controle date d'expiration des documents / MAJ Statut / Declanchement d'envoi mail rappel j-30

* @modification 26/01/2021
*@description mettre les declencheurs vers MC que lorsque aucun autre document du même type que le document qui est expiré ou qui va expiré  
* est toujours valide ou en cours de validation
*/
public with sharing class Batch_DocumentExpires implements Database.Batchable<sObject>, Schedulable  {
    
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator('SELECT id, Date_de_validite__c, Statut__c, Statut__r.key__c, Email_rappel_expiration__c, ' +
                                        ' Tolerate_Expired_Delay__c, Evaluate_Expired__c, Type_de_document__c , MC_Email_Expiration_Assurance__c,Compte_Pro__c,idDocument__c' +
                                        ' FROM Document__c' + 
                                        ' WHERE Date_de_validite__c!=null AND ( Statut__r.key__c = \'EXPIRED\' OR Statut__r.key__c = \'VALIDATED\')'); // AND  Statut__r.key__c != \'EXPIRED\' 
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> docList){     
        date dToday = Date.today();
        List<Document__c> updateList = new List<Document__c> ();
        Integer delay = Integer.valueOf(Label.DocTolerateExpired);

        id docExpireRef = [SELECT id, key__c FROM reference__c WHERE key__c ='EXPIRED' AND recordType.developerName='Statut_Document'].id;

        Map<Id,List<Document__c>> ProWithDocuments = new Map<Id,List<Document__c>>(); 

        List<Document__c> listDocs; 

        List<Document__c> updateFinal = new List<Document__c>(); 

        for(Document__c doc : (List<Document__c>) docList){

            if(ProWithDocuments.isEmpty()){
                listDocs = new List<Document__c>(); 
                listDocs.add(doc);
                ProWithDocuments.put(doc.Compte_Pro__c,listDocs); 

            } else {

                if(ProWithDocuments.containsKey(doc.Compte_Pro__c)){

                    listDocs = ProWithDocuments.get(doc.Compte_Pro__c); 
                    listDocs.add(doc); 
                    ProWithDocuments.put(doc.Compte_Pro__c,listDocs);

                } else {
                    listDocs = new List<Document__c>(); 
                    listDocs.add(doc);
                    ProWithDocuments.put(doc.Compte_Pro__c,listDocs);

                }
                     
            }
        }  

        System.debug('pro with document '+ProWithDocuments);

        Set<Id> idCompteProSet = new Set<Id>();
        idCompteProSet = ProWithDocuments.keySet();

        Integer i = 0;

        for(Id IdPro : idCompteProSet) {

            i = i +1;
            
            List<Document__c> docToAnalyse = ProWithDocuments.get(IdPro);

            List<Document__c> documentToUpdate = this.relanceExpiration(docToAnalyse,IdPro);

            for(Document__c docu :documentToUpdate){
                updateList.add(docu);
            }
            

            for(Document__c doc:docToAnalyse){

                if(doc.Tolerate_Expired_Delay__c != null && doc.Tolerate_Expired_Delay__c < dToday) { // Evaluer le delai :
                    doc.Tolerate_Expired_Delay__c = null;
                    doc.Evaluate_Expired__c = true;
                    updateList.add(doc);
                } 

                if(doc.Statut__c == docExpireRef) { // Document Expiré
                    // si doc expiré sans delai fait par la PP  :
                    if(delay!=0 && doc.Tolerate_Expired_Delay__c==null && doc.Date_de_validite__c > dToday-delay) {
                        doc.Tolerate_Expired_Delay__c = dToday+delay;
                        doc.Evaluate_Expired__c = false;
                        updateList.add(doc);
                    } 
                } else {
                        if(doc.Date_de_validite__c < dToday) {
                        doc.Statut__c = docExpireRef;
                        if(delay!=0) {
                            doc.Tolerate_Expired_Delay__c = dToday+delay;
                            doc.Evaluate_Expired__c = false;
                        }
                        updateList.add(doc);
                    }
                }

            }
        }  
        
        System.debug('nombre de tour '+i);
    
        if(updateList.isEmpty()){
            return;
        } else {
            Map <Id,Document__c> docMap = new Map<Id,Document__c>();
            docMap.putall(updateList);

            if(docMap.size()>0){
                updateFinal = docMap.values();
            }
        }

        DataBase.SaveResult[] updateResults = DataBase.update(updateFinal, false);
        for(DataBase.SaveResult res : updateResults) {
            if(!res.isSuccess()) {
                for(Database.Error err : res.getErrors()) {
                    System.debug('### HDAK : Batch_documentExpires MAJ du document a echouée erreur : ');                   
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Champs du document origine de l\'erreur : ' + err.getFields());
                }
            }
        }
    } 
    
    public void finish(Database.BatchableContext bc){
    }    
    
    public void execute(SchedulableContext context) {
        database.executebatch(this);
    }

    private List<Document__c> relanceExpiration(List<Document__c> docToAnalyse, String IdPro) {

        List<Document__c> expiredDoc = new List<Document__c>();
        List<Document__c> valitedDoc = new List<Document__c>();
        List<Document__c> valitedDocAfter15 = new List<Document__c>();
      
        //Rechercher tous les documents nouveau rattaché au pro 
        
        List<Document__c> relatedNewDoc = [SELECT id, Date_de_validite__c, Statut__c, Statut__r.key__c, Email_rappel_expiration__c,
                                       Tolerate_Expired_Delay__c, Evaluate_Expired__c, Type_de_document__c,MC_Email_Expiration_Assurance__c,
                                       Compte_Pro__c,idDocument__c FROM Document__c WHERE Compte_Pro__c =: IdPro AND Statut__r.key__c ='NEW'];

        //Recuperer tous les documents valide du pro

        List<Document__c> relatedValideDoc = [SELECT id, Date_de_validite__c, Statut__c, Statut__r.key__c, Email_rappel_expiration__c,
                                       Tolerate_Expired_Delay__c, Evaluate_Expired__c, Type_de_document__c,MC_Email_Expiration_Assurance__c,
                                       Compte_Pro__c,idDocument__c FROM Document__c WHERE Compte_Pro__c =: IdPro AND Statut__r.key__c ='VALIDATED'];


        date todayPlus15 = Date.today() + 15;

        for(Document__c docu: relatedValideDoc){

            if(docu.Date_de_validite__c > todayPlus15){
                valitedDocAfter15.add(docu);
            }    
        }
        
        List<Document__c> listToUpdate = new List<Document__c>();


        for(Document__c dcA:docToAnalyse){

            date MC_7 = dcA.Date_de_validite__c + 7;
            date MC_M15 = dcA.Date_de_validite__c - 15;

            if(dcA.Statut__r.key__c=='EXPIRED' && Date.today() == MC_7){
                expiredDoc.add(dcA);
            } 
            
            if(dcA.Statut__r.key__c=='VALIDATED' && Date.today() == MC_M15){
                valitedDoc.add(dcA);
            }

            //Parcourir les documents expirés, pour voir s'il n'ont pas de document du même type validé ou en cours de validation

            if(expiredDoc.size() !=0){ 
                
                for(Document__c exp:expiredDoc){

                    Boolean sameTypeDoc = false;

                    if(relatedValideDoc.size()!=0 && sameTypeDoc == false){
                        for(Document__c docvalid:relatedValideDoc){
                            if(exp.Type_de_document__c == docvalid.Type_de_document__c){
                                sameTypeDoc = true;
                            }
                        }
                    } else {

                        if(relatedNewDoc.size()!=0 && sameTypeDoc == false){
                        
                            for(Document__c newDoc : relatedNewDoc){
                                if(exp.Type_de_document__c == newDoc.Type_de_document__c){
                                    sameTypeDoc= true;
                                }
                            } 
                        }
                    } 

                    if(!sameTypeDoc){ 
                      
                        exp.Email_rappel_apres_expiration__c = true;
                        exp.MC_Email_Expiration_Assurance__c = 'OTHER';
                        switch on exp.Type_de_document__c {
                            when 'insurance_dc' {
                                exp.MC_Email_Expiration_Assurance__c = 'DC';
                            }
                            when 'insurance_rc' {
                                exp.MC_Email_Expiration_Assurance__c = 'RC';
                            }
                        } 
                        listToUpdate.add(exp);
                    } 
                }
            }
    
                   
                

            //Parcourir les documents qui vont expiré à J-15 pour voir s'il n'ont pas de document avec le même qui expire à j+15 ou si 
            // nouveau document du même type en cours de validation 

            if(valitedDoc.size() !=0){ 

                for(Document__c vDoc:valitedDoc){

                    System.debug('document valid à j-15 '+vDoc.idDocument__c);

                    Boolean sameDoc = false;

                    if(valitedDocAfter15.size()!=0 && sameDoc == false){

                        for(Document__c vafter15 : valitedDocAfter15){
                            if(vDoc.Type_de_document__c == vafter15.Type_de_document__c){
                                sameDoc = true;
                            }
                        }       
                    } else {

                        if(relatedNewDoc.size()!=0 && sameDoc == false){
                            for(Document__c newDoc : relatedNewDoc){
                                if(vDoc.Type_de_document__c == newDoc.Type_de_document__c){
                                    sameDoc= true;
                                }
                            } 
                        }     
                    }
                    
                    if(!sameDoc){
                        vDoc.Email_rappel_expiration__c = true;
                        vDoc.MC_Email_Expiration_Assurance__c = 'OTHER';
                        switch on vDoc.Type_de_document__c {
                            when 'insurance_dc' {
                                vDoc.MC_Email_Expiration_Assurance__c = 'DC';
                            }
                            when 'insurance_rc' {
                                vDoc.MC_Email_Expiration_Assurance__c = 'RC';
                            }
                        }
                        listToUpdate.add(vDoc);
                    }
                }
            }    
        }     
        return listToUpdate; 
    }            
}