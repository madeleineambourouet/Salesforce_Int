/**
* @author Qiuyan Liu
* @Created date 20/12/2016
*
* @description send a list of email in mass
*/
global with sharing class EmailMassHelper {
	public static Integer BATCH_SIZE = 100;
    
    public static void sendEmailMass(List<EmailDefination> emailList) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for (EmailDefination e : emailList) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            mail.setToAddresses(e.toAddressList);
            mail.setCcAddresses(e.ccAddressList);
            mail.setSubject(e.emailSubject);
            mail.setOrgWideEmailAddressId(e.fromAddress);
            

            if (e.templateID != null) {
                mail.setTemplateId(e.templateID);
                mail.setTargetObjectId(e.targetId); 
                
            } else if (e.emailHtmlBody != null) {
                mail.setHtmlBody(e.emailHtmlBody);
            } else if (e.emailTextBody != null) {
            	 mail.setPlainTextBody(e.emailTextBody);
            }

            if ((e.whatId != null && e.whatId != '') || Test.isRunningTest()) {
                mail.setWhatId(e.whatId);
            }

            List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
            if (e.attachmentFile != null) {
                Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
                att.setFileName(e.attachmentFilename);
                att.setBody(e.attachmentFile.Body);
                fileAttachments.add(att);
            }
            mail.setFileAttachments(fileAttachments);
            
            emails.add(mail);
            
            if (emails.size() == BATCH_SIZE) { 
	        	Messaging.SendEmail(emails);
	        	emails.clear();
	        }
        }
        if (emails.size() > 0) {
        	Messaging.SendEmail(emails);
        }
    }
    
    
    public class EmailDefination {
        public ID templateID;
        public Id targetId;
        public String emailHtmlBody;
        public String emailTextBody;
        public Attachment attachmentFile;
        public String attachmentFilename;
        public ID fromAddress;
        public String[] toAddressList;
        public String[] ccAddressList;
        public Id whatId;
        public String emailSubject;
    }
}