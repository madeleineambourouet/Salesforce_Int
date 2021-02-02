@isTest(seealldata = false)
private class Test_LeadManagement {

	private static testMethod void test() 
	{

/**	    
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'AAA'); 
	    insert NAF;
	    
	    Reference__c FR = new Reference__c(RecordTypeId = RTPays, key__c = 'FRA', Name = 'France');
	    insert FR;
**/
	  /*  Lead sansSIRET = new Lead(Salutation = 'M.', FirstName = 'Pierrot', LastName = 'Carpe', SIRET__c = '32212091600208', Company = 'B&D', Status = 'Ouverte', Code_NAF__c = NAF.Id,
	                                Phone = '+33111111111');//, Code_NAF__c='AAA');
	    insert sansSIRET;
	    sansSIRET.piste_qualifiee__c = true;
	    update sansSIRET;
	  */

        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;

        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');
        insert NAF;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;

	  
	  //  Account compte = new Account(Name = 'Societe test', SIRET_texte__c = '32212091600208', Code_NAF_APE_societe_declarante__c = NAF.Id);
	  Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                        /*Nom_de_l_assurance__c = 'MAIF',*/ Pays_LKP__c = FR.id, Code_postal__c = CP.Id, 
                                        Code_NAF_APE_societe_declarante__c = NAF.Id, Code_client__c = 'testa');
	    insert compte;
        System.debug('test create compte ' + compte);
	    //compte = [SELECT id, SIRET_texte__c FROM Account WHERE id = :compte.Id LIMIT 1];
	    //System.debug('>>>>>>>>>> SIRET COMPTE = ' + compte.SIRET__c);
	    Contact ctc = new Contact(Salutation = 'M.', FirstName = 'Pierrot', LastName = 'Carpe', AccountId = compte.Id, Phone = '+33111111111', MobilePhone = '+33777777777', Email = 'pcarpe@gmail.com');
	    insert ctc;
	    
