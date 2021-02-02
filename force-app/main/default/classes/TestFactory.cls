/** 
** Classe outils spécifique au projet
** ---------------------------------------------------
** Description:
**    Classe contenant des fonctions outils spécifique pour écrire les tests
** Version(s):
**    - 1.0 : 21/04/2016 - PCA
**/
@isTest
public with sharing class TestFactory 
{
    
    public static final ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
    public static final ID RTComptePart = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Particulier' LIMIT 1].Id; 
    
    public static final ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
    public static final ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
    public static final ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
    public static final ID RTEnseigne = [SELECT Id FROM RecordType WHERE DeveloperName = 'Enseigne' LIMIT 1].Id;
    public static final ID RTCompetence = [SELECT Id FROM RecordType WHERE DeveloperName = 'Competence' LIMIT 1].Id;
    public static final ID RTCategorie = [SELECT Id FROM RecordType WHERE DeveloperName = 'Categorie' LIMIT 1].Id;
    public static final ID RTRejectMatch = [SELECT Id FROM RecordType WHERE DeveloperName = 'Matching_rejet' LIMIT 1].Id;
    public static final ID RTAgence = [SELECT Id FROM RecordType WHERE DeveloperName = 'Agence' LIMIT 1].Id;
    public static final ID RTMotif = [SELECT Id FROM RecordType WHERE DeveloperName = 'Motif' LIMIT 1].Id;
    public static final ID RTPrestation = [SELECT Id FROM RecordType WHERE DeveloperName = 'Prestation' LIMIT 1].Id;
    public static final ID RTDepartement = [SELECT Id FROM RecordType WHERE DeveloperName = 'Departement' LIMIT 1].Id;
    public static final ID RTStatutDocument = [SELECT Id FROM RecordType WHERE DeveloperName = 'Statut_Document' LIMIT 1].Id;
    public static final ID RTMetier = [SELECT Id FROM RecordType WHERE DeveloperName = 'Metier' LIMIT 1].Id;
    
    public static Account createAccount(Boolean isPro, Reference__c pays, Reference__c codePostal, Reference__c enseigne, Reference__c NAF){
        
        Account compte = new Account();
        if (isPro) {
            compte.RecordTypeId = RTComptePro;
            compte.Name = 'Test account';
            compte.Phone = '+33635136116';
            compte.Liste_des_enseignes_de_gestion_o_il_est__c = enseigne.Name;
            compte.Flux_code_Enseigne__c = enseigne.key__c;
            compte.SIRET_texte__c = '32212091600208';
            compte.Code_NAF_APE_societe_declarante__c = NAF.id;
            compte.A_ne_jamais_rappeler__c = false;
        }
        else {
            compte.RecordTypeId = RTComptePart;
            compte.LastName = 'Test';
            compte.FirstName = 'Test';
            compte.Salutation = 'M.';
            compte.PersonMobilePhone = '+33635136116';
        }
        compte.Pays_LKP__c = pays.id;
        compte.Code_postal__c = codePostal.id;
        
        return compte;
        
    }
    
    public static Lead createLead(Reference__c NAF) {
        
        return new Lead(Salutation = 'M.', FirstName = 'Test', LastName = 'Test', SIRET__c = '32212091600208', Company = 'B&D', Status = 'Ouverte', Code_NAF__c = NAF.id);
        
    }
    
    public static Reference__c createReference(String referenceType, String nom, String key, String libelle){
        
        Reference__c reference = new Reference__c();
        if (referenceType == 'pays') {
            reference.RecordTypeId = RTPays;
        }
        if (referenceType == 'NAF') {
            reference.RecordTypeId = RTNAF;
        }
        if (referenceType == 'CP') {
            reference.RecordTypeId = RTCodePostal;
            reference.Active_PP__c = true;
        }
        if (referenceType == 'enseigne') {
            reference.RecordTypeId = RTEnseigne;
        }
        if (referenceType == 'competence'){
            reference.RecordTypeId = RTCompetence;
        }
        if (referenceType == 'categorie'){
            reference.RecordTypeId = RTCategorie;
        }
        if (referenceType == 'Matching_rejet'){
            reference.RecordTypeId = RTRejectMatch;
        } 
        
        if (referenceType == 'Agence'){
            reference.RecordTypeId = RTAgence;
        }  
        
        if (referenceType == 'Motif'){
            reference.RecordTypeId = RTMotif;
        } 
        
        if (referenceType == 'Prestation') {
            reference.RecordTypeId = RTPrestation;            
        }
        
        if (referenceType == 'Departement') {
            reference.RecordTypeId = RTDepartement;            
        }
        
        if (referenceType == 'StatutDocument') {
            reference.RecordTypeId = RTStatutDocument;
        }

        if (referenceType == 'Metier') {
            reference.RecordTypeId = RTMetier;
        }

        reference.Name = nom;
        reference.key__c = key;
        reference.Libelle__c = libelle;
        reference.Libelle_2__c = libelle;
        reference.Libelle_3__c = libelle;
        
        return reference;
        
    }
    
    public static Projet__c createProject(Account particulier, Reference__c codePostal, Reference__c pays, User us){
        
        return new Projet__c(Particulier__c = particulier.id, Sous_Activite__c = 'Isolation', Code_postal__c = codePostal.id, Pays_LKP__c = pays.id, Description__c = 'test',
                             Numero_SGI__c = us.FederationIdentifier);
        
    }
    
    /*  public static User createUser(String SGI){

User us;
List<User> lUser = [SELECT id, FederationIdentifier FROM User WHERE FederationIdentifier = :SGI];

if (lUser.size() > 0) { us = lUser[0]; }
else { us = new User(FederationIdentifier = SGI); insert us; }

return us;

}*/
    
    public static Intermediation__c createMiseEnRelation(Contact contactPro, Reference__c competence, Projet__c projet){
        
        return new Intermediation__c(Contact__c = contactPro.id, Competence__c = competence.id, ID_COMPETENCE__c = competence.id, Prospect__c = false, Projet__c = projet.id, Date_de_matching__c = Date.today());
        
    }
    
    public static Contact createContact(Account compte){
        
        return new Contact(Salutation = 'M.', FirstName = 'Test', LastName = 'Test', Contact_Principal_O_N__c = true, Contact_de_facturation__c = true, AccountId = compte.id, DoNotCall = true, Phone = '+33635136116');
        
    }
    
    public static GeoCat__c createGeoCat(Contact ctc, Reference__c codePostal){
        
        return new GeoCat__c(Contact__c = ctc.id, Adresse__c = codePostal.id,Zone_d_intervention__c=1,FaminePoids__c=10);
        
    }
    
    public static  Profile  getProfilByName(String nameProfilFR) {
        String nameProfilEN = '';
        if (nameProfilFR == 'Administrateur système') nameProfilEN = 'System administrator';  
        List<Profile> profil = [SELECT Id FROM Profile WHERE Name=:nameProfilFR OR Name=:nameProfilEN limit 1];
        
        System.assert(profil.size() >= 1, nameProfilFR + ' wasnt found.');
        
        
        
        return profil[0];
        
    } 
    
    
    public static  User  createUser(String SGI, Profile profil)
    {
        User us;
        List<User> users = [select Id, FederationIdentifier from User where FederationIdentifier = :SGI];
        if (users.size() == 0)
        {
            us = new User();
            System.assert(us != null, 'Fatal error: Cannot create User. Nullpointerexception.');
            
            us.Alias = 'user';
            us.Email='usersgdbf@testclasssgdbf.com';
            us.EmailEncodingKey='UTF-8';
            us.LastName='Test';
            us.LanguageLocaleKey='fr';
            us.LocaleSidKey='fr_FR_EURO';
            us.ProfileId = profil.Id;
            us.TimeZoneSidKey='Europe/Paris';
            us.UserName='usersgdbf@testclasssgdbf.com';
            insert us;
        }
        else { us = users[0]; }
        return us;
    }
    
    public static Technical_Values__c createCustomSettings(String codeClientStart){
        
        return new Technical_Values__c(Name = 'Technical values', Code_client__c = codeClientStart); 
        
    }
    
    public static void BypassCSRules() {
        TurnOffValidationRule__c setting = TurnOffValidationRule__c.getOrgDefaults();
        if (setting.TurnOff__c == false) {
            setting.TurnOff__c = true;
            update setting;
        }
    }  
    
    public static Case createRequete(Account pro, String status, Id idMotif){
        
        return new Case(Account = pro, Status = status, Motif__c = idMotif);
        
    }
    
    public static List<String> getListDocTypesFromReference() {
        List<String> listDocTypes = new List<String> ();
        Schema.DescribeFieldResult fieldResult = reference__c.Document_obligatoire__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPickListValues();
        for(Schema.PickListEntry entry : ple)
            listDocTypes.add(entry.getValue());
        
        return listDocTypes;
    }
    
    public static reference__c createAndAddMandatoryDocTypeToPresta(String Name, String Key, String SKU, integer NbDocType, List<String> listDocTypes) { 
        reference__c presta = TestFactory.createReference('Prestation', Name,  Key, Name);
        presta.Document_obligatoire__c = '';
        for(integer i=0; i<listDocTypes.size() && i<NbDocType; ++i) {
            if(i>0)
                presta.Document_obligatoire__c+= ';';
            presta.Document_obligatoire__c += listDocTypes[i];
        }
        presta.SKU__c = SKU;
        return presta;
    }
    
    
}