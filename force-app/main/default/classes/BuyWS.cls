@RestResource(urlMapping='/subscription/buy/')
global without sharing class BuyWS {
	
	global static TryAndBuyMethods.TryObject datas;

	
	@HttpPost
	global static TryAndBuyMethods.ResponseWS traitement_buy(TryAndBuyMethods.TryObject data) {
		datas = data;
		TryAndBuyMethods.ResponseWS res = TryAndBuyMethods.traitement(datas);
		TryAndBuyMethods.buyMethods(datas,res);
		//system.debug('tryJSON = ' + datas);
		//return TryAndBuyMethods.buyMethods(datas,res);
		return res;
	}


}