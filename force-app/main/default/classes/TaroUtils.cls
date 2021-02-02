/**
* @author Clement Musabimana
* @date 20/02/2020
* @description Class permettant de gérer les traitements liés à TARO
**/
public class TaroUtils {
    //Détail
    public class TaroChiffrageDetail {
        @AuraEnabled
        public PackageInfo package_info;
        @AuraEnabled
        public Total total;
        @AuraEnabled
        public PostalCode postalCode;
        @AuraEnabled
        public Summary summary;
        //EXTRA CUSTOM FIELD not in the JSON
        @AuraEnabled
        public String periodeTravaux;
        @AuraEnabled
        public String besoinsTravaux;
        @AuraEnabled
        public List<Grant> grants;
        @AuraEnabled
        public String totalGrants;
    }

    //Creation/Modification
    public class TaroChiffrage {
        public PackageInfo package_info;
        public Total total;
        public PostalCode postalCode;
        public List<Prestation> prestations;
    }

    public class PackageInfo {
        @AuraEnabled
        public String BSKU;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String id;
    }  
    public class Total {
        @AuraEnabled
        public String minimum;
        @AuraEnabled
        public String maximum;
    } 
    public class Prestation {
        public String id_prestation;
        public String name;
        public Total total;
    }
    public class PostalCode {
        @AuraEnabled
        public String postalCode;
        @AuraEnabled
        public String inseeCode;
        @AuraEnabled
        public String name;
    }
    //Détail
    public class Summary {
        @AuraEnabled
        public List<Section> sections;
    }
    public class Section {
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public List<Item> items;
        @AuraEnabled
        public List<Categorie> categories;
    }
    public class Item {
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }
    public class Categorie {
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public List<Item> items;
    }
    /*public class Grants {
        @AuraEnabled
        public List<Grant> grants;
    }*/
    public class Grant {
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String amount;
    }

    public static String getParametersFromJson(String jsonInput){
        String jsonParameters = '';
        if(jsonInput != null && jsonInput != ''){
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
            jsonParameters = JSON.serialize(jsonMap.get('parameters'));
        }
        return jsonParameters;
    }
    
    public static TaroChiffrage getChiffrageFromJson(String jsonInput){        
        TaroChiffrage taroChiffrage = null;
        if(jsonInput != null && jsonInput != ''){
            taroChiffrage = (TaroChiffrage)JSON.deserialize(jsonInput,TaroChiffrage.class);
        }  
        System.debug('taroChiffrage '+ taroChiffrage);
        return taroChiffrage;
    }
        
    public static Projet_LMSG__c getDataNewProjetLMSGFromChiffrage(TaroChiffrage taroChiffrage, String jsonInput, String particulierId){       
        System.debug('getDataNewProjetLMSGFromChiffrage '+ taroChiffrage);
        Projet_LMSG__c projetLmsg = null;
        if(taroChiffrage != null){
            projetLmsg = new Projet_LMSG__c();
            projetLmsg.Statut__c = Label.PP_Projet_statut_par_defaut;
            System.debug('getDataNewProjetLMSGFromChiffrage.package_info.BSKU '+ taroChiffrage.package_info.BSKU);
            //projetLmsg.Chiffrage_Besoin_Travaux__c = taroChiffrage.package_info.name;
            System.debug('getDataNewProjetLMSGFromChiffrage.total.minimum '+ taroChiffrage.total.minimum);
            System.debug('getDataNewProjetLMSGFromChiffrage.total.maximum '+ taroChiffrage.total.maximum);
            projetLmsg.Particulier__c = particulierId;
            projetLmsg.Chiffrage_json__c = jsonInput;
        }
        return projetLmsg;
    }
    
