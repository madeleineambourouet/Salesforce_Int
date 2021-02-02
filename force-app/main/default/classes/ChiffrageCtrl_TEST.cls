@isTest
public class ChiffrageCtrl_TEST {
	public static testMethod void testMyController() {
        PageReference pageRef = Page.VF_Chiffrage_View;
        pageRef.getParameters().put('id','a1m4E000000zEhtQAE');
        Test.setCurrentPage(pageRef);
        ChiffrageCtrl controller = new ChiffrageCtrl();
    }
}