        Account compteBis = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '38347481400100', Phone = '+33654565456', 
                                         Pays_LKP__c = FR.id, Code_postal__c = CP.Id, 
                                        Code_NAF_APE_societe_declarante__c = NAF.Id, Code_client__c = 'testb');
	    insert compteBis;
        System.debug('compteBis ' + compteBis);
        
        Contact ctcBis = new Contact(Salutation = 'Mme', FirstName = 'Mado', LastName = 'Boucledor', AccountId = compteBis.Id, Phone = '+33455667788', MobilePhone = '+33621123443', Email = 'madobd@gmail.com');
	    insert ctcBis;
        
        List<Lead> TestList = new List<Lead>();
        List<String> TestListId = new List<String>();
        //Map<Integer,String> TestMapId = new Map<Integer,String>();
        
        Lead SIRETinconnu = new Lead(Salutation = 'M.', FirstName = 'Zubizuba', LastName = 'Zuber', SIRET__c = '77566343801906', Company = 'Zuber Man', Status = 'Ouverte', Code_NAF__c = NAF.Id, Email = 'zuzuzu@gmail.com', Phone = '+33123412341', MobilePhone = '+33612341234');
        TestList.add(SIRETinconnu);
        Lead SIRETconnu = new Lead(Salutation = 'Mme', FirstName = 'Zézile', LastName = 'Zuber', SIRET__c = '32212091600208', Company = 'Zubermarché', Status = 'Ouverte', Code_NAF__c = NAF.Id);
        TestList.add(SIRETconnu);
        //System.debug('SIRETconnu content ' + SIRETconnu);
        Lead EmailTelConnus = new Lead(Salutation = 'Mme', FirstName = 'Zuzanne', LastName = 'Zuber', SIRET__c = '48193694600013', Company = 'Zuber Eats', Status = 'Ouverte', Code_NAF__c = NAF.Id, Phone = '+33111111111', MobilePhone = '+33666666666', Email = 'pcarpe@gmail.com');
        TestList.add(EmailTelConnus);
        Lead EmailMobileConnus = new Lead(Salutation = 'Mme', FirstName = 'Pauline', LastName = 'Zuborestel', SIRET__c = '75301167500018', Company = 'Zuberdry', Status = 'Ouverte', Code_NAF__c = NAF.Id, Phone = '+33222222222', MobilePhone = '+33777777777', Email = 'pcarpe@gmail.com');
        TestList.add(EmailMobileConnus);
        Lead SocieteTelConnus = new Lead(Salutation = 'M.', FirstName = 'Bazcal', LastName = 'Zuber', SIRET__c = '31344761700116', Company = 'Test account', Status = 'Ouverte', Code_NAF__c = NAF.Id, Phone = '+33111111111', MobilePhone = '+33654321098', Email = 'zedric@testacc.com');
        TestList.add(SocieteTelConnus);
        Lead SocieteMobileConnus = new Lead(Salutation = 'Mme', FirstName = 'Magdalena', LastName = 'Zuberra', SIRET__c = '32277006600015', Company = 'Test account', Status = 'Ouverte', Code_NAF__c = NAF.Id, Phone = '+33333333333', MobilePhone = '+33777777777', Email = 'magda@lena.com');
        TestList.add(SocieteMobileConnus);
        Lead SocieteEmailConnus = new Lead(Salutation = 'Mme', FirstName = 'Sofia', LastName = 'Goyas', SIRET__c = '33070384400036', Company = 'Test account', Status = 'Ouverte', Code_NAF__c = NAF.Id, Phone = '+33122334455', MobilePhone = '+33677889900', Email = 'pcarpe@gmail.com');
        TestList.add(SocieteEmailConnus);
        Lead SocieteTelVide = new Lead(Salutation = 'Mme', FirstName = 'Leila', LastName = 'Buaifella', SIRET__c = '50975221800024', Company = 'Test account', Status = 'Ouverte', Code_NAF__c = NAF.Id, Email = 'buaifella@testacc.com', MobilePhone = '+33611335577');
        TestList.add(SocieteTelVide);
        Lead Multi = new Lead(Salutation = 'M.', FirstName = 'Javier', LastName = 'Templetos', SIRET__c = '57202866000072', Company = 'Test account', Status = 'Ouverte', Code_NAF__c = NAF.Id, Email = 'pcarpe@gmail.com', Phone = '+33455667788');
        TestList.add(Multi);
        
        insert TestList;
        
        /*Lead lSIRETinconnu = [SELECT Id, Doublon__c, Type_de_doublon__c, Nombre_de_comptes_existants__c FROM Lead WHERE Id = :TestList[0].Id];
        Lead lSIRETconnu = [SELECT Id, Doublon__c, Type_de_doublon__c, Nombre_de_comptes_existants__c FROM Lead WHERE Id = :TestList[1].Id];
        Lead lEmailTelConnus = [SELECT Id, Doublon__c, Type_de_doublon__c, Nombre_de_comptes_existants__c FROM Lead WHERE Id = :TestList[2].Id];
        Lead lEmailMobileConnus = [SELECT Id, Doublon__c, Type_de_doublon__c, Nombre_de_comptes_existants__c FROM Lead WHERE Id = :TestList[3].Id];
        Lead lSocieteTelConnus = [SELECT Id, Doublon__c, Type_de_doublon__c, Nombre_de_comptes_existants__c FROM Lead WHERE Id = :TestList[4].Id];
        Lead lSocieteMobileConnus = [SELECT Id, Doublon__c, Type_de_doublon__c, Nombre_de_comptes_existants__c FROM Lead WHERE Id = :TestList[5].Id];
        Lead lSocieteEmailConnus = [SELECT Id, Doublon__c, Type_de_doublon__c, Nombre_de_comptes_existants__c FROM Lead WHERE Id = :TestList[6].Id];
        Lead lSocieteTelVide = [SELECT Id, Doublon__c, Type_de_doublon__c, Nombre_de_comptes_existants__c FROM Lead WHERE Id = :TestList[7].Id];
        Lead lMulti = [SELECT Id, Doublon__c, Type_de_doublon__c, Nombre_de_comptes_existants__c FROM Lead WHERE Id = :TestList[8].Id];*/
        
        /*Integer i = 0;
        for (Lead ld : TestList) {
            TestMapId.put(i,ld.id);
            i++;
        }*/
        for (Lead ld : TestList) {TestListId.add(ld.id);}
        List<Lead> lTestList = [SELECT Id, FirstName, Doublon__c, Type_de_doublon__c, Nombre_de_comptes_existants__c FROM Lead WHERE Id IN :TestListId];
        
        
        /*Lead DoublonParfait = new Lead(Salutation = 'Mme', FirstName = 'Zuzanne', LastName = 'Zuber', SIRET__c = '48193694600013', Company = 'Zuber Eats', Status = 'Ouverte', Code_NAF__c = NAF.Id, Phone = '+33111111111', MobilePhone = '+33666666666', Email = 'pcarpe@gmail.com');
        insert DoublonParfait;
        DoublonParfait.piste_qualifiee__c = true;
        update DoublonParfait;*/
        
        System.assert(lTestList.get(0).Doublon__c == null);
        System.assert(lTestList.get(0).Type_de_doublon__c == null);
        ////System.debug('Banane Nombre de comptes existants = ' + SIRETinconnu.Nombre_de_comptes_existants__c);
        System.assert(lTestList.get(0).Nombre_de_comptes_existants__c == 0);
        ////System.debug('Cerise Doublon ID = ' + SIRETconnu.Doublon__c);
        ////System.debug('Mangue Doublon Name = ' + SIRETconnu.Doublon__r.Name);
        ////System.debug('Nefle Nombre de comptes existants = ' + SIRETconnu.Nombre_de_comptes_existants__c);
        //System.debug('Raisin Prenom premier lead = ' + lTestList[0].FirstName);
        System.assert(lTestList.get(1).Doublon__c == compte.id);
        System.assert(lTestList.get(1).Type_de_doublon__c == 'SIRET');
        System.assert(lTestList.get(1).Nombre_de_comptes_existants__c > 0);
        System.assert(lTestList.get(2).Doublon__c == compte.id);
        System.assert(lTestList.get(2).Type_de_doublon__c == 'Email&Tel');
        System.assert(lTestList.get(2).Nombre_de_comptes_existants__c > 0);
        System.assert(lTestList.get(3).Doublon__c== compte.id);
        System.assert(lTestList.get(3).Type_de_doublon__c == 'Email&Mobile');
        System.assert(lTestList.get(3).Nombre_de_comptes_existants__c > 0);
        System.assert(lTestList.get(4).Doublon__c == compte.id);
        System.assert(lTestList.get(4).Type_de_doublon__c == 'Société&Tel');
        System.assert(lTestList.get(4).Nombre_de_comptes_existants__c > 0);
        System.assert(lTestList.get(5).Doublon__c == compte.id);
        System.assert(lTestList.get(5).Type_de_doublon__c == 'Société&Mobile');
        System.assert(lTestList.get(5).Nombre_de_comptes_existants__c > 0);
        //System.debug('Prune Doublon ID = ' + lSocieteEmailConnus.Doublon__c);
        System.assert(lTestList.get(6).Doublon__c == compte.id);
        System.assert(lTestList.get(6).Type_de_doublon__c == 'Email&Société');
        System.assert(lTestList.get(6).Nombre_de_comptes_existants__c > 0);
        System.assert(lTestList.get(7).Doublon__c == compte.id || lTestList.get(7).Doublon__c == compteBis.id);
        System.assert(lTestList.get(7).Type_de_doublon__c == 'Société&Tel');
        System.assert(lTestList.get(7).Nombre_de_comptes_existants__c > 0);
        System.assert(lTestList.get(8).Doublon__c == compte.id || lTestList.get(8).Doublon__c == compteBis.id);
        System.assert(lTestList.get(8).Type_de_doublon__c == 'Société&Tel' || lTestList[7].Type_de_doublon__c == 'Société&Email');
        System.assert(lTestList.get(8).Nombre_de_comptes_existants__c > 0);
        
        //TestList.get(0).piste_qualifiee__c = true;
        TestList.get(0).Bypass_Validation_Rule__c = true;
        TestList.get(0).Status = 'Qualifiée';
        update TestList.get(0);
        VFC_Extension_Lead extLead = new VFC_Extension_Lead(new ApexPages.StandardController(TestList.get(1)));
        extLead.fillCountry();
        
        
        /*Lead SIRETinconnu = new Lead(Salutation = 'M.', FirstName = 'Pierrot', LastName = 'Carpe', SIRET__c = '12345678900001', Company = 'B&D', Status = 'Ouverte');
        insert SIRETinconnu;
        SIRETinconnu.piste_qualifiee__c = true;
        update SIRETinconnu;*/
        
	}

}