    public static List<Prestation_Projet__c> getPrestationsFromChiffrage(TaroChiffrage taroChiffrage,String IdProjetLMSG){
        List<Prestation_Projet__c> prestationsProjet = new List<Prestation_Projet__c>();
        List<String> prestationsPSKU = new List<String>();
        Map<String, Reference__c> prestationSkuKey = new Map<String, Reference__c>();
        String jsonPrestations = '';
        
        System.debug('getPrestationsFromChiffrage '+ taroChiffrage);
        if(taroChiffrage != null){
            System.debug('getPrestationsFromChiffrage.package_info.BSKU '+ taroChiffrage.package_info.BSKU);
            System.debug('getPrestationsFromChiffrage.total.minimum '+ taroChiffrage.total.minimum);
            System.debug('getPrestationsFromChiffrage.total.maximum '+ taroChiffrage.total.maximum);
            //Recupération de la liste des PSKU
            for(Prestation prestation :taroChiffrage.prestations){
                prestationsPSKU.add(prestation.id_prestation);
            }
            for(Reference__c ref :[SELECT Id, Name, key__c,SKU__c from Reference__c where SKU__c IN:prestationsPSKU]){
                prestationSkuKey.put(ref.SKU__c,ref);
            }
            for(Prestation prestation :taroChiffrage.prestations){
                if(prestationSkuKey.get(prestation.id_prestation) != null) {
                    Prestation_Projet__c prestationProjet = new Prestation_Projet__c();
                    prestationProjet.Name = 'PRESTA ' + prestationSkuKey.get(prestation.id_prestation).Name;
                    prestationProjet.Projet_LMSG__c = IdProjetLMSG;
                    prestationProjet.Minimum__c = Decimal.valueOf(prestation.total.minimum);
                    prestationProjet.Maximum__c = Decimal.valueOf(prestation.total.maximum);
                    prestationProjet.Prestation__c = prestationSkuKey.get(prestation.id_prestation).id;
                    prestationProjet.PSKU__c = prestation.id_prestation;
                    prestationsProjet.add(prestationProjet);
                    System.debug('getPrestationsFromChiffrage prestation.id_prestation '+ prestation.id_prestation);
                    System.debug('getPrestationsFromChiffrage prestation.name '+ prestation.name);
                    System.debug('getPrestationsFromChiffrage prestation.total.minimum '+ prestation.total.minimum);
                    System.debug('getPrestationsFromChiffrage prestation.total.maximum '+ prestation.total.maximum);
                }
            }   
        }
        return prestationsProjet;
    }
    
    public static List<Prestation_Projet__c> getPrestationsFromProjetLMSG(String IdProjetLMSG){
        List<Prestation_Projet__c> prestationsProjet = new List<Prestation_Projet__c>();
        System.debug('getPrestationsFromProjetLMSG IdProjetLMSG '+ IdProjetLMSG);
        if(IdProjetLMSG != null && IdProjetLMSG != ''){
            prestationsProjet.addAll([SELECT Id from Prestation_Projet__c where Projet_LMSG__c =:IdProjetLMSG]);
        }
        return prestationsProjet;
    }
    
    @AuraEnabled
    public static TaroChiffrageDetail callChiffrageDetail (String projetLmsgId) {
        TaroChiffrageDetail taroChiffrageDetail = new TaroChiffrageDetail();
        TaroChiffrageDetail taroChiffrageDetailReturn = new TaroChiffrageDetail();
        List<String> listResult = new List<String>();
        String bsku = '';
        String taroJson = '';
        String message = '';
        String periodeTravaux = '';
        String besoinsTravaux = '';
        System.debug('callChiffrageDetail projetLmsgId '+projetLmsgId);
        for(Projet_LMSG__c projetLmsg :[select Chiffrage_bsku__c,Besoin_Travaux__r.Name,Chiffrage_json__c,Delai_souhaite_avant_debut_travaux__c from Projet_LMSG__c where id =:projetLmsgId limit 1]){
            bsku = projetLmsg.Chiffrage_bsku__c;
            taroJson = projetLmsg.Chiffrage_json__c;
            periodeTravaux = projetLmsg.Delai_souhaite_avant_debut_travaux__c;
            besoinsTravaux = projetLmsg.Besoin_Travaux__r.Name;
        }
        if(taroJson != null && taroJson != ''){
            taroChiffrageDetail = (TaroChiffrageDetail)JSON.deserialize(taroJson,TaroChiffrageDetail.class);
        }  
        if(taroChiffrageDetail != null){
            taroChiffrageDetailReturn = getSelectedItemsFromChiffrage(taroChiffrageDetail);
            taroChiffrageDetailReturn.periodeTravaux = periodeTravaux;
            taroChiffrageDetailReturn.besoinsTravaux = besoinsTravaux;
        }
        System.debug('taroChiffrageDetailReturn '+ taroChiffrageDetailReturn);
        return taroChiffrageDetailReturn;
    }

