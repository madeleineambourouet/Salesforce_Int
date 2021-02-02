/**
 * @description       : 
 * @author            : Hassan Dakhcha
 * @group             : 
 * @last modified on  : 01-16-2021
 * @last modified by  : Hassan Dakhcha
 * Modifications Log 
 * Ver   Date         Author           Modification
 * 1.0   12-02-2020   Hassan Dakhcha   Initial Version
**/
public class MessagingSessionMethods {

    public static void updateRelationship(List<MessagingSession> newList) {
         // check if MS has MessaringUser :
        List<MessagingSession> msList = new List<MessagingSession>();
        Set<id> muSet = new Set<id>();
        Set<id> accSet = new Set<id>(); // ms endUserAccountId
        System.debug('****** updateRelationship');
        for(MessagingSession ms : newList) {
            System.debug('****** MS = ' +
            ms.ChannelEndUserFormula + ' ' +ms.Name + ' ' + ms.EndUserAccountId + ' ' +  ms.MessagingEndUserId + ' ' + 
            ms.EndUserContactId  + ' ' +  ms.MessagingEndUser.AccountId + ' ' +  ms.MessagingEndUser.ContactId + ' ' +  ms.Status + ' '
             + ms.Projet_LMSG__c + ' ' + ms.Projet_HY__c + ' ' + ms.origin);
            if(ms.MessagingEndUserId != null && ms.Projet_LMSG__c==null && ms.Projet_HY__c==null && ms.origin!='TriggeredOutbound') {
                accSet.add(ms.EndUserAccountId);
                muSet.add(ms.MessagingEndUserId);
                msList.add(ms);
            }
        }
        
        if(muSet.isEmpty())
            return;

        Map<id, MessagingEndUser> muMap = new Map<id, MessagingEndUser>([SELECT ID, ContactId, Contact.AccountId FROM MessagingEndUser WHERE id IN :muSet]);
        if(muMap.isEmpty())
            return;
        //Complete the accSet from the messagingUser (some MS may have null endUserAccountId):
        for(id mu : muMap.keySet()) {
            System.debug('****** MU = ' + muMap.get(mu).ContactId + ' ' + muMap.get(mu).Contact.AccountId);
            accSet.add(muMap.get(mu).Contact.AccountId);
        }

        Map<id, Account> clientMap = new Map<id, Account>([SELECT id, isPersonAccount FROM Account WHERE id=:accSet and isPersonAccount = true]);
        List<Projet_LMSG__c> ppList = [SELECT id, OwnerId, Code_postal__c, Code_postal__r.Key__c, Particulier__c, createdDate FROM Projet_LMSG__c 
                                            WHERE Particulier__c =:clientMap.keySet() ORDER BY createdDate];
        Map<id, Projet_LMSG__c> clientPrjLMSGMap = new Map<id, Projet_LMSG__c>();
        for(Projet_LMSG__c pp : ppList) {
            clientPrjLMSGMap.put(pp.Particulier__c, pp);
        }
        // Get projetHY for others
        Set<id> clientWithoutPP = new Set<id>(clientMap.keySet());
        clientWithoutPP.removeAll(clientPrjLMSGMap.keySet());
        List<Projet__c> pList = new List<Projet__c>();
        if(!clientWithoutPP.isEmpty()) {
            pList = [ SELECT id, Code_postal__c, Code_postal__r.Key__c, particulier__c, Statut_Projet__c FROM Projet__c 
                      WHERE particulier__c IN :clientWithoutPP /*AND Statut_Projet__c = 'Part NRP' AND Sous_statut__c = '1er appel' 'Faux Num'*/
                      ORDER BY createdDate];
        }
        Map<id, Projet__c> clientPrjHYMap = new Map<id, Projet__c>();
        for(Projet__c p : pList) {
            clientPrjHYMap.put(p.Particulier__c, p);
        }

        for(MessagingSession ms : msList) {
            Id client = ms.EndUserAccountId;
            if(client == null) {
                client = muMap.get(ms.MessagingEndUserId).Contact.AccountId;
            }

            if(client == null) {
                continue;
            }
            if(clientMap.get(client) != null) { // PersonAccount
                Projet_LMSG__c pp = clientPrjLMSGMap.get(client);
                Projet__c p = clientPrjHYMap.get(client);

                ms.Projet_LMSG__c = pp == null? null : pp.id;
                ms.Projet_HY__c = p == null? null : p.id;
                ms.Project_Owner__c = pp == null? null : pp.OwnerId;
                ms.Account__c = client;
                String zoneKey = null;
                if(pp!=null && pp.Code_postal__c!=null) {
                    zoneKey = pp.Code_postal__r.Key__c.left(2);
                } else if (p!=null && p.Code_postal__c!=null) {
                    zoneKey = p.Code_postal__r.Key__c.left(2);
                }
                ms.Zone__c = (zoneKey!=null && zoneKey!='') ? ProjectZoneMap.get(zoneKey) : null;
            } else {
                ms.Account__c = client;
            }
        }
    }
   
