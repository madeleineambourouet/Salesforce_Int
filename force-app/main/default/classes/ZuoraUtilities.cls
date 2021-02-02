/*    Copyright (c) 2015 Zuora, Inc.
 *
 *   Permission is hereby granted, free of charge, to any person obtaining a copy of 
 *   this software and associated documentation files (the "Software"), to use copy, 
 *   modify, merge, publish the Software and to distribute, and sublicense copies of 
 *   the Software, provided no fee is charged for the Software.  In addition the
 *   rights specified above are conditioned upon the following:
 *
 *   The above copyright notice and this permission notice shall be included in all
 *   copies or substantial portions of the Software.
 *
 *   Zuora, Inc. or any other trademarks of Zuora, Inc.  may not be used to endorse
 *   or promote products derived from this Software without specific prior written
 *   permission from Zuora, Inc.
 *
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *   FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL
 *   ZUORA, INC. BE LIABLE FOR ANY DIRECT, INDIRECT OR CONSEQUENTIAL DAMAGES
 *   (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 *   ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  


 *   IN THE EVENT YOU ARE AN EXISTING ZUORA CUSTOMER, USE OF THIS SOFTWARE IS GOVERNED

 *   BY THIS AGREEMENT AND NOT YOUR MASTER SUBSCRIPTION AGREEMENT WITH ZUORA.
 */
 

