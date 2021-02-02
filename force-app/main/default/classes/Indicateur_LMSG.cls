/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 11-27-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   08-11-2020   Hassan Dakhcha   Initial Version
**/
public class Indicateur_LMSG {

    public static void account_LMSG(List<Account> accounts, Map<id, Account> oldMap) {
        for(Account acc : accounts) {
            if(acc.isPersonAccount == true && acc.Compte_Nouvelles_Offres__c == true && 
                (oldMap==null || acc.Compte_Nouvelles_Offres__c != oldMap.get(acc.id).Compte_Nouvelles_Offres__c))
                acc.Date_nouveau_client__c = Datetime.now();
        }
    }

    /*
    Projet LMSG
            'Date_modification_statut__c ' => 'Statut__c' => 'ALL'
            'Date_Dernier_Statut_Depose__c' => 'Statut__c' => 'VALIDATING'
            'Date_qualification_PP__c' => 'Statut__c;Sous_statut__c' => 'VALIDATING;Qualifie_PP,Differe,Non_publiable'
            'Date_publication_PP' => 'Statut__c' => 'PUBLISHED'  
    */
    public static void projet_LMSG(List<Projet_LMSG__c> newProjects, Map<Id, Projet_LMSG__c> oldMap) {
        //projectMaps();
        for(Projet_LMSG__c project : newProjects) {
            System.debug('#### statut ' + project.Statut__c );
            System.debug('#### Sous statut ' + project.Sous_Statut__c );
    
            if(oldMap==null) { // Insert
                project.Date_modification_statut__c = Datetime.now();
                if(project.Statut__c == 'VALIDATING') {
                    project.Date_dernier_statut_depose__c = Datetime.now();
                }
            } else {
                System.debug('#### Old Statut = ' + oldMap.get(project.id).Statut__c);
                System.debug('#### Old Sous Statut = ' + oldMap.get(project.id).Sous_Statut__c );

                if(project.Statut__c != oldMap.get(project.id).Statut__c) {
                    project.Date_modification_statut__c = Datetime.now();
                    if(project.Statut__c == 'VALIDATING') {
                        project.Date_dernier_statut_depose__c = Datetime.now();
                    }
                    if(project.Statut__c == 'PUBLISHED') {
                        project.Date_publication_PP__c = Datetime.now();
                    }
                }
                if( project.Statut__c == 'VALIDATING' &&
                    project.get('Sous_statut__c') != oldMap.get(project.id).get('Sous_statut__c') && 
                    (project.get('Sous_statut__c') == 'Qualifie_PP' 
                     || project.get('Sous_statut__c') == 'Differe' 
                     || project.get('Sous_statut__c') == 'Non_publiable') ) {
                        project.Date_qualification_PP__c = Datetime.now();
                }
            }
        }
    }

    /*
    MER 
            'Date_modification_statut__c' => 'Statut__c' => 'ALL'
            'Date_modification_statut_RDV__c' => 'statut_RDV__c' => 'ALL'
            'Date_positionnement__c' => 'Statut__c' => 'Pro_positionne'
            'Date_selection__c' => 'Statut__c' => 'Pro_selectionne'
   */
    public static void merLMSG(List<Mise_en_relation__c> newMer, Map<id, Mise_en_relation__c> oldMap) {
        for(Mise_en_relation__c mer : newMer) {
            if(oldMap==null) {
                mer.Date_modification_statut__c = Datetime.now();
                mer.Date_modification_statut_RDV__c = Datetime.now();
                if(mer.Statut__c == 'Pro_positionne') {
                    mer.Date_positionnement__c = Datetime.now();
                }
                if(mer.Statut__c == 'Pro_selectionne') {
                    mer.Date_selection__c = Datetime.now();
                }
            } else {
                if(mer.Statut__c != oldMap.get(mer.id).Statut__c) {
                    mer.Date_modification_statut__c = Datetime.now();
                    if(mer.Statut__c == 'Pro_positionne') {
                        mer.Date_positionnement__c = Datetime.now();
                    }
                    if(mer.Statut__c == 'Pro_selectionne') {
                        mer.Date_selection__c = Datetime.now();
                    }
                } 
                if(mer.statut_RDV__c != oldMap.get(mer.id).statut_RDV__c) {
                    mer.Date_modification_statut_RDV__c = Datetime.now();
                }
            }
        }
    }