    // Called before insert
    public static void updateMSInboundType(List<MessagingSession> newList) {
        Set<id> muSet = new Set<id>();
        Set<MessagingSession> inboundMsList = new Set<MessagingSession>();
        for(MessagingSession ms : newList) {
            if(ms.origin=='InboundInitiated') {
                inboundMsList.add(ms);
                muSet.add(ms.MessagingEndUserId);
            }
        }
        if(!muSet.isEmpty()) {
            // get the latest outbound messaging session :
            List<MessagingSession> triggeredMS = [SELECT id, type__c, MessagingEndUserId, Date_retour_client__c, createdDate FROM MessagingSession 
                                                  WHERE origin ='TriggeredOutbound'  AND MessagingEndUserId IN :muSet ORDER BY createdDate];
            Map<id, MessagingSession> muMsMap = new Map<id, MessagingSession> ();
            for(MessagingSession ms : triggeredMS) {
                muMsMap.put(ms.MessagingEndUserId, ms);
            }
            if(!muMsMap.isEmpty()) {
                List<MessagingSession> updateRespTime = new List<MessagingSession>();
                for(MessagingSession ms : inboundMsList) {
                    MessagingSession outboundMs = muMsMap.get(ms.MessagingEndUserId);
                    if(outboundMs==null) {
                        ms.type__c = 'client_init';
                        continue;
                    }

                    if(outboundMs.type__c == 'nrp_hy')
                        ms.type__c = 'resp_nrp_hy';
                    if(outboundMs.type__c == 'nrp_lmsg')
                        ms.type__c = 'resp_nrp_lmsg';
                    if(outboundMs.type__c == 'ar_lmsg')
                        ms.type__c = 'resp_ar_lmsg';
                    if(outboundMs.type__c == 'rdv_part')
                        ms.type__c = 'resp_rdv_part';
                    if(outboundMs.type__c == 'rdv_pro')
                        ms.type__c = 'resp_rdv_pro';
                    
                    if(outboundMs.Date_retour_client__c == null) {
                        outboundMs.Date_retour_client__c = ms.startTime;
                        updateRespTime.add(outboundMs);
                    }
                }
                if(!Test.isRunningTest())
                    Database.update(updateRespTime, false);
            }
        }
    }
/*
    public static void updateMSOutboundType(List<MessagingSession> msList) {
        Set<String> msNames = new Set<String> ();
        for(MessagingSession ms : msList) {
            if(ms.origin=='TriggeredOutbound') {
                msNames.add(ms.Name);
            }
        }
        if(!msNames.isEmpty()) {
            updateMSOutboundType(msNames);
        }
    }

    @future
    public static void updateMSOutboundType(Set<String> msNames) {

        List<ConversationEntry> convList = [SELECT id, Message, ConversationId, Conversation.Name FROM ConversationEntry WHERE Conversation.Name IN :msNames];
        Map<id, String> MSMessages = new Map<id, String>();
        for(ConversationEntry conv : convList) {
            MSMessages.put(conv.ConversationId, conv.Message);
        }
        List<MessagingSession> msToUpdate = new List<MessagingSession>();
        for(id ms : MSMessages.keySet()) {
            String msg = MSMessages.get(ms);
            if(msg==null || msg=='')
                continue;
        
            if(msg.contains('Ce rendez-vous est clé pour la suite de votre projet')) {
                msToUpdate.add(new MessagingSession(id = ms, type__c = 'rdv_part'));
            } else if (msg.contains('votre date de rendez-vous, avec')) {
                msToUpdate.add(new MessagingSession(id = ms, type__c = 'rdv_pro'));
            } else if(msg.contains('Ces professionnels attendent votre réponse')) {
                msToUpdate.add(new MessagingSession(id = ms, type__c = 'ar_lmsg'));
            }
        }
        if(!msToUpdate.isEmpty())
            Database.update(msToUpdate, false);
    }
    */

