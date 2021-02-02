/*
* @author Qiuyan LIU
* @date 14/12/2018
* @description test class for QuoteOptions
*/
@isTest
public with sharing class QuoteOptionsTEST {

	public static testMethod void  test1() {
        zqu__Quote__c quote = new zqu__Quote__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        QuoteOptions controller = new QuoteOptions(sc);
        PageReference pageRef = Page.UnifiedQuoteDetailWrapper;
        Test.setCurrentPage(pageRef);
	}
}