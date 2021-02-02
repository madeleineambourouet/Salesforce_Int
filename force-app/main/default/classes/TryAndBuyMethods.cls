global without sharing class TryAndBuyMethods {

	global static Account acc;
	global static Contact con;
	global static List<Try__c> tries;
	global static zqu__Quote__c quote;
	global static QuoteRulesEnginePluginController engineController;
	global static Boolean triggerStop = false;

	// Classes necessaires au format JSON
	global class TryObject {
		global String error;
		global String idClient;
		global String subscriptionMode;
		global productsObject products;
		global companyObject company;
		global companyIdentifiersFRObject companyIdentifiersFR;
		global sgObject sg;
		global List<contactsObject> contacts;
		global companyAddressObject companyAddress;
		global Account acc;
		global Contact con;
		global Try__c tri;
		global zqu__Quote__c quo;


	}

	global class companyAddressObject {
		global String address;
		global String additionalAddress;
		global String country;
		global String zipCode;
		global String city;
		global String inseeCode;
	}

	global class productsObject {
		global String billingPeriod;
		global List<productListObjet> productList;

	}

	global class productListObjet {
		global String name;
		global String startDate;
		global String endDate;
	}

	global class companyObject {
		global String companyName;
		global String description;
		global String request;
		global String websiteUrl;
	}

	global class companyIdentifiersFRObject {
		global String nafOrApe;
		global String siret;
	}

	global class sgObject {
		global String agence;
		global String codeClientGroupe;
		global String customerIdSAP;
		global String sgId;
		global String codePointP;
		global String enseigneGestion;
	}

	global class contactsObject {
		global String title;
		global String firstname;
		global String lastname;
		global String phone1;
		global String phone2;
		global String role;
		global String email;
		global String description;
		global contactAddressObject contactAddress;
	}

	global class contactAddressObject {
		global String address;
		global String additionalAddress;
		global String zipCode;
		global String inseeCode;
		global String city;
		global String country;

	}

	global class ResponseWS {
		global String status;
		global String createdIdClient;
		global String failedCode;
		global String message;
	}

	// Fin des classes necessaires au format JSON

	global static ResponseWS traitement(TryObject objtry) {

		triggerStop = true;

		// Verification de l'id crm si il existe!
		if (objtry.idclient != null && [SELECT Id FROM Account WHERE Id = :objtry.idClient].size() > 0)
			return getResponse('success', '', objtry.idClient);
		else if (objtry.idclient != null)
			return getResponse('error', 'Id Salesforce introuvable', objtry.idClient);

		RecordType rtAgence = [SELECT Id FROM RecordType WHERE DeveloperName = 'Agence' LIMIT 1];
		RecordType rtpro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Compte_Professionnel' LIMIT 1];

		// Recuperation du contact
		contactsObject conobj;
		for (contactsObject con : objtry.contacts) {
			conobj = con;
			break;
		}

		if (!AccountMethods.checkSiret(objtry.companyIdentifiersFR.siret)){
			objtry.error += 'SIRET;';
			return getResponse('error', 'SIRET invalide', null);
		}

		system.debug('conobj = ' + conobj);
		if (!validateEmail(conobj.email)) {
			objtry.error += 'MAIL;';
			return getResponse('error', 'Email invalide', null);
		}

		if (!validatePhone(conobj.phone1)) {
			objtry.error += 'PHONE;';
			return getResponse('error', 'Numero de téléphone invalide', null);
		}

		String cp = constructInseeCP(objtry.companyAddress.inseeCode, objtry.companyAddress.zipCode);
		if (!validateCP(cp)) {
			objtry.error += 'CP;';
			return getResponse('error', 'Code postal/Insee invalide', null);
		}

		if ([SELECT Id FROM Account WHERE SIRET_texte__c =:objtry.companyIdentifiersFR.siret AND Statut_de_paiement__c != null].size() > 0) {
			objtry.error += 'IMPAYE;';
			return getResponse('error', 'Compte impayé', null);
		}


		List<Account> accs = [SELECT Id FROM Account WHERE SIRET_texte__c =:objtry.companyIdentifiersFR.siret AND SIRET_texte__c != null];
		List<Contact> cons = [SELECT Id FROM Contact WHERE Email =:conobj.email];
		//Map<String, Try__c> trys = new map<String,Try__c>();
		//List<Try__c> t = new List<Try__c>();

		// Verifie si le SIRET est présent dans Salesforce
		if (accs.size() == 0) {
			

			Account a = new Account();
			Contact c = new Contact();
			
			a.Canal_pr_inscription__c = 'WEB';
			a.Source_pr_inscription__c = 'FULL WEB';


			if (objtry.company != null){
				a.Name = objtry.company.companyName;
				a.Description = objtry.company.description;
				a.Website = objtry.company.websiteUrl;
			}


			if (objtry.companyIdentifiersFR != null){
				a.SIRET_texte__c = objtry.companyIdentifiersFR.siret;
				if (objtry.companyIdentifiersFR.nafOrApe != '' && objtry.companyIdentifiersFR.nafOrApe != null)
					a.putSObject('Code_NAF_APE_societe_declarante__r', new Reference__c(Key__c = objtry.companyIdentifiersFR.nafOrApe));
			}

			if (objtry.companyAddress != null) {
				a.Adresse1__c = objtry.companyAddress.address;
				a.Adresse2__c = objtry.companyAddress.additionalAddress;
				if (objtry.companyAddress.country != null)
					a.putSObject('Pays_LKP__r', (new Reference__c(Key__c = objtry.companyAddress.country)));
			}

			if (objtry.sg != null)
				a.Code_client_Point_P__c = objtry.sg.codePointP;

			if (cp != null) 
				a.putSObject('Code_postal__r', new Reference__c(Key__c = cp));

			if (Test.isRunningTest()) {a.putSObject('Pays_LKP__r', (new Reference__c(Key__c = 'ZWE')));}
			
			a.RecordTypeId = rtpro.Id;
			if (objtry.sg != null)
				a.Enseignes_de_gestion_Client__c = objtry.sg.enseigneGestion;



			//check validite email
			system.debug('conobj.email = ' + conobj.email);
			if (validateEmail(conobj.email) ) {
				//check existence du contact
				if (cons.size() == 0) {

					c.Email = conobj.email;
					c.MobilePhone = conobj.phone1;
					c.Phone = conobj.phone2;
					c.Title = conobj.role;
					c.Salutation = conobj.title;
					c.Fonction__c = conobj.role;
					c.Contact_Principal_O_N__c = true;
					c.LastName = conobj.lastname;
					c.FirstName = conobj.firstname;
					c.Description = conobj.description;

					c.Account = new Account(SIRET_texte__c = objtry.companyIdentifiersFR.siret);
					String cp_con;
					if (conobj.contactAddress != null && conobj.contactAddress.inseeCode != null && conobj.contactAddress.zipCode != null) {
						cp_con = constructInseeCP(conobj.contactAddress.inseeCode, conobj.contactAddress.zipCode);
						//system.debug('conobj.contactAddress.additionalAddress = ' + conobj.contactAddress.additionalAddress);
						c.Adresse1__c = conobj.contactAddress.address + ' ' + conobj.contactAddress.additionalAddress;
						
						if (conobj.contactAddress.country != null && conobj.contactAddress.country != '')
							c.putSObject('Pays_lkp__r', (new Reference__c(Key__c = conobj.contactAddress.country)));
						else
							c.putSObject('Pays_lkp__r', (new Reference__c(Key__c = 'FRA')));
					}


					if (validateCP(cp_con)) 
						c.putSObject('Code_postal_lkp__r', new Reference__c(Key__c = cp_con));
					 
				} else {
						return getResponse('error', 'Votre email est déjà enregistré, merci de nous contacter au 09 72 72 16 17', null);
					}

				} else {
					return getResponse('error', 'Email invalide', null);
				}

			insert a;
			insert c;

			AccountMethods.generateToken(c.Email, 0, 0, 'Try');

			// try only
			/*for (productListObjet plo : objtry.products.productList) {
				Try__c temp = new Try__c();
				temp.Service__c = plo.name;
				temp.EndDate__c = getDate(plo.endDate);
				temp.Compte__r = new Account(SIRET_texte__c = objtry.companyIdentifiersFR.siret);
				t.add(temp);
			}
			insert t;*/
			// end try

			

			return getResponse('success', '', a.Id);


			} else {

			/*for (Try__c tt : [SELECT Id, Service__c FROM Try__c WHERE Compte__c =:accs[accs.size()-1].id])
				trys.put(tt.Service__c, tt);

			//[SELECT Id, Name FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__c IN (SELECT Id FROM Zuora__Subscription__c WHERE Zuora__Status__c = 'Active') AND NAME LIKE : AND Zuora__Account__c]

			for (productListObjet plo : objtry.products.productList) {
				String var = '%'+plo.name+'%';

				// check Service try deja present
				if (!trys.containsKey(plo.name) &&
					[SELECT Id, Name FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__c IN (SELECT Id FROM Zuora__Subscription__c WHERE Zuora__Status__c = 'Active') AND NAME LIKE :var AND Zuora__Account__c = :accs[accs.size()-1].id].size() == 0) {
					Try__c temp = new Try__c();
					temp.Service__c = plo.name;
					temp.EndDate__c = getDate(plo.endDate);
					temp.Compte__c = accs[accs.size()-1].id;
					t.add(temp);

				} else {
					return getResponse('error', 'Service déja present', accs[accs.size()-1].id);
				}
			}
			insert t;*/
			return getResponse('success', '', accs[accs.size()-1].id);
		}



		/*for (productListObjet plo : objtry.products.productList) {
			Try__c temp = new Try__c();
			temp.EndDate__c = getDate(plo.endDate);
			temp.Compte__r = new Account(SIRET_texte__c = objtry.companyIdentifiersFR.siret);
			t.add(temp);
		}*/

	}

	global static Boolean validateEmail(String email) { 
		Boolean res = true;
		String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
		Pattern MyPattern = Pattern.compile(emailRegex);
		Matcher MyMatcher = MyPattern.matcher(email);

		if (!MyMatcher.matches()) 
			res = false;

		return res;	
	}

	global static Boolean validatePhone(String phone) {

			Boolean res = true;
			String phoneRegex = '^[+]33[1-9]{1}[0-9]{8}$';
			Pattern MyPattern = Pattern.compile(phoneRegex);
			Matcher MyMatcher = MyPattern.matcher(phone);
			
			if (!MyMatcher.matches()) 
			    res = false;
			return res;	
		}

	global static String constructInseeCP(String Insee, String CP) {

		if ( !String.isBlank(Insee) && !String.isBlank(CP) &&
			Insee.isNumeric() && CP.isNumeric() &&
			Insee.length() == 5 && CP.length() == 5) {

			return CP + '_' + Insee;
		} else {
			return null;
		}
	}

	global static Date getDate(String date_param){
			Date d = null;
			if (date_param != null) {
				String[] param = date_param.split('T');
				if (param.size() >= 1){
					String[] param_date = param[0].split('-');
					if (param_date.size() == 3 && param_date[0].isNumeric() && param_date[1].isNumeric() && param_date[2].isNumeric()) {
						d = date.newinstance(Integer.valueOf(param_date[0]), Integer.valueOf(param_date[1]),Integer.valueOf(param_date[2]));
					}
				}
			}
			return d;

		}

	global static ResponseWS getResponse(String status, String message, String idSF) {
		ResponseWS res = new ResponseWS();
		res.status = status;
		res.message = message;
		if (idSF != null) {
			res.createdIdClient = idSF;
		}

		return res;
	}

	global static Boolean validateCP(String cp) {

			Boolean res = true;
			Pattern MyPattern;
			Matcher MyMatcher;

			system.debug('cp = ' + cp);
			if (cp != null) {
				String cpRegex = '^[0-9]{5}_[0-9]{5}$';
				MyPattern = Pattern.compile(cpRegex);
				MyMatcher = MyPattern.matcher(cp);
				system.debug('MyMatcher.matches() = ' + MyMatcher.matches());
			}


			if (MyMatcher == null || !MyMatcher.matches() || cp == null) 
			    res = false;

			return res;	
		}

	global static ResponseWS tryMethods(TryObject objtry, ResponseWS response) {

		Map<String, Try__c> trys = new map<String,Try__c>();
				
		List<Try__c> t = new List<Try__c>();

		if (response.status != 'error') {

			/*for (Zuora__SubscriptionProductCharge__c subch : [SELECT Id, Name FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__c IN (SELECT Id FROM Zuora__Subscription__c WHERE Zuora__Status__c = 'Active') AND Zuora__Account__c = :response.createdIdClient]) {

			}*/

			for (Try__c tt : [SELECT Id, Service__c FROM Try__c WHERE Compte__c =:response.createdIdClient])
					trys.put(tt.Service__c, tt);

				//[SELECT Id, Name FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__c IN (SELECT Id FROM Zuora__Subscription__c WHERE Zuora__Status__c = 'Active') AND NAME LIKE : AND Zuora__Account__c]

				for (productListObjet plo : objtry.products.productList) {
					String var = '%'+plo.name+'%';

					// check Service try deja present
					if (!trys.containsKey(plo.name) &&
						[SELECT Id, Name FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Subscription__c IN (SELECT Id FROM Zuora__Subscription__c WHERE Zuora__Status__c = 'Active') AND NAME LIKE :var AND Zuora__Account__c = :response.createdIdClient].size() == 0) {
						Try__c temp = new Try__c();
						temp.Service__c = plo.name;
						temp.StartDate__c = getDate(plo.startDate);
						temp.EndDate__c = getDate(plo.endDate);
						temp.Compte__c = response.createdIdClient;
						temp.Contact__c = [SELECT Id FROM Contact WHERE Contact_Principal_O_N__c = true AND AccountId = :response.createdIdClient LIMIT 1].Id;
						t.add(temp);

					} else {
						return getResponse('error', 'Service déja present', response.createdIdClient);
					}
				}

				insert t;
				return response;

		} else {

			return response;

		}
	}

	/*
	global static ResponseWS buyMethods(TryObject objtry, ResponseWS response) {

		if (response.status != 'error') {
			Date myDate = date.today();
			RecordType rtpro = [SELECT Id FROM RecordType WHERE DeveloperName = 'Default' AND SobjectType = 'zqu__Quote__c' LIMIT 1];
			Account acc = [SELECT Id, Contact_principal__c FROM Account WHERE Id = :response.createdIdClient LIMIT 1];
			Contact con = [SELECT Id FROM Contact WHERE Id = :acc.Contact_principal__c];
			

			// Recuperation periode de facturation
			String period = objtry.products.billingPeriod;

			productListObjet plo;

			if (objtry.products.productList != null && objtry.products.productList.size() == 1)
				plo = objtry.products.productList[0];
			// fin periode

			// Recuperation GA
			String facturation;

			if (objtry.products.billingPeriod.contains('monthly')) {
				facturation = objtry.products.billingPeriod;
			} else if ([SELECT Id FROM ProgrammeFidelite__c WHERE Compte__c = :response.createdIdClient].size() != 0) {
				facturation = 'Partenaire';
			} else {
				facturation = objtry.products.billingPeriod;
			}

			MAP_BUY__mdt factu = [SELECT Id, DeveloperName, facturation_produit__c, facturation_rate_plan__c FROM MAP_BUY__mdt WHERE DeveloperName = :facturation LIMIT 1];

			Product2 product = [ SELECT Id  FROM Product2 WHERE Family = 'Offre' AND Type_de_facturation__c includes (:factu.facturation_produit__c) AND Name LIKE '%facturation%' LIMIT 1];
			Product2 remise = [ SELECT Id  FROM Product2 WHERE Family = 'Remise' AND Type_de_facturation__c includes (:factu.facturation_produit__c) AND Name LIKE '%facturation%' LIMIT 1]; 
			
			
			zqu.Product singleProduct = zqu.Product.loadProduct(product.Id);
			List<String> allRatePlan = new List<string>();

			List<zqu.ProductRatePlan> listToReset = new List<zqu.ProductRatePlan>();
			for (zqu.ProductRatePlan rpc : singleProduct.productRatePlans) {
				if (rpc.sfdcProductRatePlan.Name.contains(plo.Name)) {
					listToReset.add(rpc);
					allRatePlan.add(rpc.sfdcProductRatePlan.Id);
				}
			}

			singleProduct.productRatePlans.clear();
			singleProduct.productRatePlans.addAll(listToReset);

			zqu.Product singleRemise = zqu.Product.loadProduct(remise.Id);

			listToReset.clear();
			for (zqu.ProductRatePlan rpc : singleRemise.productRatePlans) {
				if (rpc.sfdcProductRatePlan.Name.contains('Privilège')) {
					listToReset.add(rpc);
					allRatePlan.add(rpc.sfdcProductRatePlan.Id);
				}
			}

			singleRemise.productRatePlans.clear();
			singleRemise.productRatePlans.addAll(listToReset);

			system.debug('singleRemise.productRatePlans = ' + singleRemise.productRatePlans);
			system.debug('singleRemise = ' + singleRemise);



			zqu__Quote__c quote = new zqu__Quote__c();
			quote.RecordTypeId = rtpro.Id;
			quote.zqu__account__c = acc.Id;
			quote.zqu__SoldToContact__c = con.Id;
			quote.zqu__BillToContact__c = con.Id;
			quote.zqu__StartDate__c = myDate;
    		quote.zqu__ValidUntil__c = myDate.addMonths(1);
			quote.zqu__Status__c = 'New';
			quote.zqu__SubscriptionType__c = 'New Subscription';
    		quote.zqu__Subscription_Term_Type__c = 'Evergreen';
    		quote.zqu__InvoiceProcessingOption__c = 'Subscription';

    		// Fake Card
    		quote.PM_BillingCountry__c = 'us';
    		//quote.PM_BillingPostalCode__c = '';
    		quote.PM_CardHolderName__c = 'fredo des fredo';
    		//quote.PM_CardNumber__c = '';
    		//quote.PM_CreditCardBrand__c = '';
    		quote.PM_CreditCardType__c = 'Visa';
    		quote.PM_Email__c = 'a@a.a';
    		quote.PM_ExpirationMonth__c = '11';
    		quote.PM_ExpirationYear__c = '2042';
    		quote.PM_SecondTokenId__c = '411111******1111';
    		quote.PM_TokenId__c = 'eb2c7153ac2548f64a9697ce848c0225521077526514519cdac3417463740e6c';

			zqu.Quote quo = zqu.Quote.createNewInstance(quote);
			quo.save();
			quo.addQuoteProducts(new List<zqu.Product> {singleProduct, singleRemise});
			quo.save();
			//system.debug('previewResult = ' + previewResult);
			List<zqu.ZChargeGroup> allCharges = zqu.zQuoteUtil.getChargeGroups(quo.getId());
			list<string> ratePlanIdList = new list<string>();

			/*system.debug('quo = ' + quo);
			for (zqu.QuoteProduct qp : quo.getQuoteProducts()) {
				system.debug('qp.chargeGroup = ' + qp.chargeGroup);
				system.debug('qp.chargeGroup.productRatePlanId = ' + qp.chargeGroup.productRatePlanId);

				ratePlanIdList.add(qp.chargeGroup.productRatePlanId);
				allCharges.add(qp.chargeGroup);
			}*/

			/*

			engineController = new QuoteRulesEnginePluginController();


			//engineController.runProductRules(quo.getSObject(), allRatePlan, new List<zqu.ZQuoteRulesEngine.ChangeLog>());

			//engineController.runValidationRules(quo.getSObject(), allCharges, new List<zqu.ZQuoteRulesEngine.ChangeLog>());

			engineController.runpricerules(allCharges, new List<zqu.ZQuoteRulesEngine.ChangeLog>());
			
			engineController.runValidationRules(quo.getSObject(), allCharges, new List<zqu.ZQuoteRulesEngine.ChangeLog>());
			
			system.debug('');
			system.debug('allCharges = ' + allCharges);
			//allCharges = zqu.zQuoteUtil.updateChargeGroups(allCharges);

			//quo.save();


















			/*

			// Recuperation produit

			String typeFacturation = facturation + period;
			Map<String, zqu__ProductRatePlan__c> productRateplans = new Map<String, zqu__ProductRatePlan__c>();

			productListObjet plo;
			if (objtry.products.productList != null && objtry.products.productList.size() == 1)
				plo = objtry.products.productList[0];

			// Rate plan
			List<zqu__ProductRatePlan__c> rp_current = [SELECT Id, Name, zqu__ZuoraId__c FROM zqu__ProductRatePlan__c WHERE Typedeproduit__c = 'Standalone' AND Name LIKE '%:plo.name%' AND Type_de_facturation__c INCLUDES (':typeFacturation')];

			// Rate plan charge
			List<zqu__ProductRatePlanCharge__c> rpc_current = [SELECT Id, Name FROM zqu__ProductRatePlanCharge__c WHERE zqu__ProductRatePlan__c IN :rp_current];                                       

			// Rate plan charge tier
			List<zqu__ProductRatePlanChargeTier__c> rpct_current = [SELECT Id, Name FROM zqu__ProductRatePlanChargeTier__c WHERE zqu__ProductRatePlanCharge__c IN :rpc_current];
			
			// Construction des map

			// MAP Id product rate plan charge/product rate plan charge tier
			Map<String, zqu__ProductRatePlanChargeTier__c> rpctMap = new Map<String, zqu__ProductRatePlanChargeTier__c>();
			// MAP Id product rate plan/quote rate plan charge
			Map<String, zqu__QuoteRatePlan__c> qrpMap = new Map<String, zqu__QuoteRatePlan__c>();
			for (zqu__ProductRatePlanChargeTier__c prct : rpct_current) {
				rpctMap.put(prct.zqu__ProductRatePlanCharge__c, prct);
			}

			zqu__Quote__c quote = new zqu__Quote__c();
			//quote = zqu.Quote.getInstance(quote.Id);
			
			// Fin recuperation produit

			// construction de la quote
			
			/*List<zqu__Quote__c> quotes = new List<zqu__Quote__c>();
			List<zqu__QuoteAmendment__c> quoteAmendments = new List<zqu__QuoteAmendment__c>(); 
			List<zqu__QuoteRatePlan__c>  quoteRatePlans = new List<zqu__QuoteRatePlan__c>();
			List<zqu__QuoteRatePlanCharge__c> quoteRatePlanCharges = new List<zqu__QuoteRatePlanCharge__c>(); 
			List<zqu__QuoteChargeSummary__c> quoteChargeSummaries = new List<zqu__QuoteChargeSummary__c>();

			
			zqu__Quote__c quote = new zqu__Quote__c();
			quote.RecordTypeId = rtpro.Id;
			quote.zqu__account__c = acc.Id;
			quote.zqu__SoldToContact__c = con.Id;
			quote.zqu__BillToContact__c = con.Id;
			quote.zqu__StartDate__c = myDate;
    		quote.zqu__ValidUntil__c = myDate.addMonths(1);
			quote.zqu__Status__c = 'New';
			quote.zqu__SubscriptionType__c = 'New Subscription';
    		quote.zqu__Subscription_Term_Type__c = 'Evergreen';
    		quote.zqu__InvoiceProcessingOption__c = 'Subscription';
    		quotes.add(quote);

    		insert quote;
			// Fin quote

			// construction des quote rateplan

			
			for (zqu__ProductRatePlan__c rp : rp_current) {
				zqu__QuoteRatePlan__c  quoRatePlan = new zqu__QuoteRatePlan__c();

				quoRatePlan.Name = rp.Name;
				quoRatePlan.zqu__ProductRatePlan__c= rp.Id;
				quoRatePlan.zqu__QuoteProductName__c =  rp.Name;
				quoRatePlan.zqu__ProductRatePlanZuoraId__c = rp.zqu__ZuoraId__c;
				//quoRatePlan.zqu__QuoteAmendment__c = qA.Id;
				quoRatePlan.zqu__Quote__c = quote.Id;
				quoRatePlan.zqu__AmendmentType__c = 'NewProduct';
				quoteRatePlans.add(quoRatePlan);
				qrpMap.put(rp.Id , quoRatePlan);

			}
			//Fin quote rateplan

			// construction des quote rateplan charge
			for (zqu__ProductRatePlanCharge__c rpc : rpc_current) {
				zqu__QuoteRatePlanCharge__c quoRatePlanCharge = new zqu__QuoteRatePlanCharge__c(); 
				quoRatePlanCharge.Name = rpc.Name;
				quoRatePlanCharge.zqu__QuoteRatePlan__c = qrpMap.get(rpc.zqu__ProductRatePlan__c).Id;
				quoRatePlanCharge.zqu__ProductRatePlanCharge__c = rpc.Id;
				quoRatePlanCharge.zqu__Quantity__c = 1;
				quoRatePlanCharge.zqu__ChargeType__c = rpc.zqu__Type__c;
				quoRatePlanCharge.zqu__Model__c = rpc.zqu__Model__c;
				quoRatePlanCharge.zqu__FeeType__c = rpctMap.get(rpc.Id).zqu__PriceFormat__c;
				quoRatePlanCharge.zqu__ProductRatePlanChargeZuoraId__c = rpc.zqu__ZuoraId__c;
				quoRatePlanCharge.HYRatePlanChargeID__c = rpc.HYRatePlanChargeID__c;
				quoRatePlanCharge.zqu__Total__c = rpctMap.get(rpc.Id).zqu__Price__c;
				quoRatePlanCharge.zqu__ListTotal__c = rpctMap.get(rpc.Id).zqu__Price__c;
				quoRatePlanCharge.zqu__ListPrice__c = rpctMap.get(rpc.Id).zqu__Price__c;
				quoRatePlanCharge.zqu__EffectivePrice__c = rpctMap.get(rpc.Id).zqu__Price__c;
				quoRatePlanCharge.zqu__Description__c = rpc.Name;
				quoRatePlanCharge.zqu__Currency__c = rpctMap.get(rpc.Id).zqu__Currency__c;
				
				//quoRatePlanCharge.zqu__TCV__c = 0.0;
				//quoRatePlanCharge.zqu__MRR__c = 0.0;
			}
			// Fin quotes rateplan charge
			*/
			

			/*
		} else {
			return response;
		}
		return response;
	}*/
}