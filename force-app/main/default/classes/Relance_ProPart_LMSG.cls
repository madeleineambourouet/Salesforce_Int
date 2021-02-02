/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 08-10-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   07-28-2020   Hassan Dakhcha   Initial Version
**/
public class Relance_ProPart_LMSG implements Queueable, Database.AllowsCallouts {
 
    Boolean justDebug = Label.Campagne_Relance_Commit_Debug == 'DEBUG' ? true : false;
    // Relance Pro :  on recupere la liste des projet publié a moins de 48h avec nombre de Mer Restantes > 0 et on relance les pro qui matchent
    List<String> projectWbeIds;
    public Relance_ProPart_LMSG(List<String> projectWbeIds) {
        this.projectWbeIds = new List<String> (projectWbeIds);
    }

    // Relance Part Constructor :
    List<Mise_En_Relation__c> merList;
    public Relance_ProPart_LMSG(List<Mise_En_Relation__c> merList) {
        this.merList = new List<Mise_En_Relation__c> (merList);
    }

    public void execute(QueueableContext context) {
        // Relance Pro
        if(projectWbeIds != null && !projectWbeIds.isEmpty()) {
            this.relancePro();
        }

        // Relance Part
        if(merList != null && !merList.isEmpty()) {
            this.relancePart();
        }
    }

    private void relancePro() {
        // Split the buch into packet of 50 projets
        List<String> subList = new List<String>();
        List<String> listToProcess = new List<String>(projectWbeIds);
        if(projectWbeIds.size()>20) {
            for(Integer idx=20; idx<projectWbeIds.size(); idx++) {
                   subList.add(projectWbeIds[idx]);
                   Integer idxElem = listToProcess.indexOf(projectWbeIds[idx]);
                   if(idxElem != -1) {
                        listToProcess.remove(idxElem);
                   }
            }
            projectWbeIds.clear();
            projectWbeIds = listToProcess.clone();
        }

        // Get Matchs
        List<Map<String, String>> matchList = matchMethods.getMatchList(null, projectWbeIds, true);
        if(matchList != null) {
            // status map:
            //'CREATED' => 'Nouveau' , 'READ' => 'Lu' , 'REFUSED' => 'Refusé' , 'ACCEPTED' => 'Positionné','ARCHIVED' => 'Archivé', 'VIEWED' => 'Lu'};
            if(this.justDebug==true) {
                System.debug('### Relance Pro  : Nombre de Matchs ' + matchList.size());
            }
        
            // filter Matchs 
            Set<String> ctcWbeIds = new Set<String>();
            for(Map<String, String> match : matchList) {
                if( match.get('positionable')=='true' && (match.get('status') == 'CREATED' || match.get('status') == 'READ' || match.get('status') == 'VIEWED')) {
                    if(this.justDebug==true) {
                        System.debug('### Campagne Relance Pro : match pris en compte => ' +  match);
                    }
                    ctcWbeIds.add(match.get('proWbeId'));
                }
            }

            if(!ctcWbeIds.isEmpty()) {
                // Check Calls 
                List<Contact> newList = filterAlreadyCalled(ctcWbeIds);

                if(newList != null && !newList.isEmpty()) {
                    // create File Call Members
                    tagContacts(newList);
                }
            }
        }

        // if there is more project to process so enqueue the job:
        if(!subList.isEmpty()) {
            System.enqueueJob(new Relance_ProPart_LMSG(subList));
        }
    }

    private static List<Contact> filterAlreadyCalled(Set<String> ctcWbeIds) {
        // Get Contact numbers
        Map<id, Contact> ctcMap = new Map<id, Contact> ([SELECT id, MobilePhone, AccountId FROM Contact 
                                                         WHERE External_Contact_Id__c IN :ctcWbeIds AND (Date_Relance_CS_AR3__c=null OR Date_Relance_CS_AR3__c < TODAY) ]);

        if(ctcMap.isEmpty()) {
            return null;
        }

        String ids = '(';
        for(id ctc : ctcMap.keySet()) {
            ids += '\'' + ctc +'\', ';
        }
        ids = ids.substringBeforeLast(',') + ')';

        vhc__Campaign__c campaignPro = [SELECT id, Name FROM vhc__Campaign__c WHERE Name =:Label.Campagne_Relance_Pro_AR3 LIMIT 1];
        String queryStr = 'SELECT id, vhc__Call_File_Member__r.vhc__Campaign__c, vhc__Contact__c FROM vhc__Call__c ' + 
                            Label.Campagne_Relance_Criteres_Filre_Pro + 
                            ' AND vhc__Contact__c!= null AND vhc__Call_File_Member__r.vhc__Campaign__c=\'' + campaignPro.id + '\'' +
                            ' AND vhc__Contact__c IN ' + ids;
        //System.debug('### query = ' + queryStr);
        List<vhc__Call__c> calls = Database.query(queryStr);
        System.debug('### Relance Pro : Nombre pro avant filtre ' + ctcMap.size());

        if(!calls.isEmpty()) {
            for(vhc__Call__c call : calls) {
                System.debug('### Relance Pro existing Calls : ' + call);
                ctcMap.remove(call.vhc__Contact__c);
            }
        }
        System.debug('### Relance Pro : Nombre pro apres filtre ' + ctcMap.size());

        return ctcMap.values();
    }