    /*
    Devis LMSG
    'Date_modification_statut__c' => 'Statut__c' => 'ALL'
    'Date_signature_devis' => 'Statut__c' => 'SIGNED'

    Modification le 19/01/2021 ->date signature devis rempli uniquement pour les devis de type Devis
    */
    public static void devisLMSG(List<Devis_LMSG__c> newQuotes, Map<id, Devis_LMSG__c> oldMap) {
        List<id> signedQuotes = new List<id>();
        for(Devis_LMSG__c quote : newQuotes) {
            if(oldMap==null) {
                quote.Date_modification_statut__c = Datetime.now();
            } else {
                if(quote.Statut__c != oldMap.get(quote.id).Statut__c) {
                    quote.Date_modification_statut__c = Datetime.now();
                    if(quote.Statut__c == 'SIGNED') {
                        quote.Date_signature_devis__c = Datetime.now();
                        if(quote.Type_de_devis__c == 'INITIAL'){
                            signedQuotes.add(quote.id);
                        }
                    }
                } 
            }
        }
        if(!signedQuotes.isEmpty()) {
            List<Devis_LMSG__c> quoteList = [SELECT id, Mise_en_relation_LMSG__c, Mise_en_relation_LMSG__r.Projet_LMSG__c FROM Devis_LMSG__c WHERE id IN :signedQuotes];
            Set<id> ids = new Set<id>();
            for(Devis_LMSG__c quote : quoteList) {
                if(quote.Mise_en_relation_LMSG__c!=null) {
                    ids.add(quote.Mise_en_relation_LMSG__r.Projet_LMSG__c);
                }
            }
            List<Projet_LMSG__c> projectToUpdate = new List<Projet_LMSG__c> ();
            for(id prj : ids) {
                projectToUpdate.add(new Projet_LMSG__c(id=prj, Date_signature_devis__c = Datetime.now()));
            }
            DataBase.update(projectToUpdate, false);
        }
    }

    /*
    Facture LMSG :
    'Date_modification_statut__c' => 'Statut__c'  => 'ALL CHANGES'
    */
    public static void factureLMSG(List<Facture__c> newBills, Map<id, Facture__c> oldMap) {
        for(Facture__c bill : newBills) {
            if(oldMap==null || bill.Statut__c != oldMap.get(bill.id).Statut__c) {
                bill.Date_modification_statut__c = Datetime.now();
            }
        }
    }

