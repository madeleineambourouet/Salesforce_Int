/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 10-01-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   07-29-2020   Hassan Dakhcha   Initial Version
**/
@isTest
private class Relance_ProPart_LMSG_Test {

    @isTest
    static void Relance_Part() {
        
        Test.startTest();
        List<Projet_LMSG__c> projects = [SELECT id, Date_modification_statut__c FROM Projet_LMSG__c];
        System.assertEquals(5, projects.size(), 'Nombre de projets total doit etre 5');
        List<Account> accounts = [SELECT id FROM Account WHERE isPersonAccount = false];

        // Creation de MER sur les projets :
        List<Mise_en_relation__c> merList = new List<Mise_en_relation__c>();
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[0].id, Compte_Pro__c = accounts[0].id,Statut__c = 'Pro_selectionne', Date_Heure_rendez_vous__c = null, Date_modification_statut__c = system.today()-6));
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[0].id, Compte_Pro__c = accounts[1].id,Statut__c = 'Pro_selectionne', Date_Heure_rendez_vous__c = null, Date_modification_statut__c = system.today()-4));
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[0].id, Compte_Pro__c = accounts[2].id,Statut__c = 'Pro_positionne', Date_Heure_rendez_vous__c = null, Date_modification_statut__c = system.today()-2));
        
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[1].id, Compte_Pro__c = accounts[0].id,Statut__c = 'Pro_selectionne', Date_Heure_rendez_vous__c = system.now(), Date_modification_statut__c = system.today()-6));
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[1].id, Compte_Pro__c = accounts[1].id,Statut__c = 'Pro_rencontre', Date_Heure_rendez_vous__c = null, Date_modification_statut__c = system.today()-6));
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[1].id, Compte_Pro__c = accounts[2].id,Statut__c = 'Pro_selectionne', Date_Heure_rendez_vous__c = system.now(), Date_modification_statut__c = system.today()-1));
        
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[2].id, Compte_Pro__c = accounts[0].id,Statut__c = 'Pro_selectionne', Date_Heure_rendez_vous__c = null, Date_modification_statut__c = system.today()-12));
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[2].id, Compte_Pro__c = accounts[1].id,Statut__c = 'Pro_selectionne', Date_Heure_rendez_vous__c = null, Date_modification_statut__c = system.today()-45));
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[2].id, Compte_Pro__c = accounts[2].id,Statut__c = 'Pro_selectionne', Date_Heure_rendez_vous__c = null, Date_modification_statut__c = system.today()));
        
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[3].id, Compte_Pro__c = accounts[0].id,Statut__c = 'Pro_selectionne', Date_Heure_rendez_vous__c = null, Date_modification_statut__c = system.today()-3));
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[3].id, Compte_Pro__c = accounts[1].id,Statut__c = 'Pro_selectionne', Date_Heure_rendez_vous__c = null, Date_modification_statut__c = system.today()-4));
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[3].id, Compte_Pro__c = accounts[2].id,Statut__c = 'Pro_selectionne', Date_Heure_rendez_vous__c = null, Date_modification_statut__c = system.today()-5));

        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[4].id, Compte_Pro__c = accounts[0].id,Statut__c = 'Pro_selectionne', Date_Heure_rendez_vous__c = null, Date_modification_statut__c = system.today()-8));
        merList.add( new Mise_en_relation__c(Projet_LMSG__c = projects[4].id, Compte_Pro__c = accounts[1].id,Statut__c = 'Pro_selectionne', Date_Heure_rendez_vous__c = null, Date_modification_statut__c = system.today()-5));

        insert merList;
        merList[0].Date_modification_statut__c = system.today()-6; // yes
        merList[1].Date_modification_statut__c = system.today()-4; // yes
        merList[2].Date_modification_statut__c = system.today()-2; // no
        
        merList[3].Date_modification_statut__c = system.today()-6; // no
        merList[4].Date_modification_statut__c = system.today()-6; // no
        merList[5].Date_modification_statut__c = system.today()-1; // no
        
        merList[6].Date_modification_statut__c = system.today()-12; // yes
        merList[7].Date_modification_statut__c = system.today()-45; // yes
        merList[8].Date_modification_statut__c = system.today();    // no
        
        merList[9].Date_modification_statut__c = system.today()-3;  // yes
        merList[10].Date_modification_statut__c = system.today()-4;  // yes
        merList[11].Date_modification_statut__c = system.today()-5;  // yes

        merList[12].Date_modification_statut__c = system.today()-8; // yes
        merList[13].Date_modification_statut__c = system.today()-5;  // yes
        update merList;

        System.assertEquals(14, [SELECT id FROM Mise_en_relation__c].size(), 'Nombre total de MER doit etre 14');
      
        Relance_ProPart_LMSG_Batch b = new Relance_ProPart_LMSG_Batch('relancePart'); 
        database.executebatch(b);


        String condition = Label.Query_Batch_Relance_Part_RDV_Devis.substringAfter('FROM');
        String queryStr = 'SELECT  id, Projet_LMSG__c, Projet_LMSG__r.Identifiant_PP__c, Projet_LMSG__r.Telephone_Mobile__c, Statut__c , Date_Heure_rendez_vous__c , Date_modification_statut__c FROM ' + condition;
        System.debug('#### Query = ' + queryStr);
        List<Mise_en_relation__c> mers = Database.query(queryStr);
        System.assertEquals(9, mers.size(), 'Nombre de MER trouvées doit etre 9');
        Test.stopTest();

        Set<String> mobilePhones = new Set<String>{'+33102030455', '+33102030466', '+33102030477', '+33102030488'};
        Set<String> projectNames = new Set<String>{'P001', 'P002', 'P003', 'P004', 'P005'};

        List<vhc__Campaign_Member__c> members = [ SELECT  id, Projet_HY__c, Projet_LMSG__c, Name, vhc__Priority__c, vhc__ClickToDial__c,vhc__Account__c,vhc__Contact__c,
                                                    Projet_LMSG__r.Identifiant_PP__c, vhc__Status__c,  vhc__Campaign__r.name, CreatedDate 
                                                    FROM vhc__Campaign_Member__c
                                                    WHERE Projet_LMSG__c!=null ];
        for(vhc__Campaign_Member__c mem : members) {
            System.debug('### debug MEM ' + mem);
        }
        System.assertEquals('Num created calls 4', 'Num created calls ' + members.size(), 'On doit avoir 4 relances');

        for(vhc__Campaign_Member__c mem : members) {
            System.debug('### MEM ' + mem.Projet_LMSG__r.Identifiant_PP__c + '  ' + mem);

            System.assertEquals('HIGH', mem.vhc__Priority__c, 'HIGH par defaut');
            System.assertEquals(null, mem.Projet_HY__c, 'Le call est attaché au projet LMSG' );
            System.assertNotEquals(null, mem.Projet_LMSG__c, 'Le call doit etre attaché au projet LMSG' );
            System.assertEquals(true, projectNames.contains(mem.Projet_LMSG__r.Identifiant_PP__c), 'Le call est attaché au Projet LMSG');
            System.assertEquals(null, mem.vhc__Account__c, 'Le call est attaché au Projet');
            System.assertEquals(null, mem.vhc__Contact__c, 'Le call est attaché au Projet');
            System.assertEquals('Create in progress', mem.vhc__Status__c, 'Statut To Create est mis par VHC a In progress' );
            System.assertEquals(Label.Campagne_Relance_Part_RDV_DEVIS, mem.vhc__Campaign__r.name, 'Campaign Pro');
            System.assertEquals(true, mobilePhones.contains( mem.vhc__ClickToDial__c), 'Telephone');

            projectNames.remove( mem.Projet_LMSG__r.Identifiant_PP__c);
            mobilePhones.remove( mem.vhc__ClickToDial__c);
        }

        System.assertEquals(1, projectNames.size(), 'un projet restant');
        System.assertEquals(true, mobilePhones.isEmpty(), 'must be empty');    
	}

    @isTest
    static void Relance_Pro() {
     
        Test.startTest();

        String queryStr = 'SELECT id, vhc__Call_File_Member__r.vhc__Campaign__c, vhc__Contact__c FROM vhc__Call__c ';
        System.debug('### query = ' + queryStr);
        List<vhc__Call__c> calls = Database.query(queryStr);
        System.debug('### Relance Pro pre created calls  : ' + calls.size());

		MockHttpMatchResponse mock = new MockHttpMatchResponse();
		Test.setMock(HttpCalloutMock.class, mock);
		String responseBody =  '[{"projectId":"P001","userId":"CONTACT1_id","status":"CREATED","createdAt":"2020-04-01T10:29:39.408232","positionable":true,"positionedCount":0},'+
								'{"projectId":"P002","userId":"CONTACT1_id","status":"CREATED","createdAt":"2020-04-01T13:11:01.170462","positionable":false,"positionedCount":1},'+
								'{"projectId":"P003","userId":"CONTACT1_id","status":"ACCEPTED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":2},'+
								'{"projectId":"P001","userId":"CONTACT2_id","status":"CREATED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":0},'+
                                '{"projectId":"P002","userId":"CONTACT2_id","status":"ACCEPTED","createdAt":"2020-04-01T10:29:39.408242","positionable":false,"positionedCount":0},'+
                                '{"projectId":"P005","userId":"CONTACT2_id","status":"CREATED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":0},'+
                                '{"projectId":"P001","userId":"CONTACT3_id","status":"CREATED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":0},'+
                                '{"projectId":"P001","userId":"CONTACT4_id","status":"CREATED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":0},'+
                                '{"projectId":"P001","userId":"CONTACT5_id","status":"CREATED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":0},'+
                                '{"projectId":"P001","userId":"CONTACT6_id","status":"CREATED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":0},'+
								'{"projectId":"P004","userId":"CONTACT1_id","status":"CREATED","createdAt":"2020-04-01T10:29:39.408242","positionable":true,"positionedCount":0}]';
        mock.setResponseBody(responseBody);
        String condition = Label.Query_Batch_Relance_Pro_AR3.substringAfter('FROM');
        queryStr = 'SELECT id, Identifiant_PP__c, Nombre_de_MER_restantes__c, Date_modification_statut__c FROM ' + condition;
        System.debug('#### Query = ' + queryStr);
        List<Projet_LMSG__c> projects = Database.query(queryStr);
        System.assertEquals(4, projects.size(), 'Nombre de projets trouvé doit etre 4');

		String endPointArgs = 'userIds=&projectIds=';
		for(Projet_LMSG__c prj : projects) {
            endPointArgs +=  prj.Identifiant_PP__c +',';
            System.debug('#### Projet = ' + prj);
        }
		mock.setEndPointArgs(endPointArgs.substringBeforeLast(',') + '&archived=false');

        System.assertEquals(5, [SELECT id, Date_modification_statut__c FROM Projet_LMSG__c].size(), 'Total des projets est 5');

        Relance_ProPart_LMSG_Batch b = new Relance_ProPart_LMSG_Batch('relancePro'); 
        database.executebatch(b);

        Test.stopTest();
     
        Set<id> callids = new Set<id>();
        for(vhc__Call__c call : calls) {
            callids.add(call.vhc__Call_File_Member__c);
        }
        List<vhc__Campaign_Member__c> callList = [SELECT id FROM vhc__Campaign_Member__c WHERE id IN :callids];
        delete callList;

        Set<String> contactMatch = new Set<String>{'Test3 Test3', 'Ctc PRO 2 test'};
        Set<String> mobilePhones = new Set<String>{'+33612232323', '+33611313345'};

        List<vhc__Campaign_Member__c> members = [ SELECT  id, Projet_HY__c, Projet_LMSG__c, Name, vhc__Priority__c, vhc__ClickToDial__c,vhc__Account__c,vhc__Contact__c,
                                                  vhc__Account__r.Name, vhc__Contact__r.Name,
                                                  vhc__Status__c,  vhc__Campaign__r.name, CreatedDate FROM vhc__Campaign_Member__c];
        for(vhc__Campaign_Member__c mem : members) {
            System.debug('### debug MEM ' + mem);
        }
        System.assertEquals('Num created calls 2', 'Num created calls ' + members.size(), 'On doit avoir 2 relances');
      
        for(vhc__Campaign_Member__c mem : members) {
            System.assertEquals('HIGH', mem.vhc__Priority__c, 'HIGH par defaut');
            System.assertEquals(null, mem.Projet_HY__c, 'Le call est attaché au contact principal' );
            System.assertEquals(null, mem.Projet_LMSG__c, 'Le call est attaché au contact principal');
            System.assertEquals(null, mem.vhc__Account__c, 'Le call doit etre atthé a un seul objet ');
            System.assertEquals(true, contactMatch.contains( mem.vhc__Contact__r.Name), 'Le call est attaché au contact principal');
            System.assertEquals('Create in progress', mem.vhc__Status__c, 'Statut To Create est mis par VHC a In progress' );
            System.assertEquals('CS_Relance_Pro_AR3', mem.vhc__Campaign__r.name, 'Campaign Pro');
            System.assertEquals(true, mobilePhones.contains( mem.vhc__ClickToDial__c), 'Telephone');

            contactMatch.remove( mem.vhc__Contact__r.Name);
            mobilePhones.remove( mem.vhc__ClickToDial__c);
        }
        System.assertEquals(true, contactMatch.isEmpty(), 'must be empty');
        System.assertEquals(true, mobilePhones.isEmpty(), 'must be empty');
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
		Account pro1 = CreateAccount('mail1@testorg.com', '1111', '1111', 'pro1', '32212091600208', '+33635136116', 'ACC1' /* wbeId*/, rt, codeEns, listEns, codeNaf, pays, cp);
		Contact ctc1 = new Contact( Salutation = 'M.', FirstName = 'Test3', LastName = 'Test3', Contact_Principal_O_N__c = true, MobilePhone='+33612232323',
										email = 'mail1@testorg.com', Email__c = 'mail1@testorg.com', AccountId = pro1.id, External_Contact_Id__c = 'CONTACT1_id');
        insertCtc.add(ctc1);

		Account pro2 = CreateAccount('mail2@testorg.com', '2222', '2222', 'pro2', '81978912400016', '+33635144116', 'ACC2' /* wbeId*/, rt, codeEns, listEns, codeNaf, pays, cp);
		Contact ctc2 = new Contact( Salutation = 'M.', FirstName = 'Ctc PRO 2', LastName = 'test', Contact_Principal_O_N__c = true, MobilePhone='+33611313345',
									email = 'mail2@testorg.com', Email__c = 'mail2@testorg.com', AccountId = pro2.id, External_Contact_Id__c = 'CONTACT2_id');
        insertCtc.add(ctc2);
        
        Account pro3 = CreateAccount('mail3@testorg.com', '3333', '3333', 'pro3', '40043682000015', '+33635121116', 'ACC3' /* wbeId*/, rt, codeEns, listEns, codeNaf, pays, cp);
		Contact ctc3 = new Contact( Salutation = 'M.', FirstName = 'Ctc PRO 3', LastName = 'test', Contact_Principal_O_N__c = true, MobilePhone='+33611555345',
									email = 'mail3@testorg.com', Email__c = 'mail3@testorg.com', AccountId = pro3.id, External_Contact_Id__c = 'CONTACT3_id');
        insertCtc.add(ctc3);
                    
        Account pro4 = CreateAccount('mail4@testorg.com', '4444', '4444', 'pro4', '50211792200026', '+33633336116', 'ACC4' /* wbeId*/, rt, codeEns, listEns, codeNaf, pays, cp );
		Contact ctc4 = new Contact( Salutation = 'M.', FirstName = 'Ctc PRO 4', LastName = 'test', Contact_Principal_O_N__c = true, MobilePhone='+33611555445',
		    						email = 'mail4@testorg.com', Email__c = 'mail4@testorg.com', AccountId = pro4.id, External_Contact_Id__c = 'CONTACT4_id');
        insertCtc.add(ctc4);

        Account pro5 = CreateAccount('mail5@testorg.com', '5555', '5555', 'pro5', '50026948500016', '+33635139996', 'ACC5' /* wbeId*/, rt, codeEns, listEns, codeNaf, pays, cp );
		Contact ctc5 = new Contact( Salutation = 'M.', FirstName = 'Ctc PRO 5', LastName = 'test', Contact_Principal_O_N__c = true, MobilePhone='+33611555545',
									email = 'mail5@testorg.com', Email__c = 'mail5@testorg.com', AccountId = pro5.id, External_Contact_Id__c = 'CONTACT5_id');
        insertCtc.add(ctc5);
        
        Account pro6 = CreateAccount('mail6@testorg.com', '6666', '6666', 'pro6', '37887802900016', '+33635544416', 'ACC6' /* wbeId*/, rt, codeEns, listEns, codeNaf, pays, cp );
		Contact ctc6 = new Contact( Salutation = 'M.', FirstName = 'Ctc PRO 6', LastName = 'test', Contact_Principal_O_N__c = true, MobilePhone='+33611555645',
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
        vhc__Outgoing_Campaign__c outgCampPro = new  vhc__Outgoing_Campaign__c( Name = Label.Campagne_Relance_Pro_AR3, vhc__Active__c=true, vhc__AnsweringTYpeSelect__c = 'DRIVER', vhc__Auto_Record__c=true,
                                                                        vhc__Callback_Rule__c ='{"NoAnswer":{"type":2,"param":"00:10","name":""},"Disturbed":{"type":0,"param":null,"name":""},"Busy":{"type":2,"param":"00:10","name":""},"AnsweringMachine":{"type":2,"param":"00:10","name":""},"Abandon":{"type":2,"param":"00:10","name":""},"Missed":{"type":0,"param":null,"name":""}}',
                                                                        /*vhc__Campaign_ID__c,*/ vhc__Country_Number_Format__c='FR',/* vhc__DbName__c= ,*/
                                                                        vhc__Language__c = 'fr', vhc__MaxChannels__c =1, vhc__National_Number_Format__c=true,
                                                                        /*vhc__Oid__c,*/  vhc__OutAbandon__c=1, vhc__outMode__c='Progressive',  vhc__OutRetries__c=3,  vhc__OutRing__c=3,
                                                                         vhc__OutWait__c=1,  vhc__Patience__c=1, vhc__PhoneDisplay__c='A Specific Phonenumber',
                                                                         vhc__PhoneDisplaySpecific__c='+33188247005', vhc__Use_Distribution_Rule__c=false, 
                                                                         vhc__Virtual__c=false, vhc__Wait_duration_before_detection_sec__c=1, vhc__customer__c=cust.id);

        insert ( new List<vhc__Outgoing_Campaign__c> {outgCampPart, outgCampPro});

		Vhc__campaign__c camp1 = new Vhc__campaign__c ( vhc__Outgoing_Campaign__c = outgCampPart.id, name=Label.Campagne_Relance_Part_RDV_DEVIS, vhc__Block_duplication__c=false,
                                        vhc__Country_Number_Format__c='FR', vhc__National_Number_Format__c=true);
        Vhc__campaign__c camp2 = new Vhc__campaign__c ( vhc__Outgoing_Campaign__c = outgCampPro.id, name=Label.Campagne_Relance_Pro_AR3,
                                        vhc__Block_duplication__c=false, vhc__Country_Number_Format__c='FR', vhc__National_Number_Format__c=true);
        insert (new List<Vhc__campaign__c> {camp1, camp2});

        // filtrer le pro 3 avec le call 
        List<vhc__Campaign_Member__c> campMem = new List<vhc__Campaign_Member__c>();
        vhc__Campaign_Member__c cmpMem1 = new vhc__Campaign_Member__c(vhc__Priority__c='HIGH', vhc__ClickToDial__c='+33611555345',vhc__Account__c =pro3.id ,
                                                vhc__Contact__c = ctc3.id, vhc__Status__c='To Create',  vhc__Campaign__c = camp2.id);
        campMem.add(cmpMem1);
        vhc__Campaign_Member__c cmpMem2 = new vhc__Campaign_Member__c(vhc__Priority__c='HIGH', vhc__ClickToDial__c='+33611555445',vhc__Account__c =pro4.id ,
                                                                     vhc__Contact__c = ctc4.id, vhc__Status__c='To Create',  vhc__Campaign__c = camp2.id);
        campMem.add(cmpMem2);       
        vhc__Campaign_Member__c cmpMem3 = new vhc__Campaign_Member__c(vhc__Priority__c='HIGH', vhc__ClickToDial__c='+33611555545',vhc__Account__c =pro5.id ,
                                                                     vhc__Contact__c = ctc5.id, vhc__Status__c='To Create',  vhc__Campaign__c = camp2.id);
        campMem.add(cmpMem3);       
        vhc__Campaign_Member__c cmpMem4 = new vhc__Campaign_Member__c(vhc__Priority__c='HIGH', vhc__ClickToDial__c='+33611555645',vhc__Account__c =pro6.id ,
                                                                     vhc__Contact__c = ctc6.id, vhc__Status__c='To Create',  vhc__Campaign__c = camp2.id);
        campMem.add(cmpMem4);       
        insert campMem;

        List<vhc__call__c> newCalls = new List<vhc__call__c> ();
        newCalls.add(new vhc__call__c(vhc__Status__c ='Call success', vhc__Qualification__c='Ne pas rappeler', 	vhc__Call_File_Member__c = cmpMem1.id,
                         vhc__Contact__c = cmpMem1.vhc__Contact__c, vhc__Account__c = cmpMem1.vhc__Account__c));
        newCalls.add(new vhc__call__c(vhc__Status__c ='Call success', vhc__Qualification__c='Rappel Personnel', 	vhc__Call_File_Member__c = cmpMem2.id,
                         vhc__Contact__c = cmpMem2.vhc__Contact__c, vhc__Account__c = cmpMem2.vhc__Account__c));
        newCalls.add(new vhc__call__c(vhc__Status__c ='Call success', vhc__Qualification__c='Relance', 	vhc__Call_File_Member__c = cmpMem3.id,
                         vhc__Contact__c = cmpMem3.vhc__Contact__c, vhc__Account__c = cmpMem3.vhc__Account__c));
        newCalls.add(new vhc__call__c(vhc__Status__c ='Call success', vhc__Qualification__c='PRO nous recontacte', 	vhc__Call_File_Member__c = cmpMem4.id,
                         vhc__Contact__c = cmpMem4.vhc__Contact__c, vhc__Account__c = cmpMem4.vhc__Account__c));
       
        insert newCalls;

        List<Account> parts = new List<Account>();
        parts.add(new Account(firstName ='Albert' , lastName = 'Heinestein', PersonTitle = 'M', PersonEmail = 'mail32@testorg.com', PersonMobilePhone='+33102030455' ));
        parts.add(new Account(firstName ='Robert' , lastName = 'Clark', PersonTitle = 'M', PersonEmail = 'mail42@testorg.com', PersonMobilePhone= '+33102030466'));
        parts.add(new Account(firstName ='Philippe' , lastName = 'Bellou', PersonTitle = 'M', PersonEmail = 'mail52@testorg.com', PersonMobilePhone= '+33102030477'));
        parts.add(new Account(firstName ='Thomas' , lastName = 'Guan', PersonTitle = 'M', PersonEmail = 'mail62@testorg.com', PersonMobilePhone= '+33102030488'));

        insert parts;

		// Create projects :
        List<Projet_LMSG__c> prjList = new List<Projet_LMSG__c>();
        Projet_LMSG__c prj1 = new Projet_LMSG__c(   Identifiant_PP__c='P001', Chiffrage_bsku__c = 'B1001', Chiffrage_maximum__c = 10500,
                                                    Date_de_debut_de_chantier__c = system.today() + 5, Date_de_fin_de_chantier__c = system.today() + 30,
                                                    Particulier__c = parts[0].id, Statut__c = 'PUBLISHED', Telephone_Mobile__c='+33102030455');
        prjList.add( prj1);

        Projet_LMSG__c prj2 = new Projet_LMSG__c( Identifiant_PP__c='P002', Chiffrage_bsku__c = 'B1002', Chiffrage_maximum__c = 10200, 
                                Date_de_debut_de_chantier__c = system.today() + 10, Date_de_fin_de_chantier__c = system.today() + 35,
                                Particulier__c = parts[0].id, Statut__c = 'PUBLISHED', Telephone_Mobile__c='+33102030455');
        prjList.add( prj2);

        Projet_LMSG__c prj3 = new Projet_LMSG__c( Identifiant_PP__c='P003', Chiffrage_bsku__c = 'B1003', Chiffrage_maximum__c = 45000, 
                                                    Date_de_debut_de_chantier__c = system.today() + 15, Date_de_fin_de_chantier__c = system.today() + 40,
                                                    Particulier__c = parts[1].id, Statut__c = 'PUBLISHED', Telephone_Mobile__c='+33102030466');
        prjList.add( prj3);

        Projet_LMSG__c prj4 = new Projet_LMSG__c( Identifiant_PP__c='P004', Chiffrage_bsku__c = 'B1004', Chiffrage_maximum__c = 80000, 
                                                    Date_de_debut_de_chantier__c = system.today() + 20, Date_de_fin_de_chantier__c = system.today() + 45,
                                                    Particulier__c = parts[2].id, Statut__c = 'PUBLISHED', Telephone_Mobile__c='+33102030477');
        prjList.add( prj4);

        Projet_LMSG__c prj5 = new Projet_LMSG__c( Identifiant_PP__c='P005', Chiffrage_bsku__c = 'B1004', Chiffrage_maximum__c = 80000,
                                                    Date_de_debut_de_chantier__c = system.today() + 20, Date_de_fin_de_chantier__c = system.today() + 45,
                                                    Particulier__c = parts[3].id, Statut__c = 'PUBLISHED', Telephone_Mobile__c='+33102030488');
        prjList.add( prj5);
		insert prjList;
        
        prj1.Date_modification_statut__c = system.today()-19;
        prj2.Date_modification_statut__c = system.today()-6;
        prj3.Date_modification_statut__c = system.today()-3;
        prj4.Date_modification_statut__c = system.today()-3;
        prj5.Date_modification_statut__c = system.today()-1;
        update prjList;

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
        compte.Statut_activation__c = 'Nouveau';
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