    private void tagContacts( List<Contact> ctcList) {
        List<Contact> ctcToUpdate = new List<Contact>();
        for(Contact ctc : ctcList) {
            if(this.justDebug==true) {
                System.debug('### Relance Pro  : Contact to tag ' + ctc.id + ' phone ' + ctc.MobilePhone); 
            }
            ctcToUpdate.add(new Contact(id = ctc.id, Date_Relance_CS_AR3__c = DateTime.now()));
        }

        // update contacts :
        Database.SaveResult[] results = Database.update(ctcToUpdate, false);
        for(Database.SaveResult result : results) {
            if(!result.isSuccess()) {
                for(Database.Error err : result.getErrors()) {
                    System.debug('### Relance Pro  : Update date sur le contact a échouée ');                   
                    System.debug('### Relance Pro : ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('### Relance Pro Champs origine de l\'erreur : '  + err.getFields());
                }
            }
        }
    }

    // Relance Part :  on recupere la liste des Mer séléctionée sans RDV et on relance les Part
    private void relancePart() {
        // Map<NumTelephone, IdProjet> : comme ca on élimine les duplicates de numéro de telephone : par exemple si un Part a deux Projets 
        // dans chaque projet on a 2 Mer Selectionné sans RDV, on aura qu'un Call lié a l'un des deux projets (Ticket BUCRM-591)
        Set<Id> projectIds = new Set<Id>();
        for(Mise_en_relation__c mer : merList) {
            projectIds.add(mer.Projet_LMSG__c);
        }
        Map<id, Projet_LMSG__c> projectsToFilter = new Map<id, Projet_LMSG__c>([SELECT id FROM Projet_LMSG__c WHERE Date_Relance_CS_RDV_DEVIS__c = TODAY AND id IN:projectIds]);

        Map<String, id> projects = new Map<String, id>();
        for(Mise_en_relation__c mer : merList) {
            if(this.justDebug==true) {
                System.debug('#### Campagne Relance Part : Tel ' +  mer.Projet_LMSG__r.Telephone_Mobile__c + '  Projet '+ mer.Projet_LMSG__c);
            }
            if(mer.Projet_LMSG__c!=null && !projectsToFilter.containsKey(mer.Projet_LMSG__c) && mer.Projet_LMSG__r.Telephone_Mobile__c!=null) {
                projects.put(mer.Projet_LMSG__r.Telephone_Mobile__c, mer.Projet_LMSG__c);
            }
        }

        List<Projet_LMSG__c> projetToFlag = new List<Projet_LMSG__c>();
        for(String key : projects.keySet()) {
            projetToFlag.add(new Projet_LMSG__c (id = projects.get(key), Date_Relance_CS_RDV_DEVIS__c = DateTime.now()));
            if(this.justDebug==true) {   
                System.debug('### Relance Part  : Projet To tag' + projects.get(key) + ' phone ' + key); 
            }        
        }

        Database.SaveResult[] results = Database.update(projetToFlag, false);
            for(Database.SaveResult result : results) {
                if(!result.isSuccess()) {
                    for(Database.Error err : result.getErrors()) {
                        System.debug('### Relance Part  :Update de la date sur le projet a échouée ');                   
                        System.debug('### Relance Part : ' + err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('### Relance Part Champs origine de l\'erreur : '  + err.getFields());
                    }
                }
        }
    }

    // Appelé par le trigger des contacts une fois la relance est mise sur le projet
    public static void createProjectCallFileMembers(List<Projet_LMSG__c> newProjects, Map<id, Projet_LMSG__c> oldMap ) {

        List<Projet_LMSG__c> projectsToCall = new List<Projet_LMSG__c>();
        for(Projet_LMSG__c newPrj : newProjects) {
            if(newPrj.Date_Relance_CS_RDV_DEVIS__c!=null && oldMap.get(newPrj.id).Date_Relance_CS_RDV_DEVIS__c==null &&
                newPrj.Date_Relance_CS_RDV_DEVIS__c!=oldMap.get(newPrj.id).Date_Relance_CS_RDV_DEVIS__c ) {
                    projectsToCall.add(newPrj);
                }
        }

        if(projectsToCall.isEmpty()) {
            return;
        }

        Boolean justDebug = Label.Campagne_Relance_Commit_Debug == 'DEBUG' ? true : false;
        // Select projects to create call file members
        vhc__Campaign__c campaignPart = [SELECT id FROM vhc__Campaign__c WHERE Name =:Label.Campagne_Relance_Part_RDV_DEVIS LIMIT 1];
        if(CampaignPart == null) {
            System.debug('#### Campagne Relance Part : CS_Relance_PART_RDV_DEVIS introuvable ! ');
            return;
        }
       // Map<id, Projet_LMSG__c> projectsToCall = new Map<id, Projet_LMSG__c>([SELECT id, Telephone_Mobile__c FROM Projet_LMSG__c 
        //                                                                      WHERE Date_Relance_CS_RDV_DEVIS__c = TODAY AND Telephone_Mobile__c != null]);
        List<vhc__Campaign_Member__c> campaignMembers = new List<vhc__Campaign_Member__c>();
        for(Projet_LMSG__c prj : projectsToCall) {
            vhc__Campaign_Member__c call = new vhc__Campaign_Member__c(Projet_LMSG__c = prj.id,
                                                                        vhc__Campaign__c = campaignPart.id,
                                                                        vhc__ClickToDial__c = prj.Telephone_Mobile__c,
                                                                        vhc__Priority__c = 'HIGH',
                                                                        vhc__Status__c = 'To Create');
            campaignMembers.add(call);
            if(justDebug==true) {   
                System.debug('### Relance Part  : Projet ' + prj + ' phone ' + prj.Telephone_Mobile__c); 
                System.debug('### Relance Part  : Call ' + call + ' phone ' + call.vhc__ClickToDial__c); 
            }        
        }
        System.debug('### Relance Part  : Nombre de Calls ' + campaignMembers.size()); 

        if(justDebug==false) {
            Database.SaveResult[] results = Database.insert(campaignMembers, false);
            for(Database.SaveResult result : results) {
                if(!result.isSuccess()) {
                    for(Database.Error err : result.getErrors()) {
                        System.debug('### Relance Part  : Insertion des vhc__Campaign_Member__c a échouée ');                   
                        System.debug('### Relance Part : ' + err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('### Relance Part Champs origine de l\'erreur : '  + err.getFields());
                    }
                }
            }
        }
    }

    // Appelé par le trigger des contacts une fois la relance est mise sur le pro
    public static void createProCallFileMembers(List<Contact> newContact, Map<id, Contact> oldMap) {

        List<Contact> proToCall = new List<Contact>();
        for(Contact ctc : newContact) {
            if(ctc.Date_Relance_CS_AR3__c!=null && oldMap.get(ctc.id).Date_Relance_CS_AR3__c == null &&
                ctc.Date_Relance_CS_AR3__c!=oldMap.get(ctc.id).Date_Relance_CS_AR3__c ) {
                    proToCall.add(ctc);
            }
        }

        if(proToCall.isEmpty()) {
            return;
        }

        Boolean justDebug = Label.Campagne_Relance_Commit_Debug == 'DEBUG' ? true : false;
        vhc__Campaign__c campaignPro = [SELECT id, Name FROM vhc__Campaign__c WHERE Name =:Label.Campagne_Relance_Pro_AR3 LIMIT 1];
        if(CampaignPro == null) {
            System.debug('#### Campagne Relance Pro : CS_Relance_Pro_AR3 introuvable ! ');
            return;
        }
      //  List<Contact> tagedCtc = [SELECT id, AccountId, MobilePhone FROM Contact WHERE MobilePhone!=null AND Date_Relance_CS_AR3__c = TODAY ];
        List<vhc__Campaign_Member__c> campaignMembers = new List<vhc__Campaign_Member__c>();
        for(Contact ctc : proToCall) {
            vhc__Campaign_Member__c call = new vhc__Campaign_Member__c(vhc__Contact__c = ctc.id,
                                                                        vhc__Campaign__c = campaignPro.id,
                                                                        vhc__ClickToDial__c = ctc.MobilePhone,
                                                                        vhc__Priority__c = 'HIGH',
                                                                        vhc__Status__c = 'To Create');
            campaignMembers.add(call);
            if(justDebug==true) {
                System.debug('### Relance Pro  : Contact ' + ctc.id + ' phone ' + ctc.MobilePhone); 
                System.debug('### Relance Pro  : Call ' + call + ' phone ' + call.vhc__ClickToDial__c); 
            }
        }

        if(justDebug==true) {
            System.debug('### Relance Pro  : Nombre de Calls ' + campaignMembers.size()); 
        }

        if(justDebug==false) {
            Database.SaveResult[] results = Database.insert(campaignMembers, false);
            for(Database.SaveResult result : results) {
                if(!result.isSuccess()) {
                    for(Database.Error err : result.getErrors()) {
                        System.debug('### Relance Pro  : Insertion des vhc__Campaign_Member__c a échouée ');                   
                        System.debug('### Relance Pro : ' + err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('### Relance Pro Champs origine de l\'erreur : '  + err.getFields());
                    }
                }
            }
        }
    }


}