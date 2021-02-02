/**
 * @File Name          : Fraicheur_test.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 5/20/2020, 9:30:25 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/20/2020   Hassan Dakhcha     Initial Version
**/
@isTest
public without sharing class Fraicheur_test {

	@isTest
	public static void Test_fraicheur() {
		// Créer un compte pro
        ID RTComptePro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1].Id; 
        ID RTCodePostal = [SELECT Id FROM RecordType WHERE DeveloperName = 'CP_Ville' LIMIT 1].Id;
        ID RTNAF = [SELECT Id FROM RecordType WHERE DeveloperName = 'NAF_Libelle' LIMIT 1].Id;
        ID RTPays = [SELECT Id FROM RecordType WHERE DeveloperName = 'Pays' LIMIT 1].Id;

        Reference__c CP = new Reference__c(RecordTypeId = RTCodePostal, Code__c = '75001', Name = 'Paris');
        insert CP;
        
        Reference__c NAF = new Reference__c(RecordTypeId = RTNAF, Code__c = 'AAA', Name = 'Activite');
        insert NAF;
        
        Reference__c FR = new Reference__c(RecordTypeId = RTPays, Name = 'France', key__c = 'FRA');
        insert FR;
        
        Account compte = new Account(RecordTypeId = RTComptePro, Name = 'Test account', SIRET_texte__c = '32212091600208', Phone = '+33635136116', 
                                         Pays_LKP__c = FR.id, Code_postal__c = CP.Id, 
                                        Code_NAF_APE_societe_declarante__c = NAF.Id, A_ne_jamais_rappeler__c = false);
        insert compte; 
     

// Creer un compte particulier pour le projet
        Account Part = new Account(LastName= 'Test',
                                          FirstName= 'Compte',
                                          RecordTypeId = TestFactory.RTComptePart,
                                          Statut__c= 'Actif', 
                                          Code_postal__c= TestFactory.createReference('CP', '91070', '91070_91086', 'BONDOUFLE').Id,
                                          Pays_LKP__c= TestFactory.createReference('pays', 'France', 'FRA', 'France').Id,
                                          PersonMobilePhone= '+33240768765',
                                          Phone = '+33240768765',
                                          PersonEmail='toto@gmail.com');
        
        insert Part;
        
        Integer minute_tmp = Datetime.now().minute();
        Integer minute_calculated = (minute_tmp/15) * 15;
        
        Datetime d_before = Datetime.newInstance(Datetime.now().year(),
                                                    Datetime.now().month(),
                                                    Datetime.now().day(),
                                                    Datetime.now().hour(),
                                                    minute_calculated,
                                                    0);
        Datetime d_after = Datetime.newInstance(Datetime.now().year(),
                                                    Datetime.now().month(),
                                                    Datetime.now().day(),
                                                    (minute_calculated != 45 ? Datetime.now().hour() : Datetime.now().hour() + 1),
                                                    (minute_calculated != 45 ? minute_calculated + 15 : 0),
                                                    0);

//Créer un définition de créneau
       Def_Creneau__c DefName = new  Def_Creneau__c( Heure_Debut__c = '08h00', Jour_de_la_semaine__c ='Lundi');
        insert DefName;        
        
//Créer un créneau
        Creneau__c creneau = new Creneau__c (Reference_du_Creneau__c = DefName.id, Reservations__c = 1, Date_Horaire__c = d_before, Quota__c = 2, Groupe_Odigo__c = 'Accueil Client Part.');
        insert creneau; 
		

//Créer un projet affilié à Part et l'insert
        Projet__c projet = new Projet__c(Titre__c = 'projet test',
                                              Particulier__c= Part.Id,
                                              Categorie_lkp__c= TestFactory.createReference('categorie', 'Aménagement de combles', '1013', 'Aménagement de combles').Id,
                                              Code_postal__c= TestFactory.createReference('CP', '92140', '92140_92023', 'CLAMART').Id,
                                              Description__c='description test youhou',
                                              Statut_Projet__c='Nouveau',
                                              Demande_Part_Origine__c='Artisans qualifiés');
        
        insert projet;

        creneau.Reservations__c = 2;
        update creneau;

        Projet__c projet2 = new Projet__c(Titre__c = 'projet test',
                                             Particulier__c= Part.Id,
                                              Categorie_lkp__c= TestFactory.createReference('categorie', 'Aménagement de combles', '1013', 'Aménagement de combles').Id,
                                              Code_postal__c= TestFactory.createReference('CP', '92140', '92140_92023', 'CLAMART').Id,
                                              Description__c='description test youhou',
                                              Statut_Projet__c='Nouveau',
                                              Demande_Part_Origine__c='Artisans qualifiés');
		insert projet2;
	}
}