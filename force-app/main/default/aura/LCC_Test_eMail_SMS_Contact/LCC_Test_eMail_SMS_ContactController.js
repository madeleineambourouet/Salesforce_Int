({
	apexQuery : function(component, event, helper) {
        var myQuery = 'SELECT Name, MobilePhone, Account.Login__c FROM Contact WHERE Name = \''+component.get('v.sObjectInfo.Name')+'\'';
        helper.executeQuery(component, event, helper, myQuery);
	},
    
    	afterQuery: function(component, event, helper) {
        //after code
        
        
var recordsPro = component.get('v.queryResult');
var res = sforce.apex.execute('multicanal_msg_test', 'sendSMSSelectionTest', {
  idCtc: ''+helper.idTruncate(component.get('v.sObjectInfo.Id'))+'', 
  proPhoneNumber: 'ecordsPro[0].MobilePhon', 
  proName: 'ecordsPro[0].Nam'});
var res = sforce.apex.execute('multicanal_msg_test', 'generateEmailTest', {
  ContactId: ''+helper.idTruncate(component.get('v.sObjectInfo.Id'))+'', 
  WhatId: ''+helper.idTruncate(component.get('v.sObjectInfo.Account.Id'))+''});

        $A.get("e.force:closeQuickAction").fire();
	}

})