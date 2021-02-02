/*
* @author Qiuyan LIU
* @date 14/12/2018
* @description extension for VF UnifiedQuoteDetailWrapper
*/
public with sharing class QuoteOptions {
   // Purpose: Custom Chatter profile page
   private ApexPages.StandardController c;

   // Getter methods you can call from your Visualforce page, e.g. {! viewingMyProfile }
   public zqu.SelectProductComponentOptions optionsS { get; set; }

   // Constructor method for the controller
   public QuoteOptions(ApexPages.StandardController stdController) {
       c = stdController;
       zqu__quote__c quote = (zqu__quote__c) c.getRecord();
       optionsS = new zqu.SelectProductComponentOptions();
       optionsS.mode = zqu.SelectProductComponentOptions.MODE_DETAIL;
       optionsS.quoteId = quote.Id;
       system.debug('QuoteOptions quote '+quote);
       system.debug('QuoteOptions optionsS '+optionsS);
       system.debug('QuoteOptions optionsS.mode '+optionsS.mode);
       system.debug('QuoteOptions optionsS.quoteId '+optionsS.quoteId);
   }
}