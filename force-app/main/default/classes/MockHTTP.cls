@isTest
global class MockHTTP implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req){
        
        System.debug('>>>>>>>>>>>>>>>>>> REQUEST ENDPOINT: ' + req.getEndpoint());
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/json');
        /*
        String body = 
        '{\n'
        +'"algo":"qs,matching",\n'  
        +'"id_chantier":"",\n'
        +'"code_insee":"92014",\n'
        +'"id_sous_categorie":"1022",\n'
        +'"attributs":{"DIMENSION3":10, "LISTE_QUAND":"asap","BUDGET":30000,"TEXTELIBRE":"tout va bien"},\n'
        +'"ip":"193.234.1.9",\n'
        +'"temps_navigation":3,\n'
        +'"presence_photo":"false",\n'
        +'"url_photo":"",\n'
        +'"communication":"false",\n'
        +'"sgid":0,\n'
        +'"valeur_pia":"",\n'
        +'"type_source":"",\n'
        +'"type_affilie":""\n'
        +'}';
        */
        String body = '{"liste_pro": [], "execution": {"detail": "MySQL connection failed", "statut": "OK"}, "quality_score": {"note": 4, "score": 0, "raison": "ERROR"}}';
        
        //'{"liste_pro": [{"status_pro": "pro", "id_pro": "0037E000002ihtG", "id_competence_pro": "341"}, {"status_pro": "pro", "id_pro": "0037E000004cQIN", "id_competence_pro": "339"}, {"status_pro": "prospect", "id_pro": "0037E000004v0rd"},'
                        // +' {"status_pro": "prospect", "id_pro": "0037E000003ZC3G"}], "status": "ok", "quality_score": 1}';
        
        
        
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }


}