public with sharing class ZuoraUtilities {


    public static Zuora.zApi zuoraApiAccess() { 
    Zuora.zApi zuoraApi = new Zuora.zApi();
        if (!Test.isRunningTest()) {
            zuoraApi.zlogin();
        } else {
            // nothing
        }
        return zuoraApi;
    }


    public static List<Zuora.zObject> queryToZuora(Zuora.zApi zuoraApi, String query) {
        List<Zuora.zObject> queryResultList = new List<Zuora.zObject>();
        if (!Test.isRunningTest()) {
            queryResultList.addAll(zuoraApi.zquery(query));
        } else {
            Zuora.zObject res;
            
            if (query.contains('FROM Subscription')) {
                res = new Zuora.zObject('Subscription');
                res.setValue('OriginalId', '123456789');
                res.setValue('AccountId', '123456789');
                res.setValue('Name', '123456789');
                res.setValue('TermEndDate', Date.today().addMonths(8));
                res.setValue('SubscriptionStartDate', Date.today().addMonths(-1));
            } else if (query.contains('FROM InvoiceItem')) {
                res = new Zuora.zObject('InvoiceItem');
                res.setValue('SubscriptionId', '123456');
                res.setValue('InvoiceId', '123456');
                res.setValue('ChargeName', 'Partner Membership - Annual');
                res.setValue('ServiceEndDate', Date.today().addMonths(2));
            } else if (query.contains('TargetDate FROM Invoice')) {
                res = new Zuora.zObject('Invoice');
                res.setValue('Amount', 12);
                res.setValue('Balance', 0);
                res.setValue('TargetDate', Date.today().addMonths(1));
            } else if (query.contains('FROM InvoicePayment')) {
                res = new Zuora.zObject('InvoicePayment');
                res.setValue('Amount', 12);
                res.setValue('PaymentId', '123456');
            } else if (query.contains('FROM Invoice')) {
                res = new Zuora.zObject('Invoice');
                res.setValue('Amount', -6);
            } else if (query.contains('FROM Payment')) {
                res = new Zuora.zObject('Payment');
                res.setValue('Amount', 12);
                res.setValue('Type', 'Electronic');
            }

            res.setValue('Id','123456');

            queryResultList.add(res);
        }
        return queryResultList;
    }


    public static List<Zuora.zApi.SaveResult> createZuoraObjects(Zuora.zApi zuoraApi, List<Zuora.zObject> zuoraObjectsToCreateList) {
        List<Zuora.zApi.SaveResult> zuoraObjectsCreateResults = new List<Zuora.zApi.SaveResult>();
        if (!Test.isRunningTest()) {
            zuoraObjectsCreateResults = zuoraApi.zcreate(zuoraObjectsToCreateList);
        } else {
            Zuora.zApi.SaveResult res = new Zuora.zApi.SaveResult();
            res.Success = true;
            res.Id = '1234';
            zuoraObjectsCreateResults = new List<Zuora.zApi.SaveResult>{res};
        }
        return zuoraObjectsCreateResults;
    }


    public static List<Zuora.zApi.SaveResult> updateZuoraObjects(Zuora.zApi zuoraApi, List<Zuora.zObject> zuoraObjectsToUpdateList) {
        List<Zuora.zApi.SaveResult> zuoraObjectsUpdateResults = new List<Zuora.zApi.SaveResult>();
        if (!Test.isRunningTest()) {
            zuoraObjectsUpdateResults = zuoraApi.zupdate(zuoraObjectsToUpdateList);
        } else {
            Zuora.zApi.SaveResult res = new Zuora.zApi.SaveResult();
            res.Success = true;
            res.Id = '1234';
            zuoraObjectsUpdateResults = new List<Zuora.zApi.SaveResult>{res};
        }
        return zuoraObjectsUpdateResults;
    }


    public static List<String> analyzeSaveResult(Zuora.zApi.SaveResult saveResult) {
        List<String> result = new List<String>(); 
        
        // If zuora return variable is null / empty
        if (saveResult == null)
            result.add('Error: Zuora return is null');
        else
        {
            if ( !(saveResult.Success) ) {  
                for (Zuora.zObject error : saveResult.errors) {
                    //String errorCode = (String)error.getValue('Code');
                    //String message = (String)error.getValue('Message');
                    result.add((String)error.getValue('Code'));
                    result.add((String)error.getValue('Message'));
                    //System.debug(errorCode);
                    //System.debug(message);
                }
            }
        }
        return result;
    }
    
    public static List<String> analyzeAmendResult(Zuora.zApi.AmendResult amendResult) {
        List<String> result = new List<String>(); 
        
        // If zuora return variable is null / empty
        if (amendResult == null)
            result.add('Error: Zuora return is null');
        else
        {
            if ( !(amendResult.Success) ) {  
                for (Zuora.zObject error : amendResult.errors) {
                    //String errorCode = (String)error.getValue('Code');
                    //String message = (String)error.getValue('Message');
                    result.add((String)error.getValue('Code'));
                    result.add((String)error.getValue('Message'));
                    //System.debug(errorCode);
                    //System.debug(message);
                }
            }
        }
        return result;
    }


    public static Zuora.zApi.AmendResult createCancellationAmendment(Zuora.zApi zuoraApi, boolean preview, boolean processInvoice, 
            String zuoraSubscriptionId, String amendmentName, String amendmentDescription, Date contractEffectiveDate, Date effectiveDate) {
        Zuora.zObject amendment = new Zuora.zObject('Amendment');       
        
        amendment.setValue('SubscriptionId', zuoraSubscriptionId);
        amendment.setValue('Type', 'Cancellation');
        amendment.setValue('Status', 'Completed');
        
        amendment.setValue('Name', amendmentName);
        amendment.setValue('Description', amendmentDescription);
                                    
        amendment.setValue('ContractEffectiveDate', dateZuoraFormat(contractEffectiveDate));
        amendment.setValue('EffectiveDate', dateZuoraFormat(effectiveDate));

        Zuora.zApi.AmendRequest amendRequest = new Zuora.zApi.AmendRequest();
        amendRequest.amendments = new List <Zuora.zObject>{amendment};

        Zuora.zApi.InvoiceProcessingOptions invProcessOptions = new Zuora.zApi.InvoiceProcessingOptions();
        invProcessOptions.InvoiceDate = dateZuoraFormat(Date.today());
        invProcessOptions.InvoiceTargetDate = dateZuoraFormat(contractEffectiveDate);

        Zuora.zApi.AmendOptions amendmentOptions = new Zuora.zApi.AmendOptions();
        amendmentOptions.InvoiceProcessingOptions = invProcessOptions;
        amendmentOptions.GenerateInvoice = processInvoice;
        amendmentOptions.ProcessPayments = false;

        amendRequest.amendOptions = amendmentOptions;
        
        Zuora.zApi.PreviewOptions previewOptions = new Zuora.zApi.PreviewOptions();
        previewOptions.EnablePreviewMode = preview;
        previewOptions.NumberOfPeriods = 1;
        amendRequest.previewOptions = previewOptions;

        List<Zuora.zApi.AmendRequest> amendRequestsList = new List<Zuora.zApi.AmendRequest>{amendRequest};

        Zuora.zApi.AmendResult amendResult;

        if (!Test.isRunningTest()) {
            amendResult = zuoraApi.zamend(amendRequestsList);
        } else {
            amendResult = new Zuora.zApi.AmendResult();
            amendResult.Success = true;
            amendResult.InvoiceId = '123456';

            //invData.setValue('ChargeNumber', '1234');
            Zuora.zObject invData = new Zuora.zObject('Invoice');
            invData.setValue('Amount', -6);
            //invData.setValue('InvoiceItem', new List<Object>());
            if (preview) {
                amendResult.InvoiceDatas = new List<Zuora.zObject>();
                amendResult.InvoiceDatas.add(invData);
            }
        }
        return amendResult;
    }


    public static String dateZuoraFormat(Date someDate) {
        return String.valueOf(someDate)+'T00:00:00';
    }

/*
    public static void sendNotificationEmail(String type, String message, Exception e) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
        //String emailAddr = 'kevin.@.com';
        //String emailAddr2 = 'daniel.@.com';          
        //String[] toAddresses = new String[] {emailAddr, emailAddr2};
        
        String[] toAddresses = '';//Label.ZuoraErrorEmail.split(';');
        
        mail.setToAddresses(toAddresses);
        
        if (type == 'Contact') {            
            mail.setSubject(' | SALESFORCE - ZUORA: Contact custom synch error.');
        } else if (type == 'PM') {
            mail.setSubject(' | SALESFORCE - ZUORA: Payment Method change error.');
        } else {
            mail.setSubject(' | SALESFORCE - ZUORA: Update error.');
        }
        
        String textBody = '';
        textBody += message + '\r\n\r\n';
        if (e != null) {
            textBody += 'Exception: ' + e.getTypeName() + ' on line: ' + e.getLineNumber() + '.\r\n' + e.getMessage() + '\r\n' + e.getStackTraceString() + '\r\n\r\n';  
        }
                            
        mail.setPlainTextBody(textBody);
        try {            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail} );
            System.Debug('###### INFO: Notification email sent to: ' + toAddresses + '\r\n The message is: ' + message);
        } catch(System.EmailException ex) {
            System.Debug('###### ERROR: ' + ex.getMessage());
        }
    }
 */   
}