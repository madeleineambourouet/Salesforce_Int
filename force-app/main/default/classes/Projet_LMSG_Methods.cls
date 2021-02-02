/**
 * @File Name          : Projet_LMSG_Methods.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 11-30-2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/13/2020   Hassan Dakhcha     Initial Version
**/
public class Projet_LMSG_Methods {
    // generate prestation projets and other details
    // if JSON changes
    public static void updateDetails(List<Projet_LMSG__c> projects, Map<Id,Projet_LMSG__c> oldMap) {
     
        List<Projet_LMSG__c> ppList = new List<Projet_LMSG__c> ();
        for(Projet_LMSG__c projet : projects) {
            if( (oldMap==null && projet.Chiffrage_json__c != null && projet.Chiffrage_json__c !='')
                ||      
                (oldMap!=null && (projet.Chiffrage_json__c != oldMap.get(projet.id).Chiffrage_json__c))) {
                    ppList.add(projet);            
            }

            if( oldMap!=null && projet.Sous_statut__c == 'Qualifie_PP' &&
                (projet.Sous_statut__c != oldMap.get(projet.id).Sous_statut__c)) {
                    projet.ownerId = UserInfo.getUserId();
                }

        }

        if(ppList.isEmpty()) {
            return;
        }

        if(oldMap!=null) { // Update on delete les prestations projet
            deletePP(ppList);
        }
        
        addPP_AndUpdate_Details(ppList, oldMap==null);
        
    }

