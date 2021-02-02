@RestResource(urlMapping='/subscription/try/')
global without sharing class TryWS {
	
	global static TryAndBuyMethods.TryObject datas;

	@HttpPost
	global static TryAndBuyMethods.ResponseWS traitement_try(TryAndBuyMethods.TryObject data) {
		datas = data;
		TryAndBuyMethods.ResponseWS res = TryAndBuyMethods.traitement(datas);
		//system.debug('tryJSON = ' + datas);
		return TryAndBuyMethods.trymethods(datas,res);
	}
}