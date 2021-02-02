/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 12-08-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   10-24-2020   Hassan Dakhcha   Initial Version
**/
@isTest
public with sharing class Relance_RDV_Test {
  
    @isTest
    static void Relance_RDV_Supplier_Test() {
        // Query Locator filter :    
        // MER WHERE Projet_LMSG__c != null AND Date_Heure_rendez_vous__c = null AND Statut__c =\'Pro_selectionne\' ' +
        //           ' AND Compte_Pro__r.Statut_activation__c =\'Pro_actif_positionnable\' ' +
        //           ' AND Projet_LMSG__r.Statut__c=\'PUBLISHED\' ' + 
        //           ' AND (statut_RDV__c =null OR statut_RDV__c =\'En_attente\' ) ' +
        //             and Date_selection__c < LAST_N_DAYS:3 
        //           ' order by Date_selection__c desc '
        //
        //
        Test.startTest();
        createMers();
        Database.executebatch(new Relance_RDV_Supplier());
        Test.stopTest();

        // Check the table :
        List<Relance_RDV_MER__c> relanceList = [SELECT id, Projet_LMSG__c , Projet_LMSG__r.Chiffrage_maximum__c, Particulier__c, SMS_PrenomPart__c,
                                                 SMS_PrenomCA__c, SMS_PartPhone__c, MER1__c, MER2__c , MER3__c
                                                , part_sms_sent__c, part_sms_body__c FROM Relance_RDV_MER__c];
        System.assertEquals(4, relanceList.size());
        for(Relance_RDV_MER__c rel : relanceList) {
            System.assertNotEquals('+33102030444', rel.SMS_PartPhone__c);
            if(rel.SMS_PartPhone__c == '+33102030455' || rel.SMS_PartPhone__c == '+33102030488') {
                System.assertEquals(null, rel.MER3__c);
            }
            System.debug('***** : ' + rel);
            // check the sms send :
            System.assertEquals(false, rel.part_sms_sent__c, 'SMS SENT by the test verify the flow : Relance SMS RDV Part ' );
            System.assertEquals('SKIPED BY FLAG', rel.part_sms_body__c);
        }

        // Check the created messaging Sessions :
        List<MessagingSession> msList = [SELECT id, origin, type__c, Account__c, EnduserContactId, EndUserAccountId, Projet_HY__c, Projet_LMSG__c FROM MessagingSession ];
        //System.assertNotEquals(true, msList.isEmpty());
        for(MessagingSession ms : msList) {
            System.assertEquals('rdv_part', ms.type__c);
            System.assertEquals('TriggeredOutbound', ms.origin);
            System.assertEquals(null, ms.Projet_HY__c);
            System.assertNotEquals(null, ms.Projet_LMSG__c);
        }
    }

    @isTest
    static void Relance_RDV_Consumer_Test() {
        
        // WHERE createdDate < LAST_N_DAYS:1 AND part_sms_sent__c = true AND pro_sms_sent__c = false
        Test.startTest();
        createMers();
        String queryMers = 'SELECT id, Projet_LMSG__c, Projet_LMSG__r.Owner.firstName, ' +
                           'Compte_Pro__c, Projet_LMSG__r.Particulier__r.FirstName, ' +
                           'Projet_LMSG__r.Particulier__c, Projet_LMSG__r.Telephone_Mobile__c, ' +
                           'Statut__c, statut_RDV__c, Date_Heure_rendez_vous__c, Date_modification_statut_RDV__c, ' +  
                           'Date_selection__c, Date_modification_statut__c, Compte_Pro__r.Statut_activation__c, ' +
                           'Compte_Pro__r.name  FROM Mise_en_relation__c ' + 
                           Label.Query_Batch_Relance_RDV_SMS_Part_Supplier;
        
        List<SObject> merList = Database.query(queryMers);
        List<Relance_RDV_MER__c> relanceList = Relance_RDV_Supplier.getRelanceRDVRecords(merList);

        System.assertEquals(4, relanceList.size());
        insert(relanceList); 
        relanceList.clear();

        relanceList = [SELECT id, createdDate, part_sms_sent__c, part_sms_sent_time__c FROM Relance_RDV_MER__c];
        for(Relance_RDV_MER__c rel : relanceList) {
            rel.part_sms_sent_time__c =  system.today()-2;
            rel.part_sms_sent__c = true;
            System.debug('******* relance = ' + rel);
        }
        update relanceList;
        
        // Consume from the inserted Table
        Database.executeBatch(new Relance_RDV_Consumer());

        Test.stopTest();

        List<Relance_Pro_RDV_MER__c> created_relancePro = [ SELECT id,Projet_LMSG__c,Compte_Pro__c, Mise_en_relation_LMSG__c, pro_sms_sent_time__c,
                                                            pro_sms_body__c, SMS_Pro_Sent__c FROM Relance_Pro_RDV_MER__c ];

        System.assertEquals(10, created_relancePro.size());
        for(Relance_Pro_RDV_MER__c rel : created_relancePro) {
            System.debug('******* relance = ' + rel);
            System.assertEquals('SKIPED BY FLAG', rel.pro_sms_body__c);
            System.assertEquals(false, rel.SMS_Pro_Sent__c);
        }
    }

    @isTest
    static void Relance_RDV_Call_Consumer_Test() {
        Test.startTest();
        createMers();
        String queryMers = 'SELECT id, Projet_LMSG__c, Projet_LMSG__r.Owner.firstName, ' +
                           'Compte_Pro__c, Projet_LMSG__r.Particulier__r.FirstName, ' +
                           'Projet_LMSG__r.Particulier__c, Projet_LMSG__r.Telephone_Mobile__c, ' +
                           'Statut__c, statut_RDV__c, Date_Heure_rendez_vous__c, Date_modification_statut_RDV__c, ' +  
                           'Date_selection__c, Date_modification_statut__c, Compte_Pro__r.Statut_activation__c, ' +
                           'Compte_Pro__r.name  FROM Mise_en_relation__c ' + 
                           Label.Query_Batch_Relance_RDV_SMS_Part_Supplier;
        
        List<SObject> merList = Database.query(queryMers);
        List<Relance_RDV_MER__c> relanceList = Relance_RDV_Supplier.getRelanceRDVRecords(merList);

        System.assertEquals(4, relanceList.size());
        insert relanceList; 

        for(Relance_RDV_MER__c rel : relanceList) {
            rel.part_sms_sent_time__c =  system.today()-2;
            rel.part_sms_sent__c = true;
        }
        update relanceList;

        List<MessagingEndUser> MSUList = [SELECT id, AccountId FROM MessagingEndUser];
        Map<id, id> MSUMap = new Map<id, id>();
        for(MessagingEndUser mu : MSUList) {
            MSUMap.put(mu.AccountId, mu.id);
        }
        Id messagingChannel = [SELECT id FROM MessagingChannel WHERE DeveloperName=:Label.Messaging_Channel_API_Name].id;

        List<MessagingSession> msList = [select id, MessagingChannelId, ChannelEndUserFormula,  Origin,  Account__c,Project_Owner__r.name, Zone__c,type__c, Projet_HY__c,
                                         Projet_LMSG__c,Date_retour_client__c, Delai_de_reponse_client__c, Delai_de_prise_en_charge_CRC__c, MessagingEndUserId,
                                         MessagingChannel.MasterLabel,MessagingEndUser.Name,  EndUserContactId, EndUserAccountId, MessagingEndUser.AccountId,
                                         MessagingEndUser.ContactId,Status,MessagingEndUser.id,  EndUserAccount.IsPersonAccount , CreatedDate
                                         FROM MessagingSession ORDER BY CreatedDate DESC];
        for(MessagingSession ms : msList) {
            System.debug('**** MS Test = '+ ms.Origin + ' ' + ms.MessagingChannelId + '  ' + ms.MessagingEndUserId + ' '
                        + ms.Account__c + '  ' + ms.Project_Owner__r.name + '  ' + ms.Zone__c + '  ' + ms.type__c + '  ' 
                        + ms.Projet_HY__c + '  ' + ms.Projet_LMSG__c + '  ' + ms.Date_retour_client__c + '  ' + ms.Delai_de_reponse_client__c + '  ' 
                        + ms.Delai_de_prise_en_charge_CRC__c);
        }
       //delete msList;
        Map<String, MessagingSession> newMsList = new Map<String, MessagingSession> ();                         
        // simuler la reponse du Part :
        Id part = relanceList[3].particulier__c;
        MessagingSession ms = new MessagingSession( MessagingEndUserId = MSUMap.get(part), Origin='InboundInitiated',
                                                    MessagingChannelId = messagingChannel, Status = 'Ended', type__c = null,
                                                    Account__c = null, Projet_HY__c=null, Projet_LMSG__c=null);
        msList.clear();
        msList.add(ms);
        MessagingSessionMethods.updateMSInboundType(msList);
        MessagingSessionMethods.updateRelationship(msList);
        System.debug('****** MS Inbound = ' + ms);
        //insert ms;

        String queryStr =  ' SELECT id, Projet_LMSG__c, MER1__c, MER2__c, MER3__c, ' +
                            ' MER1__r.Compte_Pro__c, MER2__r.Compte_Pro__c, MER3__r.Compte_Pro__c, ' +
                            ' MER1__r.Date_selection__c, MER2__r.Date_selection__c, MER3__r.Date_selection__c, ' + 
                            ' MER1__r.Date_Heure_rendez_vous__c, MER2__r.Date_Heure_rendez_vous__c, MER3__r.Date_Heure_rendez_vous__c, ' +
                            ' MER1__r.statut_RDV__c, MER2__r.statut_RDV__c, MER3__r.statut_RDV__c, ' +
                            ' MER1__r.Statut__c, MER2__r.Statut__c, MER3__r.Statut__c, consumed_for_pro__c ' +
                            ' FROM Relance_RDV_MER__c ' + 
                            Label.Query_Batch_Relance_RDV_SMS_Pro_Consumer;

        relanceList = database.query(queryStr);

        Relance_RDV_Consumer consumer = new Relance_RDV_Consumer();
        consumer.execute(null, relanceList);

        List<Relance_Pro_RDV_MER__c> created_relancePro = [ SELECT id,Projet_LMSG__c,Compte_Pro__c, Mise_en_relation_LMSG__c, pro_sms_sent_time__c,
                                                            pro_sms_body__c, SMS_Pro_Sent__c FROM Relance_Pro_RDV_MER__c ];

        Map<String, MessagingSession> msMap = new Map<String, MessagingSession> ();
        for(Relance_Pro_RDV_MER__c rel : created_relancePro) {
            rel.pro_sms_sent_time__c = system.today()-2;
            rel.SMS_Pro_Sent__c = true;
            System.debug('******* relance = ' + rel);

            // Create MS
            msMap.put(messagingChannel+'_'+ MSUMap.get(rel.Compte_Pro__c) , new MessagingSession(MessagingEndUserId = MSUMap.get(rel.Compte_Pro__c), Origin='TriggeredOutbound',
                                            MessagingChannelId = messagingChannel, Status = 'Ended'));
        }
        insert msMap.values();

        // skip the first project from being called :
        created_relancePro[0].pro_sms_sent_time__c = system.today();
        created_relancePro[1].pro_sms_sent_time__c = system.today();
        id proj1 = created_relancePro[0].Projet_LMSG__c;
        id proj2 = created_relancePro[1].Projet_LMSG__c;

        update created_relancePro;
       
        database.executebatch(new Relance_RDV_Call_Consumer());
        Test.stopTest();

        created_relancePro = [ SELECT id, call_done__c, Projet_LMSG__c FROM Relance_Pro_RDV_MER__c ];
        for(Relance_Pro_RDV_MER__c rel : created_relancePro) {
            if(rel.Projet_LMSG__c == proj1 || rel.Projet_LMSG__c == proj2) {
                System.assertEquals(false, rel.call_done__c);
            } else {
                System.assertEquals(true, rel.call_done__c);
            }
        }

        List<vhc__Campaign_Member__c> callList = [SELECT id, Projet_LMSG__c, vhc__Campaign__c, vhc__ClickToDial__c , vhc__Priority__c, vhc__Status__c
                                                  FROM vhc__Campaign_Member__c ];
        
        System.assertEquals(3, callList.size());

        for(vhc__Campaign_Member__c callMem : callList) {
            System.assertNotEquals(proj1, callMem.Projet_LMSG__c);
            System.assertNotEquals(proj2, callMem.Projet_LMSG__c);
        }

    }

    // Add Mers
    private static void createMERs() {
        List<Projet_LMSG__c> projects = [SELECT id, Date_modification_statut__c FROM Projet_LMSG__c];
        System.assertEquals(5, projects.size(), 'Nombre de projets total doit etre 5');
        List<Account> accounts = [SELECT id FROM Account WHERE isPersonAccount = false];

        // Creation de MER sur les projets :
        List<Mise_en_relation__c> merList = new List<Mise_en_relation__c>();
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[0].id, Compte_Pro__c = accounts[0].id,Statut__c = 'Pro_selectionne', 
                                             Date_Heure_rendez_vous__c = null, statut_RDV__c ='En_attente'));
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[0].id, Compte_Pro__c = accounts[1].id,Statut__c = 'Pro_selectionne', 
                                             Date_Heure_rendez_vous__c = null, statut_RDV__c ='En_attente'));
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[0].id, Compte_Pro__c = accounts[2].id,Statut__c = 'Pro_positionne', 
                                             Date_Heure_rendez_vous__c = null, statut_RDV__c ='En_attente'));

        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[1].id, Compte_Pro__c = accounts[0].id,Statut__c = 'Pro_selectionne', 
                                             Date_Heure_rendez_vous__c = system.now(), statut_RDV__c ='En_attente'));
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[1].id, Compte_Pro__c = accounts[1].id,Statut__c = 'Pro_rencontre', 
                                             Date_Heure_rendez_vous__c = null, statut_RDV__c ='En_attente'));
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[1].id, Compte_Pro__c = accounts[2].id,Statut__c = 'Pro_selectionne', 
                                             Date_Heure_rendez_vous__c = system.now(), statut_RDV__c ='En_attente'));
        
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[2].id, Compte_Pro__c = accounts[0].id,Statut__c = 'Pro_selectionne', 
                                             Date_Heure_rendez_vous__c = null, statut_RDV__c ='En_attente'));
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[2].id, Compte_Pro__c = accounts[1].id,Statut__c = 'Pro_selectionne', 
                                             Date_Heure_rendez_vous__c = null, statut_RDV__c ='En_attente'));
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[2].id, Compte_Pro__c = accounts[2].id,Statut__c = 'Pro_selectionne', 
                                             Date_Heure_rendez_vous__c = null, statut_RDV__c ='En_attente'));
        
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[3].id, Compte_Pro__c = accounts[0].id,Statut__c = 'Pro_selectionne', 
                                             Date_Heure_rendez_vous__c = null, statut_RDV__c ='En_attente'));
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[3].id, Compte_Pro__c = accounts[1].id,Statut__c = 'Pro_selectionne', 
                                             Date_Heure_rendez_vous__c = null, statut_RDV__c ='En_attente'));
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[3].id, Compte_Pro__c = accounts[2].id,Statut__c = 'Pro_selectionne', 
                                             Date_Heure_rendez_vous__c = null, statut_RDV__c ='En_attente'));

        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[4].id, Compte_Pro__c = accounts[0].id,Statut__c = 'Pro_selectionne', 
                                             Date_Heure_rendez_vous__c = null, statut_RDV__c =null));
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[4].id, Compte_Pro__c = accounts[1].id,Statut__c = 'Pro_selectionne', 
                                             Date_Heure_rendez_vous__c = null, statut_RDV__c =null));
        
        insert merList;
        for(Mise_en_relation__c mer : merList) {
            mer.Date_selection__c = system.today()-4;
        }
        update merList;
    }

    @testSetup static void setup() {
        CreateRef();

        id rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id;
        String codeEns = [SELECT id, key__c FROM reference__c WHERE Name='ACS'].key__c;
        String listEns = [SELECT id, Name FROM reference__c WHERE Name='ACS'].Name;
        id codeNaf = [SELECT id FROM reference__c WHERE Name='AAA'].id;
        id pays = [SELECT id FROM reference__c WHERE Name='France'].id;
        id cp = [SELECT id FROM reference__c WHERE Name='75017'].id;

        List<Contact> insertCtc = new List<Contact>();
		Account pro1 = CreateAccount('mail1@testorg.com', '1111', '1111', 'pro1', '32212091600208', '+33633333333', 'ACC1' /* wbeId*/, rt, codeEns, listEns, codeNaf, pays, cp);
		Contact ctc1 = new Contact( Salutation = 'M.', FirstName = 'Test3', LastName = 'Test3', Contact_Principal_O_N__c = true, MobilePhone='+33633333333',
										email = 'mail1@testorg.com', Email__c = 'mail1@testorg.com', AccountId = pro1.id, External_Contact_Id__c = 'CONTACT1_id');
        insertCtc.add(ctc1);

		Account pro2 = CreateAccount('mail2@testorg.com', '2222', '2222', 'pro2', '81978912400016', '+33644444444', 'ACC2' /* wbeId*/, rt, codeEns, listEns, codeNaf, pays, cp);
		Contact ctc2 = new Contact( Salutation = 'M.', FirstName = 'Ctc PRO 2', LastName = 'test', Contact_Principal_O_N__c = true, MobilePhone='+33644444444',
									email = 'mail2@testorg.com', Email__c = 'mail2@testorg.com', AccountId = pro2.id, External_Contact_Id__c = 'CONTACT2_id');
        insertCtc.add(ctc2);

        Account pro3 = CreateAccount('mail3@testorg.com', '3333', '3333', 'pro3', '40043682000015', '+33655555555', 'ACC3' /* wbeId*/, rt, codeEns, listEns, codeNaf, pays, cp);
		Contact ctc3 = new Contact( Salutation = 'M.', FirstName = 'Ctc PRO 3', LastName = 'test', Contact_Principal_O_N__c = true, MobilePhone='+33655555555',
									email = 'mail3@testorg.com', Email__c = 'mail3@testorg.com', AccountId = pro3.id, External_Contact_Id__c = 'CONTACT3_id');
        insertCtc.add(ctc3);
           
        Account pro4 = CreateAccount('mail4@testorg.com', '4444', '4444', 'pro4', '50211792200026', '+33666666666', 'ACC4' /* wbeId*/, rt, codeEns, listEns, codeNaf, pays, cp );
		Contact ctc4 = new Contact( Salutation = 'M.', FirstName = 'Ctc PRO 4', LastName = 'test', Contact_Principal_O_N__c = true, MobilePhone='+33666666666',
		    						email = 'mail4@testorg.com', Email__c = 'mail4@testorg.com', AccountId = pro4.id, External_Contact_Id__c = 'CONTACT4_id');
        insertCtc.add(ctc4);

        Account pro5 = CreateAccount('mail5@testorg.com', '5555', '5555', 'pro5', '50026948500016', '+33677777777', 'ACC5' /* wbeId*/, rt, codeEns, listEns, codeNaf, pays, cp );
		Contact ctc5 = new Contact( Salutation = 'M.', FirstName = 'Ctc PRO 5', LastName = 'test', Contact_Principal_O_N__c = true, MobilePhone='+33677777777',
									email = 'mail5@testorg.com', Email__c = 'mail5@testorg.com', AccountId = pro5.id, External_Contact_Id__c = 'CONTACT5_id');
        insertCtc.add(ctc5);

        Account pro6 = CreateAccount('mail6@testorg.com', '6666', '6666', 'pro6', '37887802900016', '+33688888888', 'ACC6' /* wbeId*/, rt, codeEns, listEns, codeNaf, pays, cp );
		Contact ctc6 = new Contact( Salutation = 'M.', FirstName = 'Ctc PRO 6', LastName = 'test', Contact_Principal_O_N__c = true, MobilePhone='+33688888888',
								    email = 'mail6@testorg.com', Email__c = 'mail6@testorg.com', AccountId = pro6.id, External_Contact_Id__c = 'CONTACT6_id');
        insertCtc.add(ctc6);

        insert insertCtc;

        vhc__Customer__c cust = new vhc__Customer__c(Name='LMSG');
        insert cust;

        // outgoing Campaign :
        vhc__Outgoing_Campaign__c outgCampPart = new vhc__Outgoing_Campaign__c( Name = Label.Campagne_Relance_Part_RDV_DEVIS, vhc__Active__c=true, vhc__AnsweringTYpeSelect__c = 'DRIVER', vhc__Auto_Record__c=true,
                                                                       vhc__Callback_Rule__c ='{"NoAnswer":{"type":2,"param":"00:10","name":""},"Disturbed":{"type":0,"param":null,"name":""},"Busy":{"type":2,"param":"00:10","name":""},"AnsweringMachine":{"type":2,"param":"00:10","name":""},"Abandon":{"type":2,"param":"00:10","name":""},"Missed":{"type":0,"param":null,"name":""}}',
                                                                       /*vhc__Campaign_ID__c,*/ vhc__Country_Number_Format__c='FR',/* vhc__DbName__c= ,*/
                                                                       vhc__Language__c = 'fr', vhc__MaxChannels__c =1, vhc__National_Number_Format__c=true,
                                                                       /*vhc__Oid__c,*/  vhc__OutAbandon__c=1, vhc__outMode__c='Progressive',  vhc__OutRetries__c=3,  vhc__OutRing__c=3,
                                                                        vhc__OutWait__c=1,  vhc__Patience__c=1, vhc__PhoneDisplay__c='A Specific Phonenumber',
                                                                        vhc__PhoneDisplaySpecific__c='+33188247005', vhc__Use_Distribution_Rule__c=false, 
                                                                        vhc__Virtual__c=false, vhc__Wait_duration_before_detection_sec__c=1, vhc__customer__c=cust.id);
         insert outgCampPart;

		Vhc__campaign__c camp1 = new Vhc__campaign__c ( vhc__Outgoing_Campaign__c = outgCampPart.id, name=Label.Campagne_Relance_Part_RDV_DEVIS, vhc__Block_duplication__c=false,
                                        vhc__Country_Number_Format__c='FR', vhc__National_Number_Format__c=true);
        insert camp1;

        List<Account> parts = new List<Account>();
        parts.add(new Account(firstName ='Albert' , lastName = 'Heinestein', PersonTitle = 'M', PersonEmail = 'mail32@testorg.com', PersonMobilePhone='+33627795581' ));
        parts.add(new Account(firstName ='Robert' , lastName = 'Clark', PersonTitle = 'M', PersonEmail = 'mail42@testorg.com', PersonMobilePhone= '+33766725053'));
        parts.add(new Account(firstName ='Philippe' , lastName = 'Bellou', PersonTitle = 'M', PersonEmail = 'mail52@testorg.com', PersonMobilePhone= '+33611111111'));
        parts.add(new Account(firstName ='Thomas' , lastName = 'Guan', PersonTitle = 'M', PersonEmail = 'mail62@testorg.com', PersonMobilePhone= '+33622222222'));

        insert parts;
        Id messagingChannel = [SELECT id FROM MessagingChannel WHERE DeveloperName=:Label.Messaging_Channel_API_Name].id;
        List<MessagingEndUser> MSU = new List<MessagingEndUser>();
        for(Account part : parts) {
            MSU.add(new MessagingEndUser(name=part.PersonMobilePhone, MessagingChannelId=messagingChannel, AccountId = part.id, ContactId = part.personContactId, MessageType ='Text', MessagingPlatformKey=part.PersonMobilePhone));
        }
        for(Contact pro : insertCtc) {
            MessagingEndUser mu = new MessagingEndUser(name=pro.MobilePhone, MessagingChannelId=messagingChannel, AccountId = pro.AccountId, ContactId = pro.id, MessageType ='Text', MessagingPlatformKey=pro.MobilePhone);
            MSU.add(mu);
        }
        insert MSU;
        for(MessagingEndUser mu : MSU) {
            System.debug('****** MU = ' + mu.id + ' Acc' + mu.AccountId + ' CTC ' + mu.contactId + ' Name' + mu.Name);
        }

		// Create projects :
        List<Projet_LMSG__c> prjList = new List<Projet_LMSG__c>();
        Projet_LMSG__c prj1 = new Projet_LMSG__c(   Identifiant_PP__c='P001', Chiffrage_bsku__c = 'B1001', Chiffrage_maximum__c = 10500,
                                                    Date_de_debut_de_chantier__c = system.today() + 5, Date_de_fin_de_chantier__c = system.today() + 30,
                                                    Particulier__c = parts[0].id, Statut__c = 'PUBLISHED', Telephone_Mobile__c='+33102030444');
        prjList.add( prj1);

        Projet_LMSG__c prj2 = new Projet_LMSG__c( Identifiant_PP__c='P002', Chiffrage_bsku__c = 'B1002', Chiffrage_maximum__c = 10200, 
                                Date_de_debut_de_chantier__c = system.today() + 10, Date_de_fin_de_chantier__c = system.today() + 35,
                                Particulier__c = parts[0].id, Statut__c = 'PUBLISHED', Telephone_Mobile__c='+33627795581');
        prjList.add( prj2);

        Projet_LMSG__c prj3 = new Projet_LMSG__c( Identifiant_PP__c='P003', Chiffrage_bsku__c = 'B1003', Chiffrage_maximum__c = 45000, 
                                                    Date_de_debut_de_chantier__c = system.today() + 15, Date_de_fin_de_chantier__c = system.today() + 40,
                                                    Particulier__c = parts[1].id, Statut__c = 'PUBLISHED', Telephone_Mobile__c='+33627795581');
        prjList.add( prj3);

        Projet_LMSG__c prj4 = new Projet_LMSG__c( Identifiant_PP__c='P004', Chiffrage_bsku__c = 'B1004', Chiffrage_maximum__c = 80000, 
                                                    Date_de_debut_de_chantier__c = system.today() + 20, Date_de_fin_de_chantier__c = system.today() + 45,
                                                    Particulier__c = parts[2].id, Statut__c = 'PUBLISHED', Telephone_Mobile__c='+33627795581');
        prjList.add( prj4);

        Projet_LMSG__c prj5 = new Projet_LMSG__c( Identifiant_PP__c='P005', Chiffrage_bsku__c = 'B1004', Chiffrage_maximum__c = 90000,
                                                    Date_de_debut_de_chantier__c = system.today() + 20, Date_de_fin_de_chantier__c = system.today() + 45,
                                                    Particulier__c = parts[3].id, Statut__c = 'PUBLISHED', Telephone_Mobile__c='+33627795581');
        prjList.add( prj5);
		insert prjList;
        
		WBE_Token__c wbeToken = WBE_Token__c.getOrgDefaults();
        wbeToken.Name = 'WBE Token';
        wbeToken.Token__c = '4f428f16-f24e-4d62-b885-0489c7e8f512';
        wbeToken.Expire_Date__c = datetime.now();
        upsert wbeToken;
	}

    static Account CreateAccount(String email, String codeClient, String profileId, String Name, String Siret, String tel,  String wbeId, id recordtypeId, 
                                 String codeEns, String listEns, id codeNaf, id pays, id cp ) {       
        Account compte = new Account();
        compte.RecordTypeId = recordtypeId; 
        compte.Name = Name;
        compte.Phone = tel;
        compte.Liste_des_enseignes_de_gestion_o_il_est__c =  listEns;
        compte.Flux_code_Enseigne__c =  codeEns;
        compte.SIRET_texte__c = Siret;
        compte.Code_NAF_APE_societe_declarante__c = codeNaf;
        compte.A_ne_jamais_rappeler__c = false;
        compte.External_ID__c = 'pro_'+wbeId;
        compte.Pays_LKP__c = pays;
        compte.Code_postal__c = cp;
        
        // Account : 
        compte.Compte_Nouvelles_Offres__c = true;
        compte.Statut_activation__c = 'Pro_actif_positionnable';
        compte.Login__c = email;
        compte.Code_client__c = codeClient;
        compte.profile_id__c  = profileId;
		insert compte;
	    return compte;
	}
	
	static void CreateRef() {
        List<Reference__c> refList = new List<Reference__c>();
		refList.add(TestFactory.createReference('pays', 'France','FRA','France'));
        refList.add(TestFactory.createReference('CP', '75017','75017','Paris'));
        refList.add(TestFactory.createReference('NAF', 'AAA', 'AAA', 'AAA'));
        refList.add(TestFactory.createReference('enseigne', 'ACS', 'AC', 'ACS'));
		
		List<String> listDoc = new List<String> ();
		reference__c presta = TestFactory.createAndAddMandatoryDocTypeToPresta('Installation d\'un chauffe-eau','92278f', 'P100', 0, listDoc);
		presta.SKU__c = 'B1001';
		refList.add(presta);
		presta = TestFactory.createAndAddMandatoryDocTypeToPresta('Installation d\'un plancher chauffant à eau chaude','c5be38', 'P200', 0 , listDoc);
		presta.SKU__c = 'B1002';
		refList.add(presta);
		presta = TestFactory.createAndAddMandatoryDocTypeToPresta('Installation d\'un plancher chauffant électrique','a4bc1e', 'P300', 0 , listDoc);
		presta.SKU__c = 'B1003';
		refList.add(presta);
		presta = TestFactory.createAndAddMandatoryDocTypeToPresta('Installation d\'un poêle à bois','fd6898', 'P400', 0 , listDoc);
		presta.SKU__c = 'B1004';
		refList.add(presta);
		insert refList;
    }
}