    @InvocableMethod(Label='update messaging session' Description='Met Account/projetId/Type sur la MS')
    public static List<String> updateMSInfoFromFlow(List<String> args) {
        System.debug('***** args = '+ args);

        if(System.isBatch()) {
            updateMSInfoSync(args);
        } else {
            updateMSInfoAsync(args);
        }
        List<String> results = new List<String>();
        for(Integer i=0 ; i<args.size(); i++){
            results.add('Success');
        }
        return results;
    }

    @future
    public static void updateMSInfoAsync(List<String> args) {
        updateMSInfo(args);
    }
    public static void updateMSInfoSync(List<String> args) {
        updateMSInfo(args);
    }

    public static void updateMSInfo(List<String> args) {
        Integer numElem = args.size();
        if(numElem==0)
            return;
        Long timeDiff = 0;
        DateTime firstTime = System.now();
        do
        {
            timeDiff = System.now().getTime() - firstTime.getTime();
        }
        while(timeDiff <= long.valueOf(Label.Messaging_Future_Delay)  && !Test.isRunningTest());

        Map<String, String> elemMap = new Map<String, String>(); // key EndUserContactId
        Boolean isPro = false;
        for(integer i =0; i<numElem; i++) {
            List<String> splitedList = new List<String> (args[i].split(';'));
            elemMap.put(splitedList[0], args[i]);
            isPro = splitedList[3].contains('pro');
        }

        List<MessagingSession> msList;
        if(!isPro) {
            msList = [ SELECT id, type__c, Projet_HY__c, Account__c, Projet_LMSG__c, EndUserContactId FROM MessagingSession
                       WHERE Origin = 'TriggeredOutbound' AND EndUserContactId IN :elemMap.keySet() ORDER BY CreatedDate];
        } else {
            msList = [ SELECT id, type__c, Projet_HY__c, Account__c, Projet_LMSG__c, EndUserAccountId FROM MessagingSession
                       WHERE Origin = 'TriggeredOutbound' AND EndUserAccountId IN :elemMap.keySet() ORDER BY CreatedDate];
        }
     
        if(msList.isEmpty())
            return;
        Map<String, MessagingSession> msMap = new Map<String, MessagingSession>();
        for(MessagingSession ms : msList) {
            msMap.put(isPro? ms.EndUserAccountId : ms.EndUserContactId, ms);
        }

        List<MessagingSession> msToUpdate = new List<MessagingSession>();
        for(String ctcEndUser : elemMap.keySet()){
            MessagingSession ms = msMap.get(ctcEndUser);
            if(ms!=null) {
                List<String> splitedList = new List<String> (elemMap.get(ctcEndUser).split(';'));
                ms.Account__c = splitedList[1];
                ms.type__c = splitedList[3];
                if(ms.type__c.contains('hy'))
                    ms.Projet_HY__c = splitedList[2];
                else
                    ms.Projet_LMSG__c = splitedList[2];
                    
                msToUpdate.add(ms);
            }
        }
        if(!msToUpdate.isEmpty())
            Database.update(msToUpdate, false);
    }
    
