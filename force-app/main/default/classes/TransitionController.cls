global with sharing class TransitionController {

	@remoteAction
	global static void getTest(String link) {
	//String s = System.currentPageReference().getParameters().get('adress');
		System.debug('TEST : link : ' + link);
	 	//System.debug('TEST : adress : ' + adress);

        //return (new PageReference(link));
    }
}