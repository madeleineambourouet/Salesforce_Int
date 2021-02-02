Global class EmailHelper {

    public static void sendQuoteByMail(ID templateID, ID contactID, ID quoteID, Attachment PJ, String PJname, ID fromAddress) {
        
        //New instance of a single email message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // Who you are sending the email to
        mail.setTargetObjectId(contactID);
        // The email template ID used for the email
        mail.setTemplateId(templateID);
        // The object concerned by the mail (for template fusion fields)
        mail.setWhatId(quoteID); 
        // The sender address of the mail
        mail.setOrgWideEmailAddressId(fromAddress);
        
        List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
        if (PJ != null) {
            Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
            att.setFileName(PJname);
            att.setBody(PJ.Body);
            fileAttachments.add(att);
        }
        mail.setFileAttachments(fileAttachments);

        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(false); 

         if(checkRecursiveSFDCMail.runOnce())
         {
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
         }

    } 

}