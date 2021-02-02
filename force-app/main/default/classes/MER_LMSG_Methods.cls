/**
 * @File Name          : MER_LMSG_Methods.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 01-12-2021
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/22/2020   Hassan Dakhcha     Initial Version
**/
public class MER_LMSG_Methods {
    // MER List inserted or deleted 
    public static void update_NumMer(List<Mise_en_relation__c> merList, Boolean isDelete) {
        Map<id, Integer> prjNumMerMap = new Map<id, Integer>();
        for(Mise_en_relation__c mer : merList) {
            Integer numMer = prjNumMerMap.get(mer.Projet_LMSG__c);
            if(numMer==null) {
                prjNumMerMap.put(mer.Projet_LMSG__c, 1);
            } else {
                prjNumMerMap.put(mer.Projet_LMSG__c,numMer+1);
            }
        }

        if(prjNumMerMap.isEmpty())
            return;

        List<Projet_LMSG__c> prjList = [SELECT id, Nombre_de_MER__c FROM Projet_LMSG__c WHERE id IN:prjNumMerMap.keySet()];
        for(Projet_LMSG__c prj : prjList) {
            if(prj.Nombre_de_MER__c==null)
                prj.Nombre_de_MER__c = isDelete==true? 0 : prjNumMerMap.get(prj.id);
            else
                prj.Nombre_de_MER__c = isDelete==true? 
                                        (prj.Nombre_de_MER__c<prjNumMerMap.get(prj.id)? 0 : (prj.Nombre_de_MER__c - prjNumMerMap.get(prj.id)))
                                        : 
                                        (prj.Nombre_de_MER__c + prjNumMerMap.get(prj.id));
        }
        
        DataBase.SaveResult[] updateResults = DataBase.update(prjList, false);
        for(DataBase.SaveResult res : updateResults) {
            if(!res.isSuccess()) {
                for(Database.Error err : res.getErrors()) {
                    System.debug('### HDAK : MAJ du nombre de MER a echouée erreur : ');                   
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Champs du document origine de l\'erreur : ' + err.getFields());
                }
            }
        } 
    }

    public static void updateStatusCount(List<Mise_en_relation__c> merList, map<id, Mise_en_relation__c> oldMap, Boolean isInsert) {
        Map<id, Integer> prjDecrValues = new Map<id, Integer>();
        Map<id, Integer> prjIncrValues = new Map<id, Integer>();
        
        // Nombre_de_MER_restantes__c
        // Insert : MER pos/Sel decr
        // Update : passage a pos/sel decr -- sortie de pos/sel incr
        // delete : MER pos/sel incr
        Boolean insertOrDelete = oldMap == null;
        for(Mise_en_relation__c mer : merList) {
            if(insertOrDelete == true && (mer.Statut__c =='Pro_positionne' || mer.Statut__c=='Pro_selectionne')) {
                if(isInsert) {
                    prjDecrValues.put(mer.Projet_LMSG__c, prjDecrValues.get(mer.Projet_LMSG__c)==null? 1 : prjDecrValues.get(mer.Projet_LMSG__c) + 1 );
                } else {
                    prjIncrValues.put(mer.Projet_LMSG__c, prjIncrValues.get(mer.Projet_LMSG__c)==null? 1 : prjIncrValues.get(mer.Projet_LMSG__c) + 1);                  
                }
            }
            if(insertOrDelete == false && ( mer.Statut__c != oldMap.get(mer.id).Statut__c)) {               
                if(mer.Statut__c =='Pro_positionne' || mer.Statut__c =='Pro_selectionne') {
                    prjDecrValues.put(mer.Projet_LMSG__c, prjDecrValues.get(mer.Projet_LMSG__c)==null? 1 : prjDecrValues.get(mer.Projet_LMSG__c) + 1);  
                }
                if(oldMap.get(mer.id).Statut__c =='Pro_positionne' || oldMap.get(mer.id).Statut__c =='Pro_selectionne') {
                    prjIncrValues.put(mer.Projet_LMSG__c, prjIncrValues.get(mer.Projet_LMSG__c)==null ? 1 :  prjIncrValues.get(mer.Projet_LMSG__c)+1);                  
                }
            }
        }
       
        if(prjDecrValues.isEmpty() && prjIncrValues.isEmpty())
            return;

        // Update the counter
        List<Projet_LMSG__c> prjList = [ SELECT id, Nombre_de_MER_restantes__c, Statut__c
                                         FROM Projet_LMSG__c 
                                         WHERE Statut__c='PUBLISHED' AND (id IN:prjDecrValues.keySet() OR id IN:prjIncrValues.keySet())];
        Integer incr = 0 ;
        Integer decr = 0 ;
        for(Projet_LMSG__c prj : prjList) {
            incr = prjIncrValues.get(prj.id) == null ? 0 : prjIncrValues.get(prj.id);
            decr = prjDecrValues.get(prj.id) == null ? 0 : prjDecrValues.get(prj.id);
            
            prj.Nombre_de_MER_restantes__c = math.min( prj.Nombre_de_MER_restantes__c + incr, 3.0);
            if(prj.Nombre_de_MER_restantes__c < decr)
                prj.Nombre_de_MER_restantes__c = 0;
            else
                prj.Nombre_de_MER_restantes__c -=  decr;
        }

        DataBase.SaveResult[] updateResults = DataBase.update(prjList, false);
        for(DataBase.SaveResult res : updateResults) {
            if(!res.isSuccess()) {
                for(Database.Error err : res.getErrors()) {
                    System.debug('### HDAK : MAJ du nombre de MER Restantes a echouée erreur : ');                   
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Champs du document origine de l\'erreur : ' + err.getFields());
                }
            }
        } 
    }

    public static void updateTransactionIdLastUpdatedBySF (List<Mise_en_relation__c> merList) {
        Boolean sfUser = UserInfo.getFirstName() != 'Project' && UserInfo.getLastName() != 'Place';
        Request reqInfo = Request.getCurrent();
        String transaction_id = reqInfo.getRequestId();
        for(Mise_en_relation__c mer : merList) {
            mer.tech_transaction_id__c = transaction_id;
            mer.last_updated_by_sf__c = sfUser;
        }
    }
}