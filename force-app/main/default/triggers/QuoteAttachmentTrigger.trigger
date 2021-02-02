//Trigger updated by Leila BOUAIFEL le 15/04/2019 to get Attachment PDF Id in the quote
trigger QuoteAttachmentTrigger on Attachment (before insert, after insert, after update, before update) {

    if (Trigger.isBefore && Trigger.isInsert) { 
    for(Attachment att : trigger.New)
	{
         //Check if added attachment is related to Quote or not
         if(att.ParentId.getSobjectType() == zqu__Quote__c.SobjectType)
		 {
			//get the attachment number of the Quote 	
              Integer nbrQuoteAtts=[select count() from attachment where parentid=:att.ParentId];
         	   if(nbrQuoteAtts != null && nbrQuoteAtts !=0)
            	{
            	 att.addError('Une pièce jointe est déjà existante pour cette Proposition');
            	}
                       
         }
     }
  }
/*
//get the attachment Id in the Quote
    	
   Set <Id> QuotesIds = new set <Id>();
    
      for (Attachment Attach: Trigger.new) { 
           QuotesIds.add(Attach.ParentId); system.debug('xxxxAttach.ParentId' +Attach.ParentId);  
      }
    
      if (Trigger.isAfter && Trigger.isInsert) {         
        
          
       Map<Id, zqu__Quote__c> QuotesMap = new Map<Id, zqu__Quote__c>([SELECT Id,Id_de_la_piece_jointe__c from zqu__Quote__c Where Type__c = 'Création de souscription' and Id in: QuotesIds]);
        List <zqu__Quote__c> QuoteList = new List <zqu__Quote__c>();
          
          for (Attachment Attach : trigger.new){
            
            zqu__Quote__c Qte = QuotesMap.get(Attach.ParentId); 
             	 					            
              Qte.Id_de_la_piece_jointe__c = Attach.Id;
              QuoteList.add(Qte);  
             
          }
          if (QuoteList.size() > 0) {
         	Update QuoteList;
           }     
    } */

}