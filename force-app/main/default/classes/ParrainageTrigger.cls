public without sharing class ParrainageTrigger {

	public static void checkActifProbis(List<Zuora__Subscription__c> zqu_sub, Map<Id, Zuora__Subscription__c> zqu_sub_oldmap) {
        OrgWideEmailAddress oa = [SELECT Address, IsAllowAllProfiles, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, CreatedById, Id, DisplayName FROM OrgWideEmailAddress WHERE Address LIKE 'services%' AND DisplayName LIKE 'Homly%' LIMIT 1];
        List<Account> accs = new List<Account>();
        List<Id> idsAcc = new List<Id>();
        Date d1 = Date.today();

        // Récupération ID compte désincrit
        for (Zuora__Subscription__c z : zqu_sub) {
            if (z.Zuora__Status__c == 'Cancelled' && zqu_sub_oldmap.get(z.Id).Zuora__Status__c != z.Zuora__Status__c && z.Zuora__SubscriptionEndDate__c != null && z.Zuora__SubscriptionEndDate__c >= d1) {
                idsAcc.add(z.Zuora__Account__c);
            }
        }
        // Fin Récupération

        // Invalidation du filleul si Désinscription parrain

        for (Account a : [SELECT Id, Remise_consommee__c FROM Account WHERE Parrain__c IN :idsAcc AND Remise_consommee__c = null]) {
            a.Remise_consommee__c = 'Invalide';
            accs.add(a);
        }


        // Fin Invalidation filleul si désincription parrain

        // Invalidation filleul apres desinscription 
        Map<Id, Account> accFill = new Map<Id, Account>([SELECT Id, Parrain__r.Contact_principal__c, Parrain__r.Contact_principal__r.Name, Parrain__r.Contact_principal__r.Email,  Contact_principal__r.Name, Name FROM Account WHERE Id IN :idsAcc AND Parrain__c != null AND Remise_consommee__c = null]);
        
        if (accFill.size() > 0) {

            for (Zuora__Subscription__c z : zqu_sub) {
                if (z.Zuora__Status__c == 'Cancelled' && z.Zuora__SubscriptionEndDate__c != null && accFill.containsKey(z.Zuora__Account__c)) {
                    Date dateLimit = z.Zuora__SubscriptionStartDate__c.addMonths(1);
                    if (z.Zuora__SubscriptionEndDate__c < dateLimit) {
                        accFill.get(z.Zuora__Account__c).Remise_consommee__c = 'Invalide';
                        accs.add(accFill.get(z.Zuora__Account__c));

                        /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new String[] {accFill.get(z.Zuora__Account__c).Parrain__r.Contact_principal__r.Email});
                        mail.setSubject('Homly You : des nouvelles de votre parrainage');
                        mail.setBccSender(false);
                        mail.setHtmlBody(MailHelper.PARRAINAGE_maildesinscrit(accFill.get(z.Zuora__Account__c).Parrain__r.Contact_principal__r.Name, accFill.get(z.Zuora__Account__c).Contact_principal__r.Name, accFill.get(z.Zuora__Account__c).Name));
                        mail.setTargetObjectId(accFill.get(z.Zuora__Account__c).Parrain__r.Contact_principal__c);
                        mail.setSaveAsActivity(true);
                        mail.setOrgWideEmailAddressId(oa.Id);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});*/
                    }
                }
            }
        }
        
        update accs;



        // récupération parrain cancelled    

    }

    public static String beGodSon(List<Account> accs, Map<Id, Account> oldAccs, Boolean isInsert) {
        Account fill;
        Account parrain;

        if (accs.size() == 1) {
            for (Account a : accs) {

                fill = a;
            }

            
            if (!isInsert &&
                fill.Parrain__c != oldAccs.get(fill.Id).Parrain__c &&
                fill.Premiere_souscription__c != null) {
                return 'Ce filleul a déjà un parrain, vous ne pouvez pas le modifier. Contactez votre administrateur pour plus d\'information.';
            }
            system.debug('Avant Conditions');
            system.debug('fill.Parrain__c = ' + fill.Parrain__c);
            system.debug('isInsert = ' + isInsert);

            if (!isInsert)
                system.debug('oldAccs.get(fill.Id).Parrain__c = ' + oldAccs.get(fill.Id).Parrain__c);


            if ( (fill.Parrain__c != null && isInsert) ||
                (fill.Parrain__c != null && fill.Parrain__c != oldAccs.get(fill.Id).Parrain__c && oldAccs.get(fill.Id).Parrain__c == null) ) {
                
                system.debug('Conditions remplies');
            	for (Account a : [SELECT Id, Contact_principal__c, Contact_principal__r.Name, Contact_principal__r.Email FROM Account WHERE Id = :fill.Parrain__c  AND Statut_de_paiement__c = null LIMIT 1])
            		parrain = a;

            	if (parrain == null)
            		return 'Un impayé sur le parrain empêche le rattachement.';

                if ([SELECT Id FROM Zuora__Subscription__c WHERE Zuora__Account__c = :parrain.Id AND (Zuora__Status__c = 'Active' OR Zuora__Status__c = 'Pending Activation')].size() == 0) {
                    return 'Vous ne pouvez pas rattacher ce parrain à ce compte.';
                }

                if ([SELECT Id FROM Zuora__Subscription__c WHERE Zuora__Account__c = :fill.Id AND (Zuora__Status__c = 'Active' OR Zuora__Status__c = 'Pending Activation')].size() != 0) {
                    return 'Vous ne pouvez pas rattacher de parrain à ce compte.';
                }

                Date d = Date.today().addMonths(-1);

                List<Zuora__Subscription__c> subActiv = [SELECT Id FROM Zuora__Subscription__c WHERE Zuora__Account__c = :fill.Id AND Zuora__SubscriptionEndDate__c = null];
                List<Zuora__Subscription__c> sub1mois = [SELECT Id FROM Zuora__Subscription__c WHERE Zuora__Account__c = :fill.Id AND Zuora__SubscriptionEndDate__c >= :d ORDER BY Zuora__SubscriptionEndDate__c DESC LIMIT 1];

                if (subActiv.size() == 0 && sub1mois.size() != 0) {
                    return 'Le compte est résilié depuis moins de 3 mois, vous ne pouvez pas rattacher de parrain à ce compte.';
                }

                fill.Premiere_souscription__c = 'NEW';
                fill.Date_parrainnage__c = Date.today();
                List<Contact> fillcon = [SELECT Id, Name FROM Contact WHERE Id = :fill.contact_principal__c LIMIT 1];
                String fillconName = (fillcon.size() != 0 ? fillcon[0].Name : '');
                OrgWideEmailAddress oa = [SELECT Address, IsAllowAllProfiles, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, CreatedById, Id, DisplayName FROM OrgWideEmailAddress WHERE Address LIKE 'services%' AND DisplayName LIKE 'Homly%' LIMIT 1];
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] {parrain.Contact_principal__r.Email});
                mail.setSubject('Homly You : merci pour votre parrainage');
                mail.setBccSender(false);
                mail.setHtmlBody(MailHelper.PARRAINAGE_mailremerciement(parrain.Contact_principal__r.Name, fillconName, fill.Name));
                mail.setTargetObjectId(parrain.Contact_principal__c);
                mail.setSaveAsActivity(true);
                mail.setOrgWideEmailAddressId(oa.Id);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            }
        }
        return null;
    }

    public static void subscribeGodSon(List<Zuora__Subscription__c> zqu_sub) {
        
        List<Id> ids = new List<Id>();
        List<Account> accs = new  List<Account>();
        OrgWideEmailAddress oa = [SELECT Address, IsAllowAllProfiles, CreatedDate, LastModifiedDate, LastModifiedById, SystemModstamp, CreatedById, Id, DisplayName FROM OrgWideEmailAddress WHERE Address LIKE 'services%' AND DisplayName LIKE 'Homly%' LIMIT 1];
        
        for (Zuora__Subscription__c z : zqu_sub) {
            if (z.Zuora__Status__c == 'Active') {
                ids.add(z.Zuora__Account__c);
            }
        }

        List<Account> fill = [SELECT Id, contact_principal__c, contact_principal__r.Name, Parrain__r.contact_principal__c, Parrain__r.contact_principal__r.Name, Parrain__r.contact_principal__r.Email, Name FROM Account WHERE Id IN :ids AND Premiere_souscription__c = 'NEW' AND Parrain__c != null];

        for (Account a : fill) {
                a.Premiere_souscription__c = 'OLD';
                //
                /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] {a.Parrain__r.Contact_principal__r.Email});
                mail.setSubject('Homly You : votre filleul s\'est inscrit');
                mail.setBccSender(false);
                mail.setHtmlBody(MailHelper.PARRAINAGE_mailinscrit(a.Parrain__r.contact_principal__r.Name, a.contact_principal__r.Name, a.Name));
                mail.setTargetObjectId(a.Parrain__r.contact_principal__c);
                mail.setSaveAsActivity(true);
                mail.setOrgWideEmailAddressId(oa.Id);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});*/
                accs.add(a);
            }
        if (accs.size() > 0) {
            update accs;
        }

     }
}