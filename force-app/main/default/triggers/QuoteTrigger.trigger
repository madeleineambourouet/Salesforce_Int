/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 10-30-2020
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   10-22-2020   Hassan Dakhcha   Initial Version
**/
//
// 21/07/2017, Modified by Qiuyan Liu, EB114, call QuoteMethods.checkRTPostResiliation change the quote to Post Résiliation record type if needed
// xx/xx/2018, Modified by ??, Refonte des offres 
// 07/02/2018, Modified by Xavier Templet, assign manager field 
//20/03/2019, Modified by Leila Bouaifel, ajout du remplissage du TC référent sur le compte pro qui se base sur le TC référent binome

trigger QuoteTrigger on zqu__Quote__c (before insert, before update) 
{
    
    ID RTCreationQuote = [SELECT id FROM RecordType WHERE DeveloperName = 'Default' AND SObjectType = 'zqu__Quote__c' LIMIT 1].id;
    ID RTCreationQuoteReadOnly = [SELECT id FROM RecordType WHERE DeveloperName = 'ReadOnly' AND SObjectType = 'zqu__Quote__c' LIMIT 1].id;
    
    
    // BEFORE INSERT
    if (trigger.isBefore && trigger.isInsert)
    { 
        // Check if an intermediation offer is attached
        QuoteMethods.calculateIfIntermediationOffer(trigger.new);
    }
    
    
    // BEFORE UPDATE
    if (trigger.isUpdate && trigger.isbefore)
    {
        List<user> userLst = [select Id, ManagerID from user where IsActive = true];
        Map<Id,Id> Owner2Manager = new Map<Id,Id>();
        for (user u : userLst) Owner2Manager.put(u.Id, u.ManagerID);

        List<zqu__Quote__c> QuoLst4SalesFact = new List<zqu__Quote__c>();
        
        for (zqu__Quote__c uQuote : Trigger.new){

            if (Trigger.oldMap.get(uQuote.id).zqu__Status__c != uQuote.zqu__Status__c && uQuote.zqu__Status__c == 'New') {
                if (Owner2Manager.containsKey(uQuote.ownerID)) uQuote.Manager__c = Owner2Manager.get(uQuote.ownerID);

                //&& quo.RecordTypeName__c == 'Amendment' 
                if (uQuote.IsDeleted == false && uQuote.Type_de_geste__c == 'Modification de souscription') QuoLst4SalesFact.add(uQuote);
            }

            if (Trigger.oldMap.get(uQuote.id).zqu__Status__c != uQuote.zqu__Status__c && uQuote.zqu__Status__c == 'New' && Owner2Manager.containsKey(uQuote.ownerID))
                 uQuote.Manager__c = Owner2Manager.get(uQuote.ownerID);

            if (Trigger.oldMap.get(uQuote.id).Envoi_mail_generate_PDF__c != Trigger.newMap.get(uQuote.id).Envoi_mail_generate_PDF__c
                && uQuote.Envoi_mail_generate_PDF__c == true) {
                    Account cpt = [SELECT id, login__c FROM Account WHERE id = :uQuote.zqu__Account__c LIMIT 1];
                    String qUrl = AccountMethods.generateToken(cpt.login__c,31,5, 'Quote');
                    uQuote.Last_generated_token__c = qUrl.substringAfter(Label.URL_web_pour_email); 
                    //uQuote.Envoi_mail_generate_PDF__c = false;
                }
            if (Trigger.oldMap.get(uQuote.id).Modification_offres__c != Trigger.newMap.get(uQuote.id).Modification_offres__c
                && uQuote.Modification_offres__c == true) {
                    Account cpt = [SELECT id, login__c FROM Account WHERE id = :uQuote.zqu__Account__c LIMIT 1];
                    String qUrl = AccountMethods.generateToken(cpt.login__c,31,5, 'Quote Modification');
                    uQuote.Last_generated_token__c = qUrl.substringAfter(Label.URL_web_pour_email); 
                } 
            if (Trigger.oldMap.get(uQuote.id).Resiliation_offres__c != Trigger.newMap.get(uQuote.id).Resiliation_offres__c
                && uQuote.Resiliation_offres__c == true) {
                    Account cpt = [SELECT id, login__c FROM Account WHERE id = :uQuote.zqu__Account__c LIMIT 1];
                    String qUrl = AccountMethods.generateToken(cpt.login__c,31,5, 'Quote Resiliation');
                    uQuote.Last_generated_token__c = qUrl.substringAfter(Label.URL_web_pour_email); 
                }
           
            if (Trigger.oldMap.get(uQuote.id).zqu__Status__c != Trigger.newMap.get(uQuote.id).zqu__Status__c && uQuote.zqu__Status__c == 'Sent to Z-Billing' && (uQuote.RecordTypeId == RTCreationQuote || uQuote.RecordTypeId == RTCreationQuoteReadOnly) && uQuote.Type_de_geste__c != 'Geste commercial post-résiliation') {
                    uQuote.RecordTypeId = RTCreationQuoteReadOnly;
                    String fullTitle = uQuote.Name + '_preview.pdf';
                    
                    List<Attachment> PJs = [SELECT id, Name, Body FROM Attachment WHERE Name = :fullTitle];
                    EmailTemplate template = [SELECT id FROM EmailTemplate WHERE DeveloperName = 'Proposition_validee' LIMIT 1];
                    OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address LIKE 'inscription%' AND DisplayName LIKE 'LMSG%' order by CreatedDate desc limit 1];
                    EmailHelper.sendQuoteByMail(template.ID, uQuote.zqu__SoldToContact__c, uQuote.ID, (PJs.size() > 0 ? PJs[0] : null), 'HY_Conditions_contractuelles.pdf', owea.ID);
                }
        }
        
        // Check if an intermediation offer is attached
        QuoteMethods.calculateIfIntermediationOffer(trigger.new);
        //Check amendment details
        QuoteMethods.AmendmentDetails(trigger.new);

        // related to Sales_Facts__c, eb164 - refonte des offres - sales incentives
        SalesFact_Methods.InsertSF_UpSell(QuoLst4SalesFact);
        
        
        //change the quote to Post Résiliation record type if needed
        QuoteMethods.checkRTPostResiliation(Trigger.new);
        
    }
    // remplir le owner sur le compte et le TC référent sur le compte
    QuoteMethods.updateAccountChargeClientele(Trigger.new);  
}