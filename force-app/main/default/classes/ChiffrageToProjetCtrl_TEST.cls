@isTest
public class ChiffrageToProjetCtrl_TEST {
	public static testMethod void testMyController() {
        PageReference pageRef = Page.VF_TransformChiffrage;
        pageRef.getParameters().put('chiffrageId','a1m4E000000zEhtQAE');
		Test.setCurrentPage(pageRef);
        ChiffrageToProjetCtrl controller = new ChiffrageToProjetCtrl();
    }
	public static testMethod void testMyControllerWithParamShowHeader() {
        PageReference pageRef = Page.VF_TransformChiffrage;
        pageRef.getParameters().put('chiffrageId','a1m4E000000zEhtQAE');
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('showHeader','true');
        ChiffrageToProjetCtrl controller = new ChiffrageToProjetCtrl();
    }
}