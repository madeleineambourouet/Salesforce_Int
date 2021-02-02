@IsTest
private class multicanal_msg_test_TEST {

  @IsTest
  private static void Test_de_multicanal_msg_test() {

    Test.setMock(HttpCalloutMock.class, new SMSCalloutMock());
    Test.startTest();
      
    //Contact[] ContactPro = [SELECT id FROM Contact LIMIT 1];
      
	List<Account> acc_list = new List<Account>();
	Account myAccount = new Account(Name = 'Test Account');
	acc_list.add(myAccount);
	insert acc_list;
	List<Contact> ctc_list = new List<Contact>();
	Contact ContactPro = new Contact(AccountId = myAccount.Id,FirstName='XX',LastName='TEST',Salutation='Mr', Email='xx.test@saint-gobain.com', Phone ='+33634343434', MobilePhone ='+33634343434');
	ctc_list.add(ContactPro);
	insert ctc_list;
            
   // if (ContactPro.size()>0) {
	    System.Debug('ContactPro '+ ContactPro.Id);
		multicanal_msg_test.sendSMSSelectionTest(ContactPro.Id,ContactPro.MobilePhone,ContactPro.Name);
	    // runs callout and check results
	    //System.assertEquals(ContactPro.Resultat_test_SMS__c, 'OK');
	    //System.Debug('ContactPro.Resultat_test_SMS__c '+ ContactPro.Resultat_test_SMS__c);
		multicanal_msg_test.generateEmailTest(ContactPro.Id,null);
    //}
    Test.stopTest();
  }
}