    /*

            'Ce rendez-vous est clé pour la suite de votre projet' => RDV Part
            'votre date de rendez-vous, avec' => RDV Pro
            'Ces professionnels attendent votre réponse' => AR

         Bonjour, 
            Nous cherchons à vous joindre pour préciser votre projet : {!Projet_LMSG__c.Besoin_travaux_txt__c}.
            Indiquez-nous par retour de SMS quand nous pouvons vous appeler.
            Bonne journée, 
            La Maison Saint-Gobain

            Bonjour, 
            Nous cherchons à vous joindre pour préciser votre projet : {!Projet__c.Flux_Categorie__c}.
            Indiquez-nous par retour de SMS quand nous pouvons vous appeler.
            Bonne journée, 
            La Maison Saint-Gobain
            */


    // check project order
    // trigger outbound NRP / RDV check which is picked up

    public static Map<String, String> ProjectZoneMap = new Map<String, String> {'28'=> 'IDF', '45'=> 'IDF', '75'=> 'IDF', '77'=> 'IDF', '78'=> 'IDF',
                                                                                '91'=> 'IDF', '92'=> 'IDF', '93'=> 'IDF', '94'=> 'IDF', '95'=> 'IDF',
                                                                                '01'=> 'PACA-RA', '04'=> 'PACA-RA', '05'=> 'PACA-RA', '06'=> 'PACA-RA',
                                                                                '07'=> 'PACA-RA', '13'=> 'PACA-RA', '21'=> 'PACA-RA', '26'=> 'PACA-RA',
                                                                                '30'=> 'PACA-RA', '38'=> 'PACA-RA', '42'=> 'PACA-RA', '43'=> 'PACA-RA',
                                                                                '69'=> 'PACA-RA', '71'=> 'PACA-RA', '73'=> 'PACA-RA', '74'=> 'PACA-RA',
                                                                                '83'=> 'PACA-RA', '84'=> 'PACA-RA',
                                                                                '02'=>'PROVINCE', '03'=>'PROVINCE', '08'=>'PROVINCE', '09'=>'PROVINCE',
                                                                                '10'=>'PROVINCE', '11'=>'PROVINCE', '12'=>'PROVINCE', '14'=>'PROVINCE', 
                                                                                '15'=>'PROVINCE', '16'=>'PROVINCE', '17'=>'PROVINCE', '18'=>'PROVINCE', 
                                                                                '19'=>'PROVINCE', '20'=>'PROVINCE', '22'=>'PROVINCE', '23'=>'PROVINCE', 
                                                                                '24'=>'PROVINCE', '25'=>'PROVINCE', '27'=>'PROVINCE', '29'=>'PROVINCE', 
                                                                                '31'=>'PROVINCE', '32'=>'PROVINCE', '33'=>'PROVINCE', '34'=>'PROVINCE', 
                                                                                '35'=>'PROVINCE', '36'=>'PROVINCE', '37'=>'PROVINCE', '39'=>'PROVINCE', 
                                                                                '40'=>'PROVINCE', '41'=>'PROVINCE', '44'=>'PROVINCE', '46'=>'PROVINCE', 
                                                                                '47'=>'PROVINCE', '48'=>'PROVINCE', '49'=>'PROVINCE', '50'=>'PROVINCE', 
                                                                                '51'=>'PROVINCE', '52'=>'PROVINCE', '53'=>'PROVINCE', '54'=>'PROVINCE', 
                                                                                '55'=>'PROVINCE', '56'=>'PROVINCE', '57'=>'PROVINCE', '58'=>'PROVINCE', 
                                                                                '59'=>'PROVINCE', '60'=>'PROVINCE', '61'=>'PROVINCE', '62'=>'PROVINCE', 
                                                                                '63'=>'PROVINCE', '64'=>'PROVINCE', '65'=>'PROVINCE', '66'=>'PROVINCE', 
                                                                                '67'=>'PROVINCE', '68'=>'PROVINCE', '70'=>'PROVINCE', '72'=>'PROVINCE', 
                                                                                '76'=>'PROVINCE', '79'=>'PROVINCE', '80'=>'PROVINCE', '81'=>'PROVINCE', 
                                                                                '82'=>'PROVINCE', '85'=>'PROVINCE', '86'=>'PROVINCE', '87'=>'PROVINCE', 
                                                                                '88'=>'PROVINCE', '89'=>'PROVINCE', '90'=>'PROVINCE'};
}