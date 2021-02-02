trigger AccountNameClean on Account (before insert) {
    for (Account acc : trigger.new) {
        String strClean = acc.Name;
        if (strClean == null) continue;
        strClean = strClean.toLowerCase();
        String specialChars = '! "#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~€‚ƒ„…†‡ˆ‰‹Œ‘’“”•–—˜™›œ ¢£¤¥¦§¨©ª«¬­®¯°±²³´µ¶·¸¹º»¼½¾¿ÆÐ×ØÞßæð÷øþ';
        List<String> scList = specialChars.split('');
        for(integer i=0; i<scList.size(); i++) {
            strClean = strClean.replace(scList[i], '');
        }
        Map<String, String> rules = new Map<String, String>();
        rules.put('e', '[èéêë]'); 
        rules.put('a', '[àáâãäå]');
        rules.put('u', '[ùúûü]');
        rules.put('c', '[ç]');
        rules.put('s', '[š]'); 
        rules.put('z', '[ž]');
        rules.put('o', '[òóôõö]'); 
        rules.put('y', '[ÿý]');
        rules.put('i', '[ìíîï]');
        rules.put('n', '[ñ]');
        for (String key : rules.keyset()) {
            strClean = strClean.replaceAll(rules.get(key), key);
        }
        acc.Raison_Sociale_Nettoye__c = strClean;
    }
}