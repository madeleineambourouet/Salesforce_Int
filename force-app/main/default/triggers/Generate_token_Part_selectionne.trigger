trigger Generate_token_Part_selectionne on Intermediation__c (after update) {
//system.debug('>>>>>>>> Generate_token_Part_selectionne 1');
//    if(checkRecursiveSFDC.runOnce()) {
//system.debug('>>>>>>>> Generate_token_Part_selectionne 2');
//        if(Trigger.isUpdate && Trigger.isAfter) {
//            Map<Id, Intermediation__c> merMap = new Map<Id, Intermediation__c>([SELECT Id, Projet__c, Projet__r.Particulier__c, Projet__r.Particulier__r.Login__c, Projet__r.Particulier__r.Mail_de_facturation__c FROM Intermediation__c WHERE Id in: Trigger.new]);                       
//            List<Token__c> tokenList = new List<Token__c>();
//            for(Id merId : merMap.keyset()) {
//                Intermediation__c oldMER = Trigger.oldMap.get(merId);
//                 system.debug('>>>>>>>> oldMER '+ oldMER);
//                Intermediation__c newMER = Trigger.newMap.get(merId);
//                 system.debug('>>>>>>>> newMER '+ newMER);
//                Intermediation__c curMER = merMap.get(merId);
//                system.debug('>>>>>>>> curMER '+ curMER);
//system.debug('>>>>>>>> Generate_token_Part_selectionne 3 '+ newMER.Is_selectionne__c);

//                if(oldMER.Is_selectionne__c != newMER.Is_selectionne__c && newMER.Is_selectionne__c == true) { 
//                    Blob targetBlob = Blob.valueOf(curMER.Projet__r.Particulier__r.Login__c + Datetime.now().getTime());
//                    Blob hashBlob = Crypto.generateDigest('MD5', targetBlob);
//                    String hash = EncodingUtil.convertToHex(hashBlob);
//                    Token__c token = new Token__c(Name = hash, Compte__c = curMER.Projet__r.Particulier__c, Validite__c = 31, Nombre_d_usage_token_restant__c = 5, 
//                                    Type_de_token__c = 'Part Sélectionné', URL_redirection__c = Label.URL_web_pour_email + hash,Email_du_compte__c = curMER.Projet__r.Particulier__r.Login__c);
//                    tokenList.add(token);
//                    curMER.Token_Part_Selectionne__c = hash;  
//                 }
//            }
//            if (tokenList.size() > 0) {
//                System.debug('Qiuyan Debug : Generate_token_Part_selectionne merMap.values ' + merMap.size());
//                insert tokenList;
//                update merMap.values();  
//            }
//        }
//    }
}