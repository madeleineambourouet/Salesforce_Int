/*
* DocumentMethodsTest : test methods for ContactMethods class
* Created by   : Hassan
* Created Date : 26 Dec 2019
*/

@isTest
private without sharing class HerokuConnectTest {
    
    /**
    * @author Hassan Dakhcha
    * @date 26/12/2019
    * @description test qui simule l'insertion d'un contact sans compteId par HerokuConnect
    *  (pour plus de details cf : https://confluence.pointp.saint-gobain.net/display/HYB/Synchronisation+PP+%3C--%3E+Replicapp%3C--%3E+Salesforce ) 
    **/         
    @isTest static void testInsertContactHerokuConnect() {
        // HK Connect User 
        Profile sysAdm = TestFactory.getProfilByName('Administrateur système');
        User HKConnectUser = new User(Alias = 'HKC', Email='HKConnectTest@testorg.com', 
                                      EmailEncodingKey='UTF-8', LastName='Place', FirstName ='Connect' ,languageLocaleKey='en_US', 
                                      LocaleSidKey='en_US', ProfileId = sysAdm.Id, Bypass_Function__c='',
                                      TimeZoneSidKey='America/Los_Angeles', UserName='HKConnectTest@testorg.com');
        insert HKConnectuser;
        
        List<Reference__c> listReferences = new List<Reference__c>();
        Reference__c pays = TestFactory.createReference('pays', 'France','FRA','France');
        Reference__c CP = TestFactory.createReference('CP', '75017','75017','Paris');
        Reference__c NAF = TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA');
        Reference__c enseigne = TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS');
        listReferences.add(CP);
        listReferences.add(NAF);
        listReferences.add(enseigne);
        listReferences.add(pays);
        insert listReferences;
        
        // Account : 
        Account comptePro = TestFactory.createAccount(true, pays, CP, enseigne, NAF);
        comptePro.Compte_Nouvelles_Offres__c = true;
        comptePro.compte_standalone__c = true;
        comptePro.Statut_activation__c = 'Nouveau';
        comptePro.Login__c = 'HKConnectEmail@testorg.com';
        System.debug('testInsertContactHerokuConnect Compte pro before insert  = ' + comptePro);

        // Contact : 
        Contact newContact = new Contact(Salutation = 'M.', FirstName = 'Test', LastName = 'Test', Contact_Principal_O_N__c = true,
                                         Contact_de_facturation__c = true, DoNotCall = true, Phone = '+33635136116',
                                         Email__c = 'HKConnectEmail@testorg.com');
        System.debug('testInsertContactHerokuConnect contact before insert  = ' + newcontact);
        
        // Document :
        Document__c newDoc = new Document__c(Email_cle_document__c = 'HKConnectEmail@testorg.com_Assurance');
        System.debug('testInsertContactHerokuConnect Document before insert  = ' + newDoc);
        
        // Prestation contact :
        reference__c prestationId = TestFactory.createReference('Prestation', 'Isolation du sol', '067', 'Isolation du sol');
        insert prestationId;
        Prestation_Contact__c newPresCt = new Prestation_Contact__c(Email_cle_prestation__c ='HKConnectEmail@testorg.com' + '_' + prestationId.Key__c, Prestation__c = prestationId.id);   
        System.debug('testInsertContactHerokuConnect Prestation contact before insert  = ' + newPresCt);
        
        // Departement
        reference__c departementId = TestFactory.createReference('Departement', '75', '75', '75' );
        insert departementId;
        Departement__c newDep = new Departement__c(Email_cle_departement__c='HKConnectEmail@testorg.com'+ '_' + departementId.Key__c, Departement__c=departementId.id);
        System.debug('testInsertContactHerokuConnect departement before insert  = ' + newDep);
        
        Reference__c metierRef = TestFactory.createReference('Metier', 'Plombier', 'Plombier', 'Plombier');
        insert metierRef;
        Metier__c newMetier = new Metier__c(Email_cle_metier__c = 'HKConnectEmail@testorg.com' + '_' + metierRef.Key__c, metier__c = metierRef.id);
        System.debug('testInsertContactHerokuConnect metier before insert  = ' + NewMetier);

        System.runAs(HKConnectuser) {
            test.startTest();
            
            insert comptePro;
            System.debug('Inserted account = ' + comptePro );
            Account debug = [SELECT id, Pays_LKP__c FROM Account Where id = :comptePro.id];
            System.debug('Inserted account = ' + debug );

            insert newContact;
            insert newDoc;        
            insert newPresCt;
            insert newDep;
            insert newMetier;
        }    
            Account acc = [SELECT id, Login__c FROM Account WHERE Login__c = 'HKConnectEmail@testorg.com'];
            Contact ct  = [SELECT id, AccountId, Email__c, email FROM Contact WHERE Email__c = 'HKConnectEmail@testorg.com'];
            Document__c doc = [SELECT id, Email_cle_document__c, Compte_Pro__c FROM Document__c WHERE Email_cle_document__c LIKE 'HKConnectEmail@testorg.com%'];
            Prestation_Contact__c presCt = [SELECT id, Email_cle_prestation__c, Contact__c FROM Prestation_Contact__c WHERE Email_cle_prestation__c LIKE 'HKConnectEmail@testorg.com%'];
            Departement__c dep = [SELECT id, Email_cle_departement__c, Departement__c, Contact__c FROM Departement__c WHERE Email_cle_departement__c LIKE 'HKConnectEmail@testorg.com%'];
            Metier__c metier = [SELECT id, Contact__c FROM Metier__c];
            System.debug('testInsertContactHerokuConnect RESULTS : Acc = ' + acc.id + ' Ct = ' + ct.Id + ' Contact Acc = ' + ct.AccountId
                         + /*' Document Acc = ' + doc.Compte_Pro__c + */' PrestContact Ct = ' + presCt.Contact__c + ' Deprtement Ct = '  + dep.Contact__c);
            
            System.assertEquals(acc.id, ct.AccountId, 'testInsertContactHerokuConnect  : Le contact n\'a pas été ataché au bon compte' );
            System.assertEquals(acc.id, doc.Compte_Pro__c, 'testInsertContactHerokuConnect  : Le document n\'a pas été ataché au bon compte' );
            System.assertEquals(ct.id, presCt.Contact__c, 'testInsertContactHerokuConnect  : La prestation contact n\'a pas été ataché au bon contact' );
            System.assertEquals(ct.id, dep.Contact__c, 'testInsertContactHerokuConnect  : Le departement n\'a pas été ataché au bon contact' );
            System.assertEquals(ct.id, metier.Contact__c, 'testInsertContactHerokuConnect  : Le meteier n\'a pas été ataché au bon contact' );

            comptePro.compte_standalone__c = false;
            update comptePro;

            comptePro.Contact_principal__c = newContact.Id;
            comptePro.compte_standalone__c = true;
            comptePro.Nat_To_Sync__c = true;
            update comptePro;
            
            test.stopTest();     
       
    }
}