    /**
    * @author Clement Musabimana
    * @date 04/03/2020
    * @description Class permettant de récupérer dans le résumé taro uniquement les parties séléectionnés par le particulier
    **/
    public static TaroChiffrageDetail getSelectedItemsFromChiffrage (TaroChiffrageDetail taroChiffrageDetail) {
        TaroChiffrageDetail taroChiffrageDetailReturn = new TaroChiffrageDetail();
        taroChiffrageDetailReturn.package_info = taroChiffrageDetail.package_info;
        taroChiffrageDetailReturn.total = taroChiffrageDetail.total;
        taroChiffrageDetailReturn.postalCode = taroChiffrageDetail.postalCode;
        taroChiffrageDetailReturn.summary = new Summary();
        List<Section> sections = new List<Section>();
        taroChiffrageDetailReturn.summary.sections = sections;

        String labelListeChiffrageDetailExlusionValeurs = Label.ChiffrageDetailExlusionValeurs;
        Set<string> listeChiffrageDetailExlusionValeurs = new Set<string>();
        listeChiffrageDetailExlusionValeurs.addAll(labelListeChiffrageDetailExlusionValeurs.split(';'));
        System.debug('listeChiffrageDetailExlusionValeurs ='+listeChiffrageDetailExlusionValeurs); 

        for(Section taroChiffrageDetailSection: taroChiffrageDetail.summary.sections){
            boolean isSectionSelected = false;
            Section section = new Section();
            section.code = taroChiffrageDetailSection.code;
            section.label = taroChiffrageDetailSection.label;
            section.items = new List<Item>();
            section.categories = new List<Categorie>();

            if(taroChiffrageDetailSection.items != null)
            for(Item taroChiffrageDetailSectionItem: taroChiffrageDetailSection.items){
                if(!listeChiffrageDetailExlusionValeurs.contains(taroChiffrageDetailSectionItem.value)){
                    Item item = new Item();
                    item.code = taroChiffrageDetailSectionItem.code;
                    item.label = taroChiffrageDetailSectionItem.label;
                    item.value = taroChiffrageDetailSectionItem.value;
                    section.items.add(item);
                    isSectionSelected = true;
                }
            }
            if(taroChiffrageDetailSection.categories != null)
            for(Categorie taroChiffrageDetailSectionCategorie: taroChiffrageDetailSection.categories){
                boolean isSectionCategorieSelected = false;
                Categorie categorie = new Categorie();
                categorie.code = taroChiffrageDetailSectionCategorie.code;
                categorie.label = taroChiffrageDetailSectionCategorie.label;
                categorie.items = new List<Item>();
                for(Item taroChiffrageDetailSectionItem: taroChiffrageDetailSectionCategorie.items){
                    if(!listeChiffrageDetailExlusionValeurs.contains(taroChiffrageDetailSectionItem.value)){
                        Item item = new Item();
                        item.code = taroChiffrageDetailSectionItem.code;
                        item.label = taroChiffrageDetailSectionItem.label;
                        item.value = taroChiffrageDetailSectionItem.value;
                        categorie.items.add(item);
                        isSectionSelected = true;
                        isSectionCategorieSelected = true;
                    }
                }
                if(isSectionCategorieSelected == true){
                    section.categories.add(categorie);
                }
            }
            if(isSectionSelected == true){
                taroChiffrageDetailReturn.summary.sections.add(section);
            }
        }
        
        // rge grants :
        if(taroChiffrageDetail.grants!=null && !taroChiffrageDetail.grants.isEmpty()) {
            taroChiffrageDetailReturn.grants = taroChiffrageDetail.grants;
            Decimal amount = 0;
            for(Grant grant : taroChiffrageDetail.grants) {
                amount += Decimal.valueOf(grant.amount);
            }
            taroChiffrageDetailReturn.totalGrants = String.valueOf(amount);
        }

        return taroChiffrageDetailReturn;
    }
}