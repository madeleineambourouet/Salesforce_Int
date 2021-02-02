public class VFC_Search_ProgrammesFidelite {
    public Boolean showHeader {get;set;}
    public Boolean showSidebar {get;set;}
    public String callfunc {get;set;}
    public String codeClientP {get;set;}
    public String erreurs {get;set;}
    public Boolean hasErreurs {get;set;}
    public String host {get;set;}
    public Account account {get;set;}
    public String msgAccountUpdate {get;set;}

   
    public VFC_Search_ProgrammesFidelite() {
        showHeader = true;
        showSidebar = true;
        String isSessionConsole = ApexPages.currentPage().getParameters().get('isSessionConsole');
        System.debug('isSessionConsole '+isSessionConsole);
        if(isSessionConsole != null && isSessionConsole == '1'){
        	showHeader = false;
        	showSidebar = false;
        	hasErreurs = false;
        }
      
    }

    public void getContactsFromGenerationArtisan() {
    	//Verifie si le compte exite avec le code client P (cette verification sert uniquement a afficher le message "compte créé ou compe MAJ")
    	Boolean isNewAccount = true;
    	if(codeClientP != null && codeClientP.deleteWhitespace() != ''){
    		List<Account> compteClientPointP =  [SELECT Id,CreatedDate,LastModifiedDate FROM Account WHERE Code_client_Point_P__c =:codeClientP];
    		if(compteClientPointP.size() > 0){
    			isNewAccount = false;
    		}
    	}
    	List<String> listErreurs = GenerationArtisanService.serviceGenerationArtisanVFP('',codeClientP);   
        System.debug('getContactsFromGenerationArtisan listErreurs '+listErreurs); 
        //On formatte la variable avec ## pour pouvoir le convertir en tableau en javascript et afficher ligne par ligne les erreurs
        erreurs = String.join(listErreurs, '##');
        erreurs=String.escapeSingleQuotes(erreurs);
        System.debug('getContactsFromGenerationArtisan erreurs '+erreurs); 
        System.debug('getContactsFromGenerationArtisan erreurs.length() '+erreurs.length());
        if(erreurs.length() > 3){
        	//callfunc='<script> showDialog(\'Génération Artisan - programmes de fidélité\',\''+erreurs+'\'); </script>';
        	hasErreurs = true;
			account = null;
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please enter Account name'));
        } 
        else{
        	hasErreurs = false;
        	codeClientP = codeClientP.deleteWhitespace();
        	callfunc = '';
	        List<Account> compteClientPointP =  [SELECT Id,Name, SIRET_texte__c, Code_client_Point_P__c,CreatedDate,LastModifiedDate FROM Account WHERE Code_client_Point_P__c =:codeClientP];
			if(compteClientPointP.size() == 1){
				for(Account a: compteClientPointP){
	        		account = new Account();
					account = a;
        			System.debug('getContactsFromGenerationArtisan a.CreatedDate '+a.CreatedDate); 
        			System.debug('getContactsFromGenerationArtisan a.LastModifiedDate '+a.LastModifiedDate);
					Long dt1Long = (a.CreatedDate).getTime();
					Long dt2Long = (a.LastModifiedDate).getTime();
					Long milliseconds = dt2Long - dt1Long;
					Long seconds = milliseconds / 1000;
					Long minutes = seconds / 60;
        			System.debug('getContactsFromGenerationArtisan milliseconds '+milliseconds);
        			System.debug('getContactsFromGenerationArtisan seconds '+seconds);
        			System.debug('getContactsFromGenerationArtisan minutes '+minutes);
        			//Si le compte est tagué nouveau et la difference de mise a jour inferieur a 30 secondes
					msgAccountUpdate = 'Le compte '+a.Name+' a été mis à jour';
					if(isNewAccount == true && (seconds < Long.valueOf('30')) == true){
        				msgAccountUpdate =  'Le compte '+a.Name+' a été créé';
					}
				}
			}
        } 
        host = ApexPages.currentPage().getHeaders().get('Host');
        
    }
    
}