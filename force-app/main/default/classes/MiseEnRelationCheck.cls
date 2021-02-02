//@RestResource(urlMapping='/MiseEnRerlation/*')
global class MiseEnRelationCheck 
{
    //@httpPost
    webService static List<String> CheckValidity (ID MiseEnRelation, String DateDerniereSelection){
        http h= new http();
       
        HTTPRequest req = new HTTPRequest();
        String match = MiseEnRelation; //'a003E000001DYJPQA4';
        String geocat_last_selection = DateDerniereSelection; //'2016-08-22T14:50:00Z';

        req.setEndpoint('http://intermed-int.homly-you.com/intermediation/check?match='+match + '&geocat_last_selection=' + geocat_last_selection);
        req.setMethod('GET');
        req.setTimeout(120000);

        HTTPResponse res = h.send(req);
        System.debug('>>>>>>>>>>>>>>>>>> res.body()' + res.getBody());
      
        if (res.getStatusCode() != 200){
            System.debug('ERREUR : Erreur durant la connexion à l\'intermediation : STATUT = ' + res.getStatus() + ' / CODE REPONSE = ' + res.getStatusCode() + ' / CORPS = ' + res.getBody());
           // return;
        }
        List<String> ListRetour = new List<String>();
        String authorizedString='';
        String response = res.getBody();
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>> response : '+ response);
        MiseEnRelation_WSReturn returnWS_check = MiseEnRelation_WSReturn.parse(response);
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>> returnWS_check = '+returnWS_check); 
        if (returnWS_check != null){   
            MiseEnRelation_WSReturn intermed = returnWS_check;
            if (intermed.authorized == true){
                authorizedString = 'TRUE';}
            else{ 
                authorizedString ='FALSE';}
                
        ListRetour.add(intermed.context);
        ListRetour.add(authorizedString);
        ListRetour.add(intermed.info);
        }
           return ListRetour; 
    }
    

}