    // Mise a jour des dates sur le projets : Facture de commission/et d'accompte
    public static void updateInvoiceProject(List<Facture__c> invoices) {
        Set<id> idSet = new Set<id> ();
        for(Facture__c invoice : invoices) {
            System.debug('************ type fac = '+ invoice.type_facture__c + ' date create = ' + invoice.Date_creation_facture__c);
            if(invoice.Type_facture__c == 'DOWN_PAYMENT' || invoice.Type_facture__c == 'FEE_PAYMENT') {
                idSet.add(invoice.Mise_en_relation__c);
            }
        }
        if(idSet.isEmpty()) {
            return;
        }
        Map<id, Mise_en_relation__c> merMap = new Map<id, Mise_en_relation__c>([SELECT id, Projet_LMSG__c FROM Mise_en_relation__c WHERE id IN :idSet]);
        Map<id, Facture__c> prjInvDownPaiementMap = new Map<id, Facture__c>();
        Map<id, Facture__c> prjInvFeePaiementMap  = new Map<id, Facture__c>();
        idSet.clear();
        for(Facture__c invoice : invoices) {
            if(invoice.Mise_en_relation__c!=null) {
                id projectId = merMap.get(invoice.Mise_en_relation__c).Projet_LMSG__c;
                if(projectId!=null) {
                    if(invoice.Type_facture__c == 'DOWN_PAYMENT') {
                        idSet.add(projectId);
                        prjInvDownPaiementMap.put(projectId, invoice);
                    } else if(invoice.Type_facture__c == 'FEE_PAYMENT') {
                        idSet.add(projectId);
                        prjInvFeePaiementMap.put(projectId, invoice);
                    }
                }
            }
        }
        List<Projet_LMSG__c> ProjectList = new List<Projet_LMSG__c>();
        for(Id projectId : idSet) {
            Facture__c downInvoice = prjInvDownPaiementMap.get(projectId);
            Facture__c feeInvoice = prjInvFeePaiementMap.get(projectId);

            if(downInvoice!=null && feeInvoice!=null) {
                ProjectList.add(new Projet_LMSG__c(id = projectId, 
                                Date_facture_acompte_emise__c = downInvoice.Date_creation_facture__c==null ? date.toDay() : downInvoice.Date_creation_facture__c,
                                Date_facture_commission__c = feeInvoice.Date_creation_facture__c==null ? date.toDay() : feeInvoice.Date_creation_facture__c));
            } else if(downInvoice!=null) {
                ProjectList.add(new Projet_LMSG__c(id = projectId, 
                                                    Date_facture_acompte_emise__c = downInvoice.Date_creation_facture__c==null ? date.toDay() : downInvoice.Date_creation_facture__c));
            } else if(feeInvoice!=null) {
                ProjectList.add(new Projet_LMSG__c(id = projectId, 
                                                    Date_facture_commission__c = feeInvoice.Date_creation_facture__c==null ? date.toDay() : feeInvoice.Date_creation_facture__c));
            }
        }

        if(!ProjectList.isEmpty()) {
            DataBase.SaveResult[] updateResults = DataBase.update(ProjectList, false);
            for(DataBase.SaveResult res : updateResults) {
                if(!res.isSuccess()) { for(Database.Error err : res.getErrors()) {
                        System.debug('### HDAK  updateProject from facture trigger : echec de l \'update du DB du project : ');                   
                        System.debug('### HDAK : ' + err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('### HDAK Champs origine de l\'erreur : ' + err.getFields());
                    }
                }
            }
        }
    }


    /* Document paiement indicators for KBIS, ID, RIB, Statut, UBO
        MUST BE CALLED IN AFTER TRIGGER
    */
    public static void docPaiement(List<Document__c> newDocs, Map<id, Document__c> oldMap) { 
        Set<String> kybs = new Set<String> {'kbis','rib','id','company_status'};
        Set<id> accSet = new Set<id>();
        for(Document__c doc : newDocs) {
            if( doc.Compte_Pro__c == null || !kybs.contains(doc.Type_de_document__c)) {
                continue;
            }        
            // When new doc or status changed on a doc, process kyb docs for the Pro
            if(oldMap == null || doc.Statut__c != oldMap.get(doc.id).Statut__c) {
                accSet.add(doc.Compte_Pro__c);
            }
        }
        if(accSet.isEmpty()) {
            return;
        }
        //process kyb for pro :
        Set<id> kbisOk = new Set<id>();
        Set<id> ribOk = new Set<id>();
        Set<id> idOk = new Set<id>();
        Set<id> statusOk = new Set<id>();
        Set<id> kbisWaiting = new Set<id>();
        Set<id> ribWaiting = new Set<id>();
        Set<id> idWaiting = new Set<id>();
        Set<id> statusWaiting = new Set<id>();
        Map<id, reference__c> EiEirl = new Map<id, reference__c> ([SELECT id FROM Reference__c 
                                                                   WHERE RecordType.DeveloperName='Statut_juridique' AND (key__c='EI' OR key__c ='EIRL')]);
        Set<id> refId = new Set<id>();
        refId.addAll(EiEirl.keySet());
        List<Document__c> kybDocs = [SELECT id, Statut__r.key__c, Type_de_document__c, Compte_Pro__c, compte_Pro__r.statut_juridique__c
                                     FROM Document__c WHERE Compte_Pro__c IN:accSet AND Type_de_document__c IN:kybs];
        for(Document__c doc : kybDocs) {
            if(doc.Statut__r.Key__c=='VALIDATED') {
                if(doc.Type_de_document__c=='kbis') {
                    kbisOk.add(doc.Compte_Pro__c);
                }
                if(doc.Type_de_document__c=='rib') {
                    ribOk.add(doc.Compte_Pro__c);
                }
                if(doc.Type_de_document__c=='id') {
                    idOk.add(doc.Compte_Pro__c);
                } 
                if(doc.Type_de_document__c=='company_status') {
                    statusOk.add(doc.Compte_Pro__c);
                }
            } else if(doc.Statut__r.Key__c=='VALIDABLE') {
                if(doc.Type_de_document__c=='kbis') {
                    kbisWaiting.add(doc.Compte_Pro__c);
                }
                if(doc.Type_de_document__c=='rib') {
                    ribWaiting.add(doc.Compte_Pro__c);
                }
                if(doc.Type_de_document__c=='id') {
                    idWaiting.add(doc.Compte_Pro__c);
                } 
                if(doc.Type_de_document__c=='company_status') {
                    statusWaiting.add(doc.Compte_Pro__c);
                }
            }
            if(refId.contains(doc.compte_Pro__r.statut_juridique__c)) {
                statusOk.add(doc.Compte_Pro__c);
            }
        }
        List<Account> accUpdate = new List<Account>();
        for(id acc : accSet) {
            accUpdate.add(new Account( id=acc, 
                                       kbis_status__c = kbisOk.contains(acc) ? 'VALIDATED' : (kbisWaiting.contains(acc) ? 'VALIDABLE' : 'INVALID'),
                                       id_status__c = idOk.contains(acc) ? 'VALIDATED' : (idWaiting.contains(acc) ? 'VALIDABLE' : 'INVALID'), 
                                       rib_status__c = ribOk.contains(acc) ? 'VALIDATED' : (ribWaiting.contains(acc) ? 'VALIDABLE' : 'INVALID'), 
                                       statut_status__c = statusOk.contains(acc) ? 'VALIDATED' : (statusWaiting.contains(acc) ? 'VALIDABLE' : 'INVALID')));
        }
        Database.update(accUpdate, false);
    }
}