    public static void addPP_AndUpdate_Details(List<Projet_LMSG__c> projets, Boolean doInsert) {
        List<Prestation_Projet__c> ppList = new List<Prestation_Projet__c> ();
        Set<String> keyCPSet = new Set<String>();
        Set<String> BSKUSet = new  Set<String>();
        for(Projet_LMSG__c projet : projets) {
            TaroUtils.TaroChiffrage taroChiffrage = TaroUtils.getChiffrageFromJson(projet.Chiffrage_json__c);
            //projetLmsg.TaroId__c = taroChiffrage.package_info.id;
            projet.Chiffrage_bsku__c = taroChiffrage.package_info.BSKU;
            BSKUSet.add(taroChiffrage.package_info.BSKU);
            projet.Chiffrage_maximum__c = Decimal.valueof(taroChiffrage.total.maximum);
            projet.Chiffrage_minimum__c= Decimal.valueof(taroChiffrage.total.minimum);
            projet.TaroId__c = taroChiffrage.postalCode.postalCode +'_'+ taroChiffrage.postalCode.inseeCode;
            keyCPSet.add(taroChiffrage.postalCode.postalCode +'_'+ taroChiffrage.postalCode.inseeCode);
            if(!doInsert)
                ppList.addAll(TaroUtils.getPrestationsFromChiffrage(taroChiffrage, projet.Id));
        }

        // set the CP reference
        List<Reference__c> refCpList = [SELECT id,Key__c  from Reference__c where Lov_Type__c = 'CP_Ville' and Key__c IN :keyCPSet and Active_PP__c = true];
        Map<String, id> keyIdCpMap = new Map<String, id>();
        for(Reference__c ref : refCpList) {
            keyIdCpMap.put(ref.key__c, ref.id);
        }

        // set the BSKU reference :
        List<Reference__c> BesoinsTravaux = [SELECT id, Name, sku__c FROM Reference__c WHERE RecordType.developerName ='Besoins_Travaux' AND sku__c IN:BSKUSet];
        Map<String, id> bskuRefMap = new  Map<String, id>();
        for(Reference__c ref : BesoinsTravaux) {
            bskuRefMap.put(ref.sku__c, ref.id);
        }

        for(Projet_LMSG__c projet : projets) {
            projet.Code_postal__c = keyIdCpMap.get(projet.TaroId__c);
            projet.TaroId__c = '';
            projet.Besoin_Travaux__c = bskuRefMap.get(projet.Chiffrage_bsku__c);
        }
             
        if(!ppList.isEmpty()) {
            DataBase.SaveResult[] insertResults = DataBase.insert(ppList, false);
            for(DataBase.SaveResult res : insertResults) {
                if(!res.isSuccess()) {
                    for(Database.Error err : res.getErrors()) {
                        System.debug('### HDAK generatePrestationProjet :  insert a echouée erreur : ');                   
                        System.debug('### HDAK ' + err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('### HDAK Champs origine de l\'erreur : ' + err.getFields());
                    }
                }
            }
        }
    }
    public static void deletePP(List<Projet_LMSG__c> projets) {
        Set<id> prjSet = new Set<id>();
        for(Projet_LMSG__c p : projets) {
            prjSet.add(p.id);
        }
   
        List<Prestation_Projet__c> ppList = [SELECT id, Projet_LMSG__c FROM Prestation_Projet__c WHERE Projet_LMSG__c IN:prjSet];
        DataBase.DeleteResult[] deleteResults = DataBase.delete(ppList, false);
        for(DataBase.DeleteResult res : deleteResults) {
            if(!res.isSuccess()) {
                for(Database.Error err : res.getErrors()) {
                    System.debug('### HDAK  : delete des prestation projet a echouée erreur : ');                   
                    System.debug('### HDAK : ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('### HDAK Champs origine de l\'erreur : ' + err.getFields());
                }
            }
        }
    }

    public static void insertPP(List<Projet_LMSG__c> projets) {
        List<Prestation_Projet__c> ppList = new List<Prestation_Projet__c> ();
        for(Projet_LMSG__c projet : projets) {
            TaroUtils.TaroChiffrage taroChiffrage = TaroUtils.getChiffrageFromJson(projet.Chiffrage_json__c);
            ppList.addAll(TaroUtils.getPrestationsFromChiffrage(taroChiffrage, projet.Id));
        }
        if(!ppList.isEmpty()) {
            DataBase.SaveResult[] insertResults = DataBase.insert(ppList, false);
            for(DataBase.SaveResult res : insertResults) {
                if(!res.isSuccess()) {
                    for(Database.Error err : res.getErrors()) {
                        System.debug('### HDAK generatePrestationProjet :  insert a echouée erreur : ');                   
                        System.debug('### HDAK ' + err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('### HDAK Champs origine de l\'erreur : ' + err.getFields());
                    }
                }
            }
        }
    }

    // flag last updated by sf
    public static void setIsUpdatedBySF(List<Projet_LMSG__c> prjList, Map<Id,Projet_LMSG__c> oldMap) {
        Boolean sfUser = UserInfo.getFirstName() != 'Project' && UserInfo.getLastName() != 'Place';
        Request reqInfo = Request.getCurrent();
        String transaction_id = reqInfo.getRequestId();
        for(Projet_LMSG__c prj : prjList) {
            // Transaction id for synchro :
            prj.tech_transaction_id__c = transaction_id;

            if(System.isBatch() || System.isQueueable()) {
                prj.last_updated_by_sf__c = false;
            } else {
                if(oldMap!=null && prj.Statut__c == 'PUBLISHED' && prj.Statut__c != oldMap.get(prj.id).Statut__c ) { // Si le projet passe a publié alors notifier la PP
                    prj.last_updated_by_sf__c = true;
                } else {
                    prj.last_updated_by_sf__c = sfUser;
                }
            }
        }
    }

     // Maj lead id on projet a la creation du projet
    public static void majIdLeadAndProjetHYStatus(List<Projet_LMSG__c> prjList) {
        
        Set<id> parentIdSet = new Set<id> ();
        for(Projet_LMSG__c prj : prjList ){
            if( prj.Projet_Parent__c != null && prj.idLead__c == null) {
                parentIdSet.add( prj.Projet_Parent__c);
            }
        }

        if(parentIdSet.isEmpty()) {
            return;
        }

        // Mettre a jour le statut du projet HY
        List<Projet__c> updateHY = new List<Projet__c>();
        for(id prjID : parentIdSet) {
            updateHY.add(new Projet__c(id = prjID, Statut_Projet__c='Transformé PP', Etat__c='ODC close')); 
        }
        Database.SaveResult[] results = Database.update(updateHY, false);
       for(DataBase.SaveResult res : results) {
            if(!res.isSuccess()) {
                for(Database.Error err : res.getErrors()) {
                    System.debug('### HDAK  : majIdLeadAndProjetHYStatus Update des projetHY a echouée erreur : ');                   
                    System.debug('### HDAK : ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('### HDAK Champs origine de l\'erreur : ' + err.getFields());
                }
            }
        }

        // get tracking 
        List<Tracking__c> trackList = [SELECT id, idLead__c, parentId__c FROM Tracking__c WHERE parentId__c IN :parentIdSet];
        if(trackList.isEmpty()) {
            return;
        }
        
        Map<String, String> mapParentLead = new Map<String, String>();
        for(Tracking__c trk : trackList) {
            if(mapParentLead.get(trk.parentId__c) == null) {
                mapParentLead.put(trk.parentId__c, trk.idLead__c);
            }
        }
        for(Projet_LMSG__c prj : prjList) {
            if(prj.Projet_Parent__c != null) {
                String idLead = mapParentLead.get(prj.Projet_Parent__c);
                if(idLead != null && idLead !='') {
                    prj.idLead__c = idLead;
                }
            }
        }
    }

    // At before insert we copy the phone from the person account
    public static void copyPhoneFromPart(List<Projet_LMSG__c> projects) {
        Set<Id> accSet = new Set<Id> ();
        for(Projet_LMSG__c prj : projects) {
            accSet.add(prj.Particulier__c);
        }
        if(accSet.isEmpty()) {
            return;
        }
        Map<id, Account> accMap = new Map<id, Account>([SELECT id , Phone, PersonMobilePhone FROM Account WHERE id IN :accSet]);

        for(Projet_LMSG__c prj : projects) {
            if (accMap.containsKey(prj.Particulier__c)) {
                prj.Telephone_Mobile__c = accMap.get(prj.Particulier__c).PersonMobilePhone != null ? accMap.get(prj.Particulier__c).PersonMobilePhone : accMap.get(prj.Particulier__c).Phone;
            }
        }
    }

    public static void updateNumMerRestantes(List<Projet_LMSG__c> newList, Map<Id,Projet_LMSG__c> oldMap) {

        // Si on passe a publié alors nombre de MER restantes = 3
        // Si on quite publié alors le nombre de MER restantes = 0
        for(Projet_LMSG__c projet : newList) {
            if(projet.Statut__c != oldMap.get(projet.id).Statut__c) {
                if(projet.Statut__c == 'PUBLISHED') {
                    projet.Nombre_de_MER_restantes__c = 3;
                } else {
                    projet.Nombre_de_MER_restantes__c = 0;
                }
            }
        }
    }

    @InvocableMethod(Label='Calculer la priorité' Description='Retourne la priorité de l\'appel selon l\'heure local')
    public static List<String> getCallMemberPriority(List<String> hours) {
        Decimal hourNow =  Datetime.now().hour();
        Decimal startHour = 9;
        Decimal endHour = 19;
        Integer bulkSize = hours.size();
        if(bulkSize>0) {
            List<String> splitedList = new List<String> (hours[0].split(';'));
            startHour = Decimal.valueOf(splitedList[0]);
            endHour = Decimal.valueOf(splitedList[1]);
        }
    
        String Priority = hourNow < startHour || hourNow >= endHour ? 'MEDIUM' : 'HIGH';
        List<String> prio = new List<String>();
        for(Integer i=0 ; i<bulkSize; i++) {
            prio.add(Priority);
        }
        return prio; 
    }

}