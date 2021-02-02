trigger TokenTrigger on Token__c (before insert) {
    System.debug('TokenTrigger : Trigger.new ' + Trigger.new);
    for (Token__c token : Trigger.new){
        
        if (token.Type_de_token__c == 'E-mail création') {
            
            Blob targetBlob = Blob.valueOf(token.Name + Datetime.now().getTime());
            Blob hashBlob = Crypto.generateDigest('MD5', targetBlob);
            String hash = EncodingUtil.convertToHex(hashBlob);
            System.debug('>>>>>>>>>>>>>>>>>> hash = ' + hash);
        
            token.Email_du_compte__c = token.Name;
            token.Name = hash;
            token.Validite__c = 31;
            token.Nombre_d_usage_token_restant__c = 5;
            token.URL_redirection__c = Label.URL_web_pour_email + hash;
            
        }
            
    }

}