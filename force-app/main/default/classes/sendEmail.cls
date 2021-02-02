public class sendEmail {
	public String subject { get; set; }
	public String body { get; set; }
    public List<Projet__c> proj { get; set; }

	private final  Projet__c projet;

	// Create a constructor that populates the Projet object
	public sendEmail(ApexPages.StandardController std) {
		projet = [select Particulier__r.Name, Particulier__r.PersonEmail

				from Projet__c where id = :ApexPages.currentPage().getParameters().get('id')];
        getprojet();
	}

	public void getprojet() {
        this.proj = new List<Projet__c>();
        this.proj.add(projet);
	}

	public PageReference send() {
		// Define the email
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 

    	String addresses = projet.Particulier__r.PersonEmail;
   
		String[] toAddresses = addresses.split(':', 0);
        
		// Sets the paramaters of the email
		email.setSubject( subject );
		email.setToAddresses( toAddresses );
        email.setPlainTextBody( body );
    
		// Sends the email
		Messaging.SendEmailResult [] r = 
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
		
		return null;
	}
}