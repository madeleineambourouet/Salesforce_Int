/**
 * @File Name          : GetDeletedRecords.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 4/26/2020, 2:51:51 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/26/2020   Hassan Dakhcha     Initial Version
**/
public class GetDeletedRecords 
{
     
        public static void getRecordsZuora(){
            //Zuora__SubscriptionProductCharge__c
            //List <Zuora__SubscriptionProductCharge__c> DeletedZuoraSubscriptionProductCharges = [SELECT id, lastmodifieddate FROM Zuora__SubscriptionProductCharge__c WHERE IsDeleted = true ALL ROWS ];
            List <Zuora__SubscriptionProductCharge__c> DeletedZuoraSubscriptionProductCharges = Trigger.old;
            System.debug('Number of Zuora__SubscriptionProductCharge__c deleted : ' + (Trigger.old).size());
            System.debug('Number of ItemDeleted__c going to create : ' + DeletedZuoraSubscriptionProductCharges.size());

            if (DeletedZuoraSubscriptionProductCharges.size()!=NULL){
                try{
                    List<ItemDeleted__c> lstItemDeleted = new List<ItemDeleted__c>();
                    for (Zuora__SubscriptionProductCharge__c DeletedZuoraSubscriptionProductCharge : DeletedZuoraSubscriptionProductCharges ){
                       System.debug('Attempting to insert fields id : ' + DeletedZuoraSubscriptionProductCharge.id);
                       ItemDeleted__c deletedItem = new ItemDeleted__c( Name= 'Zuora__SubscriptionProductCharge__c',
                                                                        Deleted_ID__c = DeletedZuoraSubscriptionProductCharge.id,
                                                                        Deleted_Date__c = DeletedZuoraSubscriptionProductCharge.lastmodifieddate);
                    
                        lstItemDeleted.add(deletedItem);
                    }
                     
                    insert lstItemDeleted;
                } catch (System.DmlException e){
                    System.debug('We caught a DML exception: ' + e.getDmlMessage(0));
                }
            }
        }
        public static void getRecordsAccount(){
            //Account
            //List <Account> DeletedAccounts = [SELECT id, lastmodifieddate FROM account WHERE IsDeleted = true ALL ROWS ];
			List <Account> DeletedAccounts = Trigger.old;
            System.debug('Number of Account deleted : ' + (Trigger.old).size());
            System.debug('Number of ItemDeleted__c going to create : ' + DeletedAccounts.size());

            if (DeletedAccounts.size()!=NULL){
                try{
                    System.debug('Attempting to insert fields');
                    List<ItemDeleted__c> deletedItemsList = new List<ItemDeleted__c>();
                    for (Account DeletedAccount : DeletedAccounts ){
                               deletedItemsList.add(new ItemDeleted__c( Name= 'Account',
                                                                                Deleted_ID__c = DeletedAccount.id,
                                                                                Deleted_Date__c = DeletedAccount.lastmodifieddate));
                    }
                    insert deletedItemsList;
                System.debug('Finish insert fields');
                } catch (System.DmlException e){
                    System.debug('We caught a DML exception: ' + e.getDmlMessage(0));
                }
            }
      }
      public static void getRecordsContact(){      
        // Contact
            //List <Contact> DeletedContacts = [SELECT id, lastmodifieddate FROM Contact WHERE IsDeleted = true ALL ROWS ];
			List <Contact> DeletedContacts = Trigger.old;
            System.debug('Number of Contact deleted : ' + (Trigger.old).size());
            System.debug('Number of ItemDeleted__c going to create : ' + DeletedContacts.size());

            if (DeletedContacts.size()!=NULL){
                try{
                    System.debug('Attempting to insert fields');
                    List<ItemDeleted__c> deletedItemsList = new List<ItemDeleted__c>();
                    for (Contact DeletedContact : DeletedContacts ){
                               deletedItemsList.add(new ItemDeleted__c( Name= 'Contact',
                                                                                Deleted_ID__c = DeletedContact.id,
                                                                                Deleted_Date__c = DeletedContact.lastmodifieddate));
                    }
                    insert deletedItemsList;
                System.debug('Finish insert fields');
                } catch (System.DmlException e){
                    System.debug('We caught a DML exception: ' + e.getDmlMessage(0));
                }
            }
      }
      public static void getRecordsDocAssurance(){      
            //Document_Assurance__c
            //List <Document_Assurance__c> DeletedAssurances = [SELECT id, lastmodifieddate FROM Document_Assurance__c WHERE IsDeleted = true ALL ROWS ];
			List <Document_Assurance__c> DeletedAssurances = Trigger.old;
            System.debug('Number of Document_Assurance__c deleted : ' + (Trigger.old).size());
            System.debug('Number of ItemDeleted__c going to create : ' + DeletedAssurances.size());

            if (DeletedAssurances.size()!=NULL){
                try{
                    System.debug('Attempting to insert fields');
                    List<ItemDeleted__c> deletedItemsList = new List<ItemDeleted__c>();
                    for (Document_Assurance__c DeletedAssurance : DeletedAssurances ){
                               deletedItemsList.add(new ItemDeleted__c( Name= 'Document_Assurance__c',
                                                                                Deleted_ID__c = DeletedAssurance.id,
                                                                                Deleted_Date__c = DeletedAssurance.lastmodifieddate));
                    }
                    insert deletedItemsList;
                    System.debug('Finish insert fields');
                } catch (System.DmlException e){
                    System.debug('We caught a DML exception: ' + e.getDmlMessage(0));
                }
            }
      }
      public static void getRecordsDocCertf(){      
            //Document_Certification__c
            //List <Document_Certification__c> DeletedCertifications = [SELECT id, lastmodifieddate FROM Document_Certification__c WHERE IsDeleted = true ALL ROWS ];
			List <Document_Certification__c> DeletedCertifications = Trigger.old;
            System.debug('Number of Document_Certification__c deleted : ' + (Trigger.old).size());
            System.debug('Number of ItemDeleted__c going to create : ' + DeletedCertifications.size());

            if (DeletedCertifications.size()!=NULL){
                try{
                    System.debug('Attempting to insert fields');
                    List<ItemDeleted__c> deletedItemsList = new List<ItemDeleted__c>();
                    for (Document_Certification__c DeletedCertification : DeletedCertifications ){
                               deletedItemsList.add(new ItemDeleted__c( Name= 'Document_Certification__c',
                                                                                Deleted_ID__c = DeletedCertification.id,
                                                                                Deleted_Date__c = DeletedCertification.lastmodifieddate));
                    }
                    insert deletedItemsList;
                    System.debug('Finish insert fields');
                } catch (System.DmlException e){
                    System.debug('We caught a DML exception: ' + e.getDmlMessage(0));
                }
            }
       }     
       public static void getRecordsGeoCat(){
            //GeoCat__c
            //List <GeoCat__c> DeletedGeoCats = [SELECT id, lastmodifieddate FROM GeoCat__c WHERE IsDeleted = true ALL ROWS ];
			List <GeoCat__c> DeletedGeoCats = Trigger.old;
            System.debug('Number of GeoCat__c deleted : ' + (Trigger.old).size());
            System.debug('Number of ItemDeleted__c going to create : ' + DeletedGeoCats.size());


            if (DeletedGeoCats.size()!=NULL){
                try{
                    System.debug('Attempting to insert fields');
                    List<ItemDeleted__c> deletedItemsList = new List<ItemDeleted__c>();
                    for (GeoCat__c DeletedGeoCat : DeletedGeoCats ){
                               deletedItemsList.add(new ItemDeleted__c( Name= 'GeoCat__c',
                                                                                Deleted_ID__c = DeletedGeoCat.id,
                                                                                Deleted_Date__c = DeletedGeoCat.lastmodifieddate));
                    }
                    insert deletedItemsList;
                System.debug('Finish insert fields');
                } catch (System.DmlException e){
                    System.debug('We caught a DML exception: ' + e.getDmlMessage(0));
                }
            }
        }
        public static void getRecordsCompetences(){    
            //Competence__c
            //List <Competence__c> DeletedCompetences = [SELECT id, lastmodifieddate FROM Competence__c WHERE IsDeleted = true ALL ROWS ];
            List <Competence__c> DeletedCompetences = Trigger.old;
            System.debug('Number of Competence__c deleted : ' + (Trigger.old).size());
            System.debug('Number of ItemDeleted__c going to create : ' + DeletedCompetences.size());
            
            if (DeletedCompetences.size()!=NULL){
                try{
                    System.debug('Attempting to insert fields');
                    List<ItemDeleted__c> lstItemDeleted = new List<ItemDeleted__c>();
                    for (Competence__c DeletedCompetence : DeletedCompetences ){
                               ItemDeleted__c deletedItem = new ItemDeleted__c( Name= 'Competence__c',
                                                                                Deleted_ID__c = DeletedCompetence.id,
                                                                                Deleted_Date__c = DeletedCompetence.lastmodifieddate);
                               lstItemDeleted.add(deletedItem);
                    }
                     
                    insert lstItemDeleted;
                    
                System.debug('Finish insert fields');
                } catch (System.DmlException e){
                    System.debug('We caught a DML exception: ' + e.getDmlMessage(0));
                }
            }
       }

       public static void getRecordsProjet(){
            //Projet__c
            //List <Projet__c> DeletedProjets = [SELECT id, lastmodifieddate FROM Projet__c WHERE IsDeleted = true ALL ROWS ];
			List <Projet__c> DeletedProjets = Trigger.old;
            System.debug('Number of Projet__c deleted : ' + (Trigger.old).size());
            System.debug('Number of ItemDeleted__c going to create : ' + DeletedProjets.size());

            if (DeletedProjets.size()!=NULL){
                try{
                    System.debug('Attempting to insert fields');
                    List<ItemDeleted__c> deletedItemsList = new List<ItemDeleted__c>();
                    for (Projet__c DeletedProjet : DeletedProjets ){
                               deletedItemsList.add(new ItemDeleted__c( Name= 'Projet__c',
                                                                                Deleted_ID__c = DeletedProjet.id,
                                                                                Deleted_Date__c = DeletedProjet.lastmodifieddate));
                    }
                    insert deletedItemsList;
                System.debug('Finish insert fields');
                } catch (System.DmlException e){
                    System.debug('We caught a DML exception: ' + e.getDmlMessage(0));
                }
            }
       } 
       public static void getRecordsIntermed(){ 
            //Intermediation__c
            //List <Intermediation__c> DeletedIntermediations = [SELECT id, lastmodifieddate FROM Intermediation__c WHERE IsDeleted = true ALL ROWS ];
			List <Intermediation__c> DeletedIntermediations = Trigger.old;
            System.debug('Number of Intermediation__c deleted : ' + (Trigger.old).size());
            System.debug('Number of ItemDeleted__c going to create : ' + DeletedIntermediations.size());
            
            if (DeletedIntermediations.size()!=NULL){
                try{
                    System.debug('Attempting to insert fields');
                    List<ItemDeleted__c> lstItemDeleted = new List<ItemDeleted__c>();
                    for (Intermediation__c DeletedIntermediation : DeletedIntermediations ){
                               ItemDeleted__c deletedItem = new ItemDeleted__c( Name= 'Intermediation__c',
                                                                                Deleted_ID__c = DeletedIntermediation.id,
                                                                                Deleted_Date__c = DeletedIntermediation.lastmodifieddate);
                               lstItemDeleted.add(deletedItem);
                    }
                     
                    insert lstItemDeleted;
                    
                System.debug('Finish insert fields');
                } catch (System.DmlException e){
                    System.debug('We caught a DML exception: ' + e.getDmlMessage(0));
                }
            }
        }   
}