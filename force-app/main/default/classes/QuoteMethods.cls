// 19/07/2017, Qiuyan Liu, EB114, add function checkRTPostResiliation change the quote to Post Résiliation record type if needed
public class QuoteMethods 
{

//--------------------------- Calculate amendment modifications--------------------------
//Calculate Quote amendment details
public static void AmendmentDetails(List<zqu__Quote__c> lQuote)
{
    List<id> lQuoteId = new List<Id>();
    for (zqu__Quote__c quo : lQuote)    
    lQuoteId.add(quo.Id);

    // Get the Quote Amendment related to the quote
    List<zqu__QuoteChargeSummary__c> lQuoteChargeSummary = [SELECT zqu__QuoteRatePlan__r.Name, zqu__QuoteRatePlan__r.zqu__Quote__c,zqu__QuoteRatePlan__r.zqu__AmendmentType__c,id,Name,zqu__EffectivePrice__c,zqu__Type__c,zqu__Quantity__c,zqu__Model__c,zqu__TotalPrice__c,IsDeleted FROM zqu__QuoteChargeSummary__c WHERE IsDeleted = false AND zqu__QuoteRatePlan__r.zqu__Quote__c in: lQuoteId];
    
     
    if (lQuoteChargeSummary != null && lQuoteChargeSummary.size() > 0)
    {
        // Go through the quotes
        for (zqu__Quote__c quo : lQuote)
        {
            
            String lTxtDetailOffres = '';
            Decimal lFofaitActivation = 0;
            Decimal IAbonnementCap = 0;
            Integer ILicence = 0;
            Integer IlicenceNew = 0;
            Integer IlicenceNewsupp = 0;
            Integer ILicencesSupprimees = 0;
      String lTdStyle = 'valign="top" class="textContent espacetext hy" style="mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;color: #404040;font-family: Helvetica;font-size: 16px;line-height: 1.8;text-align: Left;padding-bottom: 20px;"';
            
            //Init the table
            lTxtDetailOffres += '<table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse;mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;">';
            
            // Debut --- Si le panier comporte l’ajout d’une offre de désignation  «Abonnement Offre Homly Travaux» :---------------
            for (zqu__QuoteChargeSummary__c ChargeSammary : lQuoteChargeSummary)
            {
                if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__Quote__c == quo.id)
                if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c =='NewProduct' && ChargeSammary.Name == 'Abonnement Offre Homly Travaux' )
                {       
                        //put the details
                        lTxtDetailOffres += '<tr><td '+lTdStyle+'><span style="text-decoration: underline;"><b>Votre abonnement Homly Travaux</b></span><br>Vous avez souscrit à l\'offre Homly Travaux pour obtenir des opportunités de chantier qualifiées, sur les catégories de travaux que vous avez choisies.<br><span style="text-decoration: underline;">Tarification du service</span>: <b>'+Integer.valueOf(ChargeSammary.zqu__EffectivePrice__c)+'€ HT/mois</b> + prix à l\'usage (opportunité de chantier reçue) selon la grille tarifaire en vigueur ci-jointe : <b>10€, 20€ ou 30€ HT</b> en fonction de la catégorie des travaux.<br> TVA applicable sur l\'abonnement et les usages : 20%</td></tr>';
                }
            
            }
            // Fin --- Si le panier comporte l’ajout d’une offre de désignation  «Abonnement Offre Homly Travaux» :------------------------------
            
            // Debut ----- Si le panier comporte l’ajout d’une offre de désignation  « Activation CapRenov+ » ou "bonnement CapRenov+"------------------------------------
            for (zqu__QuoteChargeSummary__c ChargeSammary : lQuoteChargeSummary)
            {
                if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__Quote__c == quo.id)
                {
                    if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c =='NewProduct' && (ChargeSammary.Name == 'Abonnement CapRenov+'))
                    // Si le panier comporte l’ajout d’une offre de désignation  « Activation CapRenov+ »  :
                    if (ChargeSammary.Name == 'Activation CapRenov+')
                    {       
                         lFofaitActivation += ChargeSammary.zqu__TotalPrice__c;//Integer.valueOf(ChargeSammary.zqu__EffectivePrice__c) ; // Récupérer le montant du forfait
                        
                    }
                    else // Récupérer le nombre de licences ainsi que le montant d'abonnement à payer 
                    if (ChargeSammary.zqu__Model__c =='Per Unit Pricing') // ligne de licences non dégroupées (Model ='Per Unit Pricing' )
                    {
                        IAbonnementCap += ChargeSammary.zqu__TotalPrice__c;//Integer.valueOf(ChargeSammary.zqu__Quantity__c*ChargeSammary.zqu__EffectivePrice__c);
                        ILicence += Integer.valueOf(ChargeSammary.zqu__Quantity__c); 
                    }

                    // Rajout Fred comptage des nouveaux caprenov 
                    System.debug('remove ChargeSammary.Name = ' + ChargeSammary.Name);
                    System.debug('remove Service "Simulateur d’efficacité énergétique" || ' + ChargeSammary.Name );
                    if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c =='NewProduct' && ChargeSammary.Name == 'Service \'\'Simulateur d’efficacité énergétique Cap Renov+\'\'') {
                        IlicenceNew ++;
                    }

                    if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c =='RemoveProduct' && ChargeSammary.Name == 'Service \'\'Simulateur d’efficacité énergétique Cap Renov+\'\'') {
                        //IlicenceNewsupp += Integer.valueOf(ChargeSammary.zqu__Quantity__c);
                        IlicenceNewsupp ++;
                        System.debug('remove ChargeSammary.Name pass');
                        System.debug('IlicenceNewsupp = ' + IlicenceNewsupp);

                    }
                    // fin du rajout
                }   
            }
            
            if (ILicence == 1) // Cas de rajout d'une seule licence : permet d'adapter le texte à afficher
            {
                if (lFofaitActivation>0) // cas d'existance d'un forfait d'activation
                {
                        //Message à afficher
                      //lTxtDetailOffres += '<tr><td '+lTdStyle+'><span style="text-decoration: underline;"><b>Votre abonnement Cap Renov+</b></span><br> Vous venez de vous abonner au logiciel d\'évaluation thermique <b>Cap Renov+ avec une licence associée.</b><br>Les clés logicielles vous seront communiquées dès activation de votre souscription.<br><span style="text-decoration: underline;">Tarification de l\'abonnement</span> : <b>'+lFofaitActivation.format()+'€ HT</b> de frais d\'activation <b>+ '+IAbonnementCap.format()+'€ HT/mois pour une licence.</b><br>TVA applicable sur l\'abonnement et les frais d\'activation : 20%</td></tr>';
                      lTxtDetailOffres += '<tr><td '+lTdStyle+'><span style="text-decoration: underline;"><b>Votre abonnement Cap Renov+</b></span><br> Vous venez de vous abonner au logiciel d\'évaluation thermique <b>Cap Renov+ avec une licence associée.</b><br>Les identifiants de connexion et les modalités d’installation vous seront communiqués dès activation de votre souscription.<br><span style="text-decoration: underline;">Tarification de l\'abonnement</span> : <b>'+lFofaitActivation.format()+'€ HT</b> de frais d\'activation <b>+ '+IAbonnementCap.format()+'€ HT/mois pour une licence.</b><br>TVA applicable sur l\'abonnement et les frais d\'activation : 20%</td></tr>';
                }
                else //cas de non existance de forfait d'activation, rajout uniquement d'une seule licence
                {
                       //Message à afficher
                      //lTxtDetailOffres += '<tr><td '+lTdStyle+'><span style="text-decoration: underline;"><b>Vos licences complémentaires Cap Renov+</b></span><br> Vous avez souscrit <b>une licence complémentaire Cap Renov+.</b><br>Les clés logicielles vous seront communiquées dès activation de votre souscription.<br><span style="text-decoration: underline;">Tarification de l\'abonnement</span> : <b>'+IAbonnementCap.format()+'€ HT/mois pour une licence.</b><br>TVA applicable sur l’abonnement : 20%</td></tr>';
                      //lTxtDetailOffres += '<tr><td '+lTdStyle+'><span style="text-decoration: underline;"><b>Vos licences complémentaires Cap Renov+</b></span><br> Vous avez souscrit <b>une licence complémentaire Cap Renov+.</b><br>Les identifiants de connexion et les modalités d’installation vous seront communiqués dès activation de votre souscription.<br><span style="text-decoration: underline;">Tarification de l\'abonnement</span> : <b>'+IAbonnementCap.format()+'€ HT/mois pour une licence.</b><br>TVA applicable sur l’abonnement : 20%</td></tr>';
                      lTxtDetailOffres += '<tr><td '+lTdStyle+'><span style="text-decoration: underline;"><b>Vos licences Cap Renov+</b></span><br> Vous avez souscrit à notre logiciel d\'évaluation thermique <b>Cap Renov+ (une licence).</b><br>Les identifiants de connexion et les modalités d’installation vous seront communiqués dès activation de votre souscription.<br><span style="text-decoration: underline;">Tarification de l\'abonnement</span> : <b>'+IAbonnementCap.format()+'€ HT/mois pour une licence.</b><br>TVA applicable sur l\'abonnement : 20%</td></tr>';
                }
                
            }
            else
            if (ILicence >1) //Cas de rajout de plusieurs licences : permet d'adapter le texte à afficher
            {
                if (lFofaitActivation>0) //cas d'existance d'un forfait d'activation
                {
                            //put the details
                      //lTxtDetailOffres += '<tr><td '+lTdStyle+'><span style="text-decoration: underline;"><b>Votre abonnement Cap Renov+</b></span><br> Vous venez de vous abonner au logiciel d\'évaluation thermique <b>Cap Renov+ avec '+ILicence+' licences associées.</b><br>Les clés logicielles vous seront communiquées dès activation de votre souscription.<br><span style="text-decoration: underline;">Tarification de l\'abonnement</span> : <b>'+lFofaitActivation.format()+'€ HT</b> de frais d\'activation <b>+ '+IAbonnementCap.format()+'€ HT/mois pour '+ILicence+' licences.</b><br>TVA applicable sur l\'abonnement et les frais d\'activation : 20%</td></tr>';
                      lTxtDetailOffres += '<tr><td '+lTdStyle+'><span style="text-decoration: underline;"><b>Votre abonnement Cap Renov+</b></span><br> Vous venez de vous abonner au logiciel d\'évaluation thermique <b>Cap Renov+ avec '+ILicence+' licences associées.</b><br>Les identifiants de connexion et les modalités d’installation vous seront communiqués dès activation de votre souscription.<br><span style="text-decoration: underline;">Tarification de l\'abonnement</span> : <b>'+lFofaitActivation.format()+'€ HT</b> de frais d\'activation <b>+ '+IAbonnementCap.format()+'€ HT/mois pour '+ILicence+' licences.</b><br>TVA applicable sur l\'abonnement et les frais d\'activation : 20%</td></tr>';
                }
                else //cas de non existance de forfait d'activation, rajout uniquement de plusieurs licences
                {
                       //put the details
                      //lTxtDetailOffres += '<tr><td '+lTdStyle+'><span style="text-decoration: underline;"><b>Vos licences complémentaires Cap Renov+</b></span><br> Vous avez souscrit <b>'+ILicence+' licences complémentaires Cap Renov+.</b><br>Les clés logicielles vous seront communiquées dès activation de votre souscription.<br><span style="text-decoration: underline;">Tarification de l\'abonnement</span> : <b>'+IAbonnementCap.format()+'€ HT/mois pour '+ILicence+' licences.</b><br>TVA applicable sur l\'abonnement : 20%</td></tr>';
                      //lTxtDetailOffres += '<tr><td '+lTdStyle+'><span style="text-decoration: underline;"><b>Vos licences complémentaires Cap Renov+</b></span><br> Vous avez souscrit <b>'+ILicence+' licences complémentaires Cap Renov+.</b><br>Les identifiants de connexion et les modalités d’installation vous seront communiqués dès activation de votre souscription.<br><span style="text-decoration: underline;">Tarification de l\'abonnement</span> : <b>'+IAbonnementCap.format()+'€ HT/mois pour '+ILicence+' licences.</b><br>TVA applicable sur l\'abonnement : 20%</td></tr>';
                      lTxtDetailOffres += '<tr><td '+lTdStyle+'><span style="text-decoration: underline;"><b>Vos licences Cap Renov+</b></span><br> Vous avez souscrit à notre logiciel d\'évaluation thermique <b>Cap Renov+ ('+ILicence+' licences).</b><br>Les identifiants de connexion et les modalités d’installation vous seront communiqués dès activation de votre souscription.<br><span style="text-decoration: underline;">Tarification de l\'abonnement</span> : <b>'+IAbonnementCap.format()+'€ HT/mois pour '+ILicence+' licences.</b><br>TVA applicable sur l\'abonnement : 20%</td></tr>';

                }              
                
            }
            // Fin ----- Si le panier comporte l’ajout d’une offre de désignation  « Activation CapRenov+ » ou "bonnement CapRenov+"------------------------------------
            
            
            //Debut --------Si le panier comporte l’ajout d’une offre de désignation  « Remise - 1 mois d'abonnement Homly Travaux offert» :------------------
            for (zqu__QuoteChargeSummary__c ChargeSammary : lQuoteChargeSummary)
             {
                if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__Quote__c == quo.id)
                if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c =='NewProduct' && ChargeSammary.Name == 'Remise - 1 mois d\'abonnement Homly Travaux offert' )
                {  
                    //texte à afficher
                    lTxtDetailOffres += '<tr><td '+lTdStyle+'><font color="#e9425c"><span style="text-decoration: underline;"><b>Remise exceptionnelle : 1 mois d\'abonnement Homly Travaux offert</b></span></font><br>Une remise exceptionnelle égale à un mois d\'abonnement Homly Travaux sera appliquée sur votre prochaine facture, soit<b>  '+ChargeSammary.zqu__EffectivePrice__c.format()+'€ HT </b>pendant un mois !<br>TVA applicable sur  cette remise : 20%</td></tr>';
                }
            
             }
            //Fin --------Si le panier comporte l’ajout d’une offre de désignation  « Remise - 1 mois d'abonnement Homly Travaux offert» :------------------------
            
            //Debut --------Si le panier comporte l’ajout d’une offre de désignation  « Remise - abonnement Homly Travaux offert pendant 2 mois» :------------------
            for (zqu__QuoteChargeSummary__c ChargeSammary : lQuoteChargeSummary)
             {
                if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__Quote__c == quo.id)
                if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c =='NewProduct' && ChargeSammary.Name == 'Remise - abonnement Homly Travaux offert pendant 2 mois' )
                {  
                    //texte à afficher
                    lTxtDetailOffres += '<tr><td '+lTdStyle+'><font color="#e9425c"><span style="text-decoration: underline;"><b>Remise exceptionnelle : 2 mois d\'abonnement Homly Travaux offert</b></span></font><br>Une remise exceptionnelle égale à un mois d\'abonnement Homly Travaux sera appliquée sur votre prochaine facture et la suivante, soit<b>  '+ChargeSammary.zqu__EffectivePrice__c.format()+'€ HT </b>pendant 2 mois !<br>TVA applicable sur  cette remise : 20%</td></tr>';
                }
            
             }
            //Fin --------Si le panier comporte l’ajout d’une offre de désignation  « Remise - abonnement Homly Travaux offert pendant 2 mois» :------------------------
            
             //Debut --------Si le panier comporte l’ajout d’une offre de désignation  « Remise - abonnement Homly Travaux offert pendant 3 mois» :------------------
            for (zqu__QuoteChargeSummary__c ChargeSammary : lQuoteChargeSummary)
             {
                if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__Quote__c == quo.id)
                if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c =='NewProduct' && ChargeSammary.Name == 'Remise - abonnement Homly Travaux offert pendant 3 mois' )
                {  
                    //texte à afficher
                    lTxtDetailOffres += '<tr><td '+lTdStyle+'><font color="#e9425c"><span style="text-decoration: underline;"><b>Remise exceptionnelle : 3 mois d\'abonnement Homly Travaux offert</b></span></font><br>Une remise exceptionnelle égale à un mois d\'abonnement Homly Travaux sera appliquée sur votre prochaine facture et les 2 suivantes, soit<b>  '+ChargeSammary.zqu__EffectivePrice__c.format()+'€ HT </b>pendant 3 mois !<br>TVA applicable sur  cette remise : 20%</td></tr>';
                }
            
             }
            //Fin --------Si le panier comporte l’ajout d’une offre de désignation  « Remise - abonnement Homly Travaux offert pendant 3 mois»  :------------------------
            

             //Debut --------Si le panier comporte l’ajout d’une offre de désignation  « Remise - abonnement CapRenov+ offert pendant 1 mois » :------------------
            for (zqu__QuoteChargeSummary__c ChargeSammary : lQuoteChargeSummary)
             {
                if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__Quote__c == quo.id)
                if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c =='NewProduct' && ChargeSammary.Name == 'Remise - abonnement CapRenov+ offert pendant 1 mois' )
                {  
                    
                    if (Integer.valueOf(ChargeSammary.zqu__Quantity__c) ==1) // Cas de rajout d'une remise sur une seule licence : permet d'adapter le texte à afficher
                    {
                        //texte à afficher
                        lTxtDetailOffres += '<tr><td '+lTdStyle+'><font color="#e9425c"><span style="text-decoration: underline;"><b>Remise exceptionnelle : 1 mois d\'abonnement Cap Renov+ offert</b></span></font><br>Une remise exceptionnelle égale à un mois d\'abonnement Cap Renov+ pour une licence sera appliquée sur votre prochaine facture d\'activation de votre service, soit  <b>'+ChargeSammary.zqu__TotalPrice__c.format()+'€ HT</b> pendant un mois !<br>TVA applicable sur  cette remise : 20%</td></tr>';
 
                    }
                    else
                    if (Integer.valueOf(ChargeSammary.zqu__Quantity__c) >1) // Cas de rajout d'une remise pour plusiers licences : permet d'adapter le texte à afficher
                    {
                        //texte à afficher
                        lTxtDetailOffres += '<tr><td '+lTdStyle+'><font color="#e9425c"><span style="text-decoration: underline;"><b>Remise exceptionnelle : 1 mois d\'abonnement Cap Renov+ offert</b></span></font><br>Une remise exceptionnelle égale à un mois d\'abonnement Cap Renov+ pour '+Integer.valueOf(ChargeSammary.zqu__Quantity__c)+' licences sera appliquée sur votre prochaine facture, soit  <b>'+ChargeSammary.zqu__TotalPrice__c.format()+'€ HT</b> pendant un mois !<br>TVA applicable sur  cette remise : 20%</td></tr>';

                    }
                    

                }
            
             }
            //Fin --------Si le panier comporte l’ajout d’une offre de désignation  « Remise - abonnement CapRenov+ offert pendant 1 mois »  :------------------------




             //Debut --------Si le panier comporte l’ajout d’une offre de désignation  « Remise - abonnement CapRenov+ offert pendant 2 mois » :------------------
            for (zqu__QuoteChargeSummary__c ChargeSammary : lQuoteChargeSummary)
             {
                if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__Quote__c == quo.id)
                if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c =='NewProduct' && ChargeSammary.Name == 'Remise - abonnement CapRenov+ offert pendant 2 mois' )
                {  
                    
                    if (Integer.valueOf(ChargeSammary.zqu__Quantity__c) ==1) // Cas de rajout d'une remise sur une seule licence : permet d'adapter le texte à afficher
                    {
                        //texte à afficher
                        lTxtDetailOffres += '<tr><td '+lTdStyle+'><font color="#e9425c"><span style="text-decoration: underline;"><b>Remise exceptionnelle : 2 mois d\'abonnement Cap Renov+ offert</b></span></font><br>Une remise exceptionnelle égale à un mois d\'abonnement Cap Renov+ pour une licence sera appliquée sur votre prochaine facture et la suivante, soit  <b>'+ChargeSammary.zqu__TotalPrice__c.format()+'€ HT</b> pendant 2 mois !<br>TVA applicable sur  cette remise : 20%</td></tr>';
 
                    }
                    else
                    if (Integer.valueOf(ChargeSammary.zqu__Quantity__c) >1) // Cas de rajout d'une remise pour plusiers licences : permet d'adapter le texte à afficher
                    {
                        //texte à afficher
                        lTxtDetailOffres += '<tr><td '+lTdStyle+'><font color="#e9425c"><span style="text-decoration: underline;"><b>Remise exceptionnelle : 2 mois d\'abonnement Cap Renov+ offert</b></span></font><br>Une remise exceptionnelle égale à un mois d\'abonnement Cap Renov+ pour '+Integer.valueOf(ChargeSammary.zqu__Quantity__c)+' licences sera appliquée sur votre prochaine facture et la suivante, soit  <b>'+ChargeSammary.zqu__TotalPrice__c.format()+'€ HT</b> pendant 2 mois !<br>TVA applicable sur  cette remise : 20%</td></tr>';

                    }
                    

                }
            
             }
            //Fin --------Si le panier comporte l’ajout d’une offre de désignation  « Remise - abonnement CapRenov+ offert pendant 2 mois »  :------------------------



             //Debut --------Si le panier comporte l’ajout d’une offre de désignation  « Remise - abonnement CapRenov+ offert pendant 3 mois » :------------------
            for (zqu__QuoteChargeSummary__c ChargeSammary : lQuoteChargeSummary)
             {
                if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__Quote__c == quo.id)
                if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c =='NewProduct' && ChargeSammary.Name == 'Remise - abonnement CapRenov+ offert pendant 3 mois' )
                {  
                    
                    if (Integer.valueOf(ChargeSammary.zqu__Quantity__c) ==1) // Cas de rajout d'une remise sur une seule licence : permet d'adapter le texte à afficher
                    {
                        //texte à afficher
                        lTxtDetailOffres += '<tr><td '+lTdStyle+'><font color="#e9425c"><span style="text-decoration: underline;"><b>Remise exceptionnelle : 3 mois d\'abonnement Cap Renov+ offert</b></span></font><br>Une remise exceptionnelle égale à un mois d\'abonnement Cap Renov+ pour une licence sera appliquée sur votre prochaine facture et les 2 suivantes, soit  <b>'+ChargeSammary.zqu__TotalPrice__c.format()+'€ HT</b> pendant 3 mois !<br>TVA applicable sur  cette remise : 20%</td></tr>';
 
                    }
                    else
                    if (Integer.valueOf(ChargeSammary.zqu__Quantity__c) >1) // Cas de rajout d'une remise pour plusiers licences : permet d'adapter le texte à afficher
                    {
                        //texte à afficher
                        lTxtDetailOffres += '<tr><td '+lTdStyle+'><font color="#e9425c"><span style="text-decoration: underline;"><b>Remise exceptionnelle : 3 mois d\'abonnement Cap Renov+ offert</b></span></font><br>Une remise exceptionnelle égale à un mois d\'abonnement Cap Renov+ pour '+Integer.valueOf(ChargeSammary.zqu__Quantity__c)+' licences sera appliquée sur votre prochaine facture et les 2 suivantes, soit  <b>'+ChargeSammary.zqu__TotalPrice__c.format()+'€ HT</b> pendant 3 mois !<br>TVA applicable sur  cette remise : 20%</td></tr>';

                    }
                    

                }
            
             }
            //Fin --------Si le panier comporte l’ajout d’une offre de désignation  « Remise - abonnement CapRenov+ offert pendant 3 mois »  :------------------------

             //Debut --------Si le panier comporte l’ajout d’une offre de désignation  « Remise exceptionnelle » ::------------------
            for (zqu__QuoteChargeSummary__c ChargeSammary : lQuoteChargeSummary)
             {
                if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__Quote__c == quo.id)
                if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c =='NewProduct' && ChargeSammary.Name == 'Remise exceptionnelle' )
                {  
                    
                     //texte à afficher
                    lTxtDetailOffres += '<tr><td '+lTdStyle+'><font color="#e9425c"><span style="text-decoration: underline;"><b>Remise exceptionnelle</b></span></font><br>Une remise exceptionnelle égale à <b>'+ChargeSammary.zqu__EffectivePrice__c.format()+'€ HT</b> sera appliquée sur votre prochaine facture!<br>TVA applicable sur  cette remise : 20%</td></tr>';

                }
            
             }
            //Fin --------Si le panier comporte l’ajout d’une offre de désignation  « Remise exceptionnelle »   :------------------------


             //Debut --------Si le panier comporte la suppression d’une offre de désignation  « Abonnement Offre Homly Travaux » :------------------
            for (zqu__QuoteChargeSummary__c ChargeSammary : lQuoteChargeSummary)
             {
                if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__Quote__c == quo.id)
                if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c =='RemoveProduct' && ChargeSammary.Name == 'Abonnement Offre Homly Travaux' )
                {  
                    //texte à afficher
                     lTxtDetailOffres += '<tr><td '+lTdStyle+'><span style="text-decoration: underline;"><b>Fin de votre abonnement Homly Travaux</b></span><br>Vous avez  désiré mettre fin à votre offre Homly  Travaux.<br>A partir de la date convenue, vous ne recevrez plus d\'opportunités de chantiers.</td></tr>';

                }
            
             }
             //Fin --------Si le panier comporte la suppression d’une offre de désignation  « Abonnement Offre Homly Travaux » ::------------------------
             
            
             //Debut --------Si le panier comporte la suppression de plusieurs offres de désignation  « Abonnement Cap Renov+ » :------------------
            for (zqu__QuoteChargeSummary__c ChargeSammary : lQuoteChargeSummary)
             {
              if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__Quote__c == quo.id)
              if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c =='RemoveProduct' && ChargeSammary.Name == 'Abonnement CapRenov+' )
              {  
                // nombre de licences supprimée
                ILicencesSupprimees +=1;
            
              }
            
             }
             
             if (ILicencesSupprimees==1)
             {
                    //texte à afficher
                     lTxtDetailOffres += '<tr><td '+lTdStyle+'><span style="text-decoration: underline;"><b>Arrêt de licence Cap Renov+</b></span><br>Vous avez désiré mettre fin à <b>une licence Cap Renov+.</b><br>A partir de la date convenue, vous ne pourrez plus utiliser votre logiciel avec cette licence.</td></tr>';
                 
             }
             else
             if (ILicencesSupprimees>1)
             {
                    //texte à afficher
                     lTxtDetailOffres += '<tr><td '+lTdStyle+'><span style="text-decoration: underline;"><b>Arrêt de licences Cap Renov+</b></span><br>Vous avez désiré mettre fin à <b>'+ILicencesSupprimees+' licences Cap Renov+.</b><br>A partir de la date convenue, vous ne pourrez plus utiliser votre logiciel avec ces licences.</td></tr>';
                 
             }
             
             //Fin --------OU Si le panier comporte la suppression de plusieurs offres de désignation  « Abonnement Cap Renov+ » :------------------------
            
            //@Starts, modified by Qiuyan Liu
            Map<Integer, String[]> amendmentDetailMap = new Map<Integer, String[]>();
            amendmentDetailMapInit(amendmentDetailMap);
            
            for (Integer key : amendmentDetailMap.keyset()) {
               for (zqu__QuoteChargeSummary__c ChargeSammary : lQuoteChargeSummary)
               {
                  if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__Quote__c == quo.id) {
                    String[] details = amendmentDetailMap.get(key);
                    System.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ChargeSammary.Name ' + ChargeSammary.Name);
                    System.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ChargeSammary ' + ChargeSammary);
                    System.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!! key ' + key);
                    System.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!! details ' + details);
                    System.debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ChargeSammary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c ' + ChargeSammary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c);
                    if (ChargeSammary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c == details[1] && ChargeSammary.Name == details[0] && (ChargeSammary.zqu__EffectivePrice__c < 0 || ChargeSammary.zqu__EffectivePrice__c > 0))
                    {  
                        //texte à afficher
                        lTxtDetailOffres += '<tr><td '+lTdStyle+'><font color="#e9425c"><span style="text-decoration: underline;"><b>' + details[2] + details[3] + (details[4] != '<br>'?ChargeSammary.zqu__EffectivePrice__c.format():'') + details[4] + details[5];
                    }
                  }
               }
            }
            
            //@ends, modified by Qiuyan Liu

            // Modif Fred
            Map<Integer, String[]> amendmentNew = new Map<Integer, String[]>();
            Map<Integer, String[]> amendmentQty = new Map<Integer, String[]>();
            DescriptionMailQuote.amendmentRefont(amendmentNew);
            DescriptionMailQuote.amendmentQuantity(amendmentQty);

            if (IlicenceNew > 0 )
            {
                for (Integer key : amendmentQty.keyset()) {
                    for (zqu__QuoteChargeSummary__c ChargeSummary : lQuoteChargeSummary) {
                        String[] details = amendmentQty.get(key);

                        System.debug('********* key ' + key);
                        System.debug('********* details ' + details);
                        System.debug('********* ChargeSummary ' + ChargeSummary);
                        System.debug('********* ChargeSummary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c ' + ChargeSummary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c);
                        System.debug('********* ChargeSummary.zqu__QuoteRatePlan__r.Name = ' + ChargeSummary.zqu__QuoteRatePlan__r.Name);
                        System.debug('********* ChargeSummary.Name = ' + ChargeSummary.Name);
                        System.debug('********* details[7] = ' + details[7]);
                        System.debug('********* details[0] = ' + details[0]);

                        if (ChargeSummary.zqu__QuoteRatePlan__r.zqu__Quote__c == quo.id &&
                            ChargeSummary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c == details[1] &&
                            ChargeSummary.zqu__QuoteRatePlan__r.Name == details[0] &&
                            ChargeSummary.Name == details[7]) {
                            if (!lTxtDetailOffres.contains(details[2]))
                                lTxtDetailOffres += '<tr><td '+lTdStyle+'><b>' + details[2] + details[3] + IlicenceNew.format() +(IlicenceNew > 1 ? ' licences':' licence') +details[4] + (ChargeSummary.zqu__EffectivePrice__c.setscale(2)).format() + details[5] + details[6];
                        }
                    }
                }
            }

            for (Integer key : amendmentNew.keyset()) {
                for (zqu__QuoteChargeSummary__c ChargeSummary : lQuoteChargeSummary) {

                    if (ChargeSummary.zqu__QuoteRatePlan__r.zqu__Quote__c == quo.id) {
                        String[] details = amendmentNew.get(key);

                        System.debug('*********' + ChargeSummary.Name+' key ' + key);
                        System.debug('*********' + ChargeSummary.Name+' key ' + key+' details ' + details);
                        System.debug('*********' + ChargeSummary.Name+' key ' + key+' ChargeSummary ' + ChargeSummary);
                        System.debug('*********' + ChargeSummary.Name+' key ' + key+' ChargeSummary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c ' + ChargeSummary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c);
                        System.debug('*********' + ChargeSummary.Name+' key ' + key+' ChargeSummary.zqu__QuoteRatePlan__r.Name = ' + ChargeSummary.zqu__QuoteRatePlan__r.Name);
                        System.debug('*********' + ChargeSummary.Name+' key ' + key+' ChargeSummary.Name = ' + ChargeSummary.Name);
                        System.debug('*********' + ChargeSummary.Name+' key ' + key+' details[6] = ' + details[6]);
                        System.debug('*********' + ChargeSummary.Name+' key ' + key+' details[0] = ' + details[0]);
                        System.debug('*********' + ChargeSummary.Name+' key ' + key+' details[1] = ' + details[1]);
                        System.debug('*********' + ChargeSummary.Name+' key ' + key+' ChargeSummary.zqu__EffectivePrice__c ' + ChargeSummary.zqu__EffectivePrice__c);

                        if (key == 28 || key == 22) {
                            System.debug('ChargeSummary.zqu__QuoteRatePlan__r.Name == details[0] || ' + ChargeSummary.zqu__QuoteRatePlan__r.Name + ' == ' + details[0]);
                            System.debug('ChargeSummary.Name == details[6] || ' + ChargeSummary.Name + ' == ' + details[6]);
                        }
                        
                        if (ChargeSummary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c == details[1] &&
                            ChargeSummary.zqu__QuoteRatePlan__r.Name == details[0] && 
                            ChargeSummary.Name == details[6] &&
                            (ChargeSummary.zqu__EffectivePrice__c < 0 || ChargeSummary.zqu__EffectivePrice__c > 0)) {
                            System.debug('********* OKKK ' + ChargeSummary.zqu__QuoteRatePlan__r.Name);
                            String fraisInstallation = '';
                            if(key == 53 || key == 54){
                                fraisInstallation = details[7];
                            }
                            lTxtDetailOffres += '<tr><td '+lTdStyle+'><b>' + details[2] + details[3] + (ChargeSummary.zqu__EffectivePrice__c.setscale(2)).format() + details[4] + fraisInstallation + details[5];
                        }

                        if (ChargeSummary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c == 'RemoveProduct' &&
                            ChargeSummary.Name == details[6] &&
                            (key < 39 || key == 53 || key == 54)) {
                            if (!lTxtDetailOffres.contains('Fin de votre abonnement ' + details[6]) && !details[0].contains('Remise'))
                                lTxtDetailOffres += '<tr><td '+lTdStyle+'><font color="black"><span style="text-decoration: underline;"><b>Fin de votre abonnement ' + details[6] + '</b></span></font><br>Vous avez désiré mettre fin à votre ' +  details[6] +'.<br>A partir de la date convenue,' + DescriptionMailQuote.endofOffre(details[6]);//' vous ne recevrez plus d\'opportunités de chantiers.';

                        }
                    }
                }
            }

            if (IlicenceNewsupp > 0 ) {
                for (Integer key : amendmentQty.keyset()) {
                    for (zqu__QuoteChargeSummary__c ChargeSummary : lQuoteChargeSummary) {
                        String[] details = amendmentQty.get(key);
                        //System.debug('ChargeSummary.Name == details[7] || ' + ChargeSummary.Name + ' || ' + details[7]);
                        //System.debug('ChargeSummary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c == ' + ChargeSummary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c);
                        
                        if (ChargeSummary.zqu__QuoteRatePlan__r.zqu__Quote__c == quo.id &&
                            ChargeSummary.zqu__QuoteRatePlan__r.zqu__AmendmentType__c == 'RemoveProduct' &&
                            ChargeSummary.Name == details[7]) {
                            if (!lTxtDetailOffres.contains('Arrêt de licence(s)'))
                                lTxtDetailOffres += '<tr><td '+lTdStyle+'><span style="text-decoration: underline;"><b>Arrêt de licence(s) ' + details[7] + '</b></span><br>Vous avez désiré mettre fin à <b>'+ IlicenceNewsupp.format() +(IlicenceNewsupp > 1?' licences ': ' licence ')+'.</b><br>A partir de la date convenue, vous ne pourrez plus utiliser votre logiciel avec '+(IlicenceNewsupp > 1?'ces licences ': ' cette licence ')+'.</td></tr>';
                        }
                    }
                }
            }
            
            //
            
            // Fin Modif Fred
            
               //close the table
            lTxtDetailOffres += '</table>';
            // Set the detail of the amendment on the quote
            quo.Detail_de_modification__c  = lTxtDetailOffres;
    }
                    
                    
 }
    
    
}


/**
*@function initialize amendment details, called by function AmendmentDetails
*@author Qiuyan Liu
*/
private static void amendmentDetailMapInit(Map<Integer, String[]> amendmentDetailMap) {
  amendmentDetailMap.put(0, 
               new List<String>{'Remise - frais d\'activation CapRenov+ offerts',
                         'NewProduct', 
                         'Remise exceptionnelle : frais d\'activation CapRenov+ offerts</b></span></font><br>', 
                         'Une remise exceptionnelle égale aux frais d\'activation CapRenov+ sera appliquée sur votre prochaine facture, soit <b>', 
                         '€ HT </b>!<br>',
                         'TVA applicable sur cette remise : 20%</td></tr>'});
  amendmentDetailMap.put(1,
               new List<String>{'Remise - 1 opportunité Homly Travaux 10€ offerte', 
                         'NewProduct', 
                         'Remise exceptionnelle : 1 opportunité Homly Travaux 10€ offerte</b></span></font><br>', 
                         'Une remise exceptionnelle, égale au coût d’une opportunité Homly Travaux à 10€, sera appliquée sur votre prochaine facture !', 
                         '<br>',
                         'TVA applicable sur cette remise : 20%</td></tr>'});
  amendmentDetailMap.put(2,
               new List<String>{'Remise - 1 opportunité Homly Travaux 20€ offerte', 
                         'NewProduct', 
                         'Remise exceptionnelle : 1 opportunité Homly Travaux 20€ offerte</b></span></font><br>', 
                         'Une remise exceptionnelle, égale au coût d’une opportunité Homly Travaux à 20€, sera appliquée sur votre prochaine facture !', 
                         '<br>',
                         'TVA applicable sur cette remise : 20%</td></tr>'});
  amendmentDetailMap.put(3,
               new List<String>{'Remise - 1 opportunité Homly Travaux 30€ offerte', 
                         'NewProduct', 
                         'Remise exceptionnelle : 1 opportunité Homly Travaux 30€ offerte</b></span></font><br>', 
                         'Une remise exceptionnelle, égale au coût d’une opportunité Homly Travaux à 30€, sera appliquée sur votre prochaine facture !', 
                         '<br>',
                         'TVA applicable sur cette remise : 20%</td></tr>'});
  amendmentDetailMap.put(4,
               new List<String>{'Remise spéciale été - abonnement Homly Travaux offert pendant 1 mois', 
                         'NewProduct', 
                         'Remise exceptionnelle : 1 mois d\'abonnement Homly Travaux</b></span></font><br>',
                         //'Remise exceptionnelle : 1 mois d\'abonnement Homly Travaux spéciale été offert</b></span></font><br>', 
                         'Une remise exceptionnelle égale à un mois d\'abonnement Homly Travaux sera appliquée sur votre prochaine facture, soit <b>  ', 
                         '€ HT </b>pendant 1 mois !<br>',
                         'TVA applicable sur cette remise : 20%</td></tr>'});
  amendmentDetailMap.put(5,
               new List<String>{'Remise - 1 mois d\'abonnement Homly Travaux offert pour absence d\'opportunité', 
                         'NewProduct',
                      'Remise exceptionnelle : 1 mois d\'abonnement Homly Travaux</b></span></font><br>', 
                      'Une remise exceptionnelle égale à un mois d\'abonnement Homly Travaux sera appliquée sur votre prochaine facture, soit <b>', 
                      '€ HT </b>pendant 1 mois !<br>',
                      'TVA applicable sur cette remise : 20%</td></tr>'});
  amendmentDetailMap.put(6,
               new List<String>{'Remise - avantage pack CapRenov+', 
                         'NewProduct',
                      'Remise : Avantage pack Cap Renov+</b></span></font><br>', 
                      'Bonne nouvelle ! Vos abonnements souscrits vous permettent d\'obtenir une remise d\'un montant de <b>', 
                      '€ HT </b>chaque mois !<br>',
                      'TVA applicable sur cette remise : 20%</td></tr>'});
  amendmentDetailMap.put(7,
               new List<String>{'Remise - avantage pack CapRenov+', 
                         'UpdateProduct',
                      'Remise : Avantage pack Cap Renov+</b></span></font><br>', 
                      'Bonne nouvelle ! Vos abonnements souscrits vous permettent d\'obtenir une remise d\'un montant de <b>', 
                      '€ HT </b>chaque mois !<br>',
                      'TVA applicable sur cette remise : 20%</td></tr>'});
}

//--------------------------------------------------------------------
public static void calculateIfIntermediationOffer(List<zqu__Quote__c> lQuote)
    {
        system.debug('>>>>>>>>>>>>>>> calculateIfIntermediationOffer START');
        
        if (lQuote != null && lQuote.size() > 0)
        {
            // Get all the rateplan intermediation for the quote retrieved
            //List<zqu__QuoteRatePlan__c> lRatePlanIntermediation = [SELECT Id, zqu__Quote__c, zqu__ProductRatePlan__r.Est_intermediation__c FROM zqu__QuoteRatePlan__c WHERE zqu__Quote__c in: lQuote AND zqu__QuoteProductName__c =: Label.OffreIntermediationProductName];
            //List<zqu__QuoteRatePlan__c> lRatePlanIntermediation = [SELECT Id, zqu__Quote__c, zqu__ProductRatePlan__r.Est_intermediation__c FROM zqu__QuoteRatePlan__c WHERE zqu__Quote__c in: lQuote AND zqu__ProductRatePlan__r.Est_intermediation__c = true];
            
            // Modifier par Leila le 08-01-18 suite refontes des offres EB164
            List<zqu__QuoteRatePlan__c> lRatePlanIntermediation = [SELECT Id, zqu__Quote__c, zqu__ProductRatePlan__r.Inclut_Mise_en_relation__c FROM zqu__QuoteRatePlan__c WHERE zqu__Quote__c in: lQuote AND zqu__ProductRatePlan__r.Inclut_Mise_en_relation__c = true];
            
            // go through the quotes
            for (zqu__Quote__c quo : lQuote)
            {
                // Find the if a rate plan intermediation is set
                zqu__QuoteRatePlan__c ratePlan = null;
                if (lRatePlanIntermediation != null && lRatePlanIntermediation.Size() > 0)
                {
                    for (zqu__QuoteRatePlan__c rt : lRatePlanIntermediation)
                    {
                        if (rt.zqu__Quote__c == quo.Id)
                        { ratePlan = rt; break; }
                    }
                }
                
                // If the rate plan is found, set the intermediation flag set to true
                if (ratePlan != null)
                    quo.Intermediation__c = true;
                else
                    quo.Intermediation__c = false;
            }

            //if (lQuote != null)
            //    update lQuote;
        }
        
        system.debug('>>>>>>>>>>>>>>> calculateIfIntermediationOffer END');
    }
    
    public static void calculateTexteCompetence(List<zqu__Quote__c> lQuote)
    {
        // Get the account of the quotes
        List<id> lAccountId = new List<Id>();
        for (zqu__Quote__c quo : lQuote)
            lAccountId.add(quo.zqu__Account__c);

        // Get the geocat of the contact of the account
        List<Contact> lContact = [SELECT Id, AccountId, LastName, FirstName FROM Contact WHERE AccountId in: lAccountId AND PXS_Nb_Geocat_With_Competence__c > 0];
        List<GeoCat__c> lGeoCat = [SELECT Id, Contact__c, TECH_Texte_Quote__c FROM GeoCat__c WHERE Contact__c in: lContact];
        
        if (lGeoCat != null && lGeoCat.size() > 0)
        {
            // Go through the quotes
            for (zqu__Quote__c quo : lQuote)
            {
                // Get the contact attached to the quotes
                List<Contact> lContactOfQuoteAccount = new List<Contact>();
                for (Contact con : lContact)
                {
                    if (con.AccountId == quo.zqu__Account__c)
                        lContactOfQuoteAccount.add(con);
                }
                
                // for each contact, get his geocat txt
                String lTxtCompetence = '';
                for (Contact con : lContactOfQuoteAccount)
                {
                    String txtCompetence = '';
                    for (GeoCat__c geo : lGeoCat)
                    {
                        if (geo.Contact__c == con.Id)
                        {
                            if (txtCompetence != '')
                                txtCompetence += '<br/>';
                            txtCompetence += geo.TECH_Texte_Quote__c;
                        }
                    }
                    lTxtCompetence += '<b>' + con.Lastname + ' ' + con.Firstname + ':</b><br/>' + txtCompetence + '<br/>';
                }
                
                // Set the competence of the contacts on the quote
                quo.Competences__c = lTxtCompetence;
            }
        }
        
        update lQuote;
    }
    
    public PageReference calculateCompetence()
    {
        Id quoteId = apexpages.currentpage().getparameters().get('quoteId');
        
        if (quoteId != null)
        {
            zqu__Quote__c quo = [SELECT Id, zqu__Account__c FROM zqu__Quote__c WHERE Id =: quoteId];
            List<zqu__Quote__c> lquote = new List<zqu__Quote__c>();
            lquote.add(quo);
            QuoteMethods.calculateTexteCompetence(lquote);
            return (new PageReference('/' + quoteId));
        }
        
        return (null);
    }


    public static String sendToZBilling(Id quoteId)
    {
        /** FIRST VERSION OF ZBILLING
         *----------------------------
        // Check if it is a new quote or an amendment or others
        String selectedZBillingAccountID = null;
        List<zqu__Quote__c> rtDeveloperNameQuote = [SELECT RecordTypeName__c FROM zqu__Quote__c WHERE Id=: quoteId];
        if (rtDeveloperNameQuote != null && rtDeveloperNameQuote.size() > 0)
        {
            if (rtDeveloperNameQuote[0].RecordTypeName__c.contains('Default'))
                selectedZBillingAccountID = 'New';
        }
        system.debug('>>>> selectedZBillingAccountID: ' + selectedZBillingAccountID);
        
        Map<String, String> finalRes = zqu.zQuoteUtil.sendToZBilling(quoteId,selectedZBillingAccountID, true, null, null);
        
        String resultString = '';
        for (String result : finalRes.values()) { resultString += result; }
        system.debug('>>>>>>>>>>>>> resultString: ' + resultString);
        if (resultString != 'null')
        {
            system.debug('>>> result KO: ' + resultString);
            zqu__Quote__c quo = [SELECT Id, Send_to_Zbilling_Status__c, Send_to_Zbilling_Message__c FROM zqu__Quote__c WHERE Id =: quoteId];
            quo.Send_to_Zbilling_Status__c = 'Erreur pendant le zbilling';
            quo.Send_to_Zbilling_Message__c = resultString;
            update quo;
            return ('ERROR;Une erreur est survenue pendant le zbilling - ' + resultString);
        }
        **/

        // Get the quote information
        zqu__Quote__c quo = [SELECT Id, zqu__Account__c, Send_to_Zbilling_Billing_Account_Created__c, Send_to_Zbilling_Status__c, Send_to_Zbilling_Message__c
                            FROM zqu__Quote__c 
                            WHERE Id =: quoteId];
        
        try
        {
            // Check if a billing account is existing
            String billingAccountId = 'new';
            List<Zuora__CustomerAccount__c> zuoraAccountList = [SELECT Id, Zuora__Account__c, Zuora__External_Id__c
                FROM Zuora__CustomerAccount__c WHERE Zuora__Account__c  =: quo.zqu__Account__c];
            if (zuoraAccountList == null || (zuoraAccountList != null && zuoraAccountList.size() > 0))
                billingAccountId = zuoraAccountList[0].Zuora__External_Id__c;
            
            system.debug('>>>>>>>>>>>>> billingAccountId: ' + billingAccountId);
            
            // Generate the list of zbillingQuoteCollection
            List<zqu.zQuoteUtil.ZBillingQuoteCollection> quotes = new List<zqu.zQuoteUtil.ZBillingQuoteCollection>();
            
            // Generate the quotecollection record
            zqu.zQuoteUtil.ZBillingQuoteCollection quote = new zqu.zQuoteUtil.ZBillingQuoteCollection();
            quote.sfdcAccountId = quo.zqu__Account__c; // SFDC CRM Account ID
            quote.zAccountId = billingAccountId; // Zuora Billing Account ID or 'new' of no billing account found
            quote.quoteRequests = new List<zqu.zQuoteUtil.ZBillingQuoteRequest>();
            zqu.zQuoteUtil.ZBillingQuoteRequest req = new zqu.zQuoteUtil.ZBillingQuoteRequest();
            req.sfdcQuoteId = quo.Id; // SFDC Quote ID
            quote.quoteRequests.add(req);
            quotes.add(quote);
            
    
            // send the quotecollection to zbilling
            List<zqu.zQuoteUtil.zBillingResult> results = zqu.zQuoteUtil.sendToZBilling(quotes);
            for (zqu.zQuoteUtil.zBillingResult result : results ) 
            {
                if (result.success == true)
                {
                    system.debug('>>>>> SUCCESS : AccountId: ' + result.zAccountId);
                    quo.Send_to_Zbilling_Billing_Account_Created__c = result.zAccountId;
                    update quo;
                }
                else
                {
                    system.debug('>>>>> FAIL: ' + result.message);
                    quo.Send_to_Zbilling_Status__c = 'Erreur pendant le zbilling';
                    quo.Send_to_Zbilling_Message__c = result.message;
                    update quo;
                    return ('ERROR;Une erreur est survenue pendant le zbilling - ' + result.message);
                }
            }
        } catch (Exception e)
        {
            system.debug('>>>>> EXCEPTION: ' + e.getMessage());
            quo.Send_to_Zbilling_Status__c = 'Erreur pendant le zbilling';
            quo.Send_to_Zbilling_Message__c = e.getMessage();
            update quo;
            return ('ERROR;Une erreur est survenue pendant le zbilling - ' + e.getMessage());
        }
        
        return ('SUCCESS');
    }
    
/**
 * ZUORA : PAYMENT METHODS
 **/
    @future (callout=true)
    public static void createPaymentMethodsAsynchronously(Id quoteId) 
    {
        createPaymentMethods(quoteId);
    }
    
    public static String createPaymentMethods(Id quoteId) 
    {
        System.debug('>>>>>>>>>> createPaymentMethods execution START.');

        // Get the quote information
        zqu__Quote__c quo = [SELECT Id, zqu__Account__c, PM_BillingCountry__c, PM_BillingPostalCode__c, PM_CardHolderName__c, PM_CardNumber__c, PM_CreditCardType__c, PM_Email__c, PM_ExpirationMonth__c,
                            PM_ExpirationYear__c, PM_SecondTokenId__c, PM_TokenId__c, zqu__ZuoraAccountID__c, Send_to_Zbilling_Status__c, Send_to_Zbilling_Message__c, zqu__Zuora_Account_Number__c, Send_to_Zbilling_Billing_Account_Created__c, RecordType.DeveloperName
                            FROM zqu__Quote__c 
                            WHERE Id =: quoteId];
        
        // Check if payment method information set
        system.debug('>>>>>>>> quo.PM_CardHolderName__c: [' + quo.PM_CardHolderName__c + ']');
        system.debug('>>>>>>>> quo.PM_CreditCardType__c: [' + quo.PM_CreditCardType__c + ']');
        system.debug('>>>>>>>> quo.PM_CardNumber__c: [' + quo.PM_CardNumber__c + ']');
        if (quo.PM_BillingCountry__c == null || quo.PM_BillingCountry__c == '' || quo.PM_CardHolderName__c == null || quo.PM_CardHolderName__c == '' || quo.PM_CreditCardType__c == null || quo.PM_CreditCardType__c == '' ||
            quo.PM_Email__c == null || quo.PM_Email__c == '' || quo.PM_ExpirationMonth__c == null || quo.PM_ExpirationMonth__c == '' || quo.PM_ExpirationYear__c == null || quo.PM_ExpirationYear__c == '' || quo.PM_SecondTokenId__c == null || quo.PM_SecondTokenId__c == '' || quo.PM_TokenId__c == null || quo.PM_TokenId__c == '')
        {
            
            quo.Send_to_Zbilling_Status__c = (quo.Recordtype.DeveloperName != 'Default' && quo.Recordtype.DeveloperName != 'ReadOnly' ? 'Succès' : 'Erreur pendant la création de la payment method'); quo.Send_to_Zbilling_Message__c = Label.CustomZbilling_SuccessMessage_NoPaymentMethodInformation; update quo;
            return ('SUCCESS;' + Label.CustomZbilling_SuccessMessage_NoPaymentMethodInformation);
        }

        try 
        {
            // Prepare the PM to create
            List<Zuora.zObject> pmToCreateList = new List<Zuora.zObject>();
            Zuora.zObject pmToCreate = new Zuora.zObject('PaymentMethod');
            //pmToCreate.setValue('AccountId', zuoraAccountList[0].Zuora__External_Id__c);
            pmToCreate.setValue('AccountId', quo.Send_to_Zbilling_Billing_Account_Created__c);
            pmToCreate.setValue('Type', 'CreditCardReferenceTransaction'); //CreditCard - CCReferencetrasanction ======>>>>>>> se rapprocher de marc
            pmToCreate.setValue('SecondTokenId', quo.PM_SecondTokenId__c);
            pmToCreate.setValue('TokenId', quo.PM_TokenId__c);
            pmToCreate.setvalue('CreditCardType', quo.PM_CreditCardType__c);
            pmToCreate.setvalue('CreditCardNumber', quo.PM_CardNumber__c);
            pmToCreate.setvalue('CreditCardHolderName', quo.PM_CardHolderName__c);
            pmToCreate.setvalue('CreditCardExpirationYear', quo.PM_ExpirationYear__c);
            pmToCreate.setvalue('CreditCardExpirationMonth', quo.PM_ExpirationMonth__c);
            pmToCreateList.add(pmToCreate);
            
            // Send the callout to Zuora
            system.debug('>>>>>>>>>>> CREATE PAYMENT METHODS');
            Zuora.zApi zApi = ZuoraUtilities.zuoraApiAccess();
            List<Zuora.zApi.SaveResult> saveResultsList = ZuoraUtilities.createZuoraObjects(zApi, pmToCreateList);
            for (Zuora.zApi.SaveResult saveResult : saveResultsList)
            {
                system.debug('>>>>>> ZUORA RESULT 1 : ' + ZuoraUtilities.analyzeSaveResult(saveResult));
                system.debug('>>>>>> ZUORA RESULT 1 : ' + saveResult);
                if (! ZuoraUtilities.analyzeSaveResult(saveResult).isEmpty())
                {
                    quo.Send_to_Zbilling_Status__c = 'Erreur pendant la création de la payment method';
                    quo.Send_to_Zbilling_Message__c = QuoteMethods.getZuoraErrorMessage(ZuoraUtilities.analyzeSaveResult(saveResult));
                    update quo;
                    System.debug('########## ERROR: ' + ZuoraUtilities.analyzeSaveResult(saveResult));
                    return ('ERROR;Le moyen de paiement n\'a pas été créé: ' + ZuoraUtilities.analyzeSaveResult(saveResult));
                }
                else
                {
                    System.debug('########## SUCCESS CREATING PM' + ZuoraUtilities.analyzeSaveResult(saveResult));
                    
                    // If success, add the method payment to the account as default
                    List<Zuora.zObject> accountsToUpdateList = new List<Zuora.zObject>();
                    Zuora.zObject accountToUpdate = new Zuora.zObject('Account');
                    //accountToUpdate.setValue('Id', zuoraAccountList[0].Zuora__External_Id__c);
                    accountToUpdate.setValue('Id', quo.Send_to_Zbilling_Billing_Account_Created__c);
                    accountToUpdate.setValue('DefaultPaymentMethodId', saveResult.Id);
                    accountsToUpdateList.add(accountToUpdate);
                    
                    system.debug('>>>>>>>>>>> ATTACH PAYMENT METHOD TO ACCOUNT');
                    List<Zuora.zApi.SaveResult> accountSaveResultsList = ZuoraUtilities.updateZuoraObjects(zApi, accountsToUpdateList);
                    for (Zuora.zApi.SaveResult saveResultUp : accountSaveResultsList)
                    {
                        system.debug('>>>>>> ZUORA RESULT 2 : ' + ZuoraUtilities.analyzeSaveResult(saveResultUp));
                        system.debug('>>>>>> ZUORA RESULT 2 : ' + saveResultUp);
                        if (! ZuoraUtilities.analyzeSaveResult(saveResultUp).isEmpty())
                        {
                            quo.Send_to_Zbilling_Status__c = 'Erreur pendant la création de la payment method';
                            quo.Send_to_Zbilling_Message__c = QuoteMethods.getZuoraErrorMessage(ZuoraUtilities.analyzeSaveResult(saveResult));
                            update quo;
                            System.debug('########## ERROR: ' + ZuoraUtilities.analyzeSaveResult(saveResultUp));
                            return ('ERROR;Le moyen de paiement n\'a pas été créé: ' + ZuoraUtilities.analyzeSaveResult(saveResultUp));
                        }
                    }
                    
                }
            }
            
            System.debug('>>>>>>>>>> createPaymentMethods execution END.');
            quo.Send_to_Zbilling_Status__c = 'Succès de l\'envoi de la quote avec les moyens de paiement' ;
            quo.Send_to_Zbilling_Message__c = '';
            update quo;
            return ('SUCCESS');
            
        } catch (Exception e) 
        {
            quo.Send_to_Zbilling_Status__c = 'Erreur pendant la création de la payment method';
            quo.Send_to_Zbilling_Message__c = e.getMessage();
            update quo;
            System.debug('>>>>>>>>>> EXCEPTION: ' +  e);
            return ('ERROR;Le moyen de paiement n\'a pas été créé: ' + e.getMessage());
        }
        
    }
/**
 * \ ZUORA : PAYMENT METHODS
 **/
 
    public static string getZuoraErrorMessage(List<String> msgs)
    {
        String res = '';
        
        for (String txt : msgs)
            res += txt + ' - ';
        
        return (res);
    }
 
    public static String manageLicenceOnSubscription(Id quoteId)
    {
        system.debug('>>>>>>>>>>>>>>>>>>>>>>> manageLicenceOnSubscription START');
        system.debug('fred');
        
        // Step 1 : get the quote information
        zqu__Quote__c quo = [SELECT Id, zqu__Account__c, zqu__ZuoraAccountID__c, Send_to_Zbilling_Status__c, Send_to_Zbilling_Message__c, Contact__c
                            FROM zqu__Quote__c 
                            WHERE Id =: quoteId];
        List<zqu__QuoteRatePlan__c> lQuoteRPIntermediation = [SELECT Id, Name, zqu__ProductRatePlan__c, zqu__ProductRatePlanZuoraId__c, zqu__QuoteProductName__c 
                                                                FROM zqu__QuoteRatePlan__c
                                                                WHERE zqu__Quote__c = :quoteId
                                                                AND Name IN ('Service "Simulateur d’efficacité énergétique Cap Renov+" - mensuel', 'Service "Simulateur d’efficacité énergétique Cap Renov+" - annuel')
                                                                AND zqu__AmendmentType__c != 'RemoveProduct'];
        List<Id> productrateplanids = new List<Id>();
        Map<String, Id> productrateplanidsMap = new Map<String, Id>();
        for (zqu__QuoteRatePlan__c zquqrp : lQuoteRPIntermediation) {
            productrateplanids.add(zquqrp.zqu__ProductRatePlan__c);
            productrateplanidsMap.put(zquqrp.Name,zquqrp.zqu__ProductRatePlan__c);
        }

        try
        {
            // Step 2: Update the quantity to 1 to the chargegroup of caprenov+ on the licence line
            List<zqu.zChargeGroup> chargeGroupList = zqu.zQuoteUtil.getChargeGroups(quoteId);
            system.debug('>>>>>>>> Nombre de chargeGroup: ' + chargeGroupList.size());
            List<zqu.zCharge> newChargeToSet = new List<zqu.zCharge>();
            
            // Step 3: Get the product rate plans to split in the charge of the quote
            List<Id> lProductRatePlanIdInCharge = new List<Id>();
            List<zqu__ProductRatePlan__c> lProductRatePlanInCharge = null;
            for (zqu.zChargeGroup chargeGroup : chargeGroupList)
                lProductRatePlanIdInCharge.add(chargeGroup.productRatePlanId);
            if (lProductRatePlanIdInCharge != null && lProductRatePlanIdInCharge.size() > 0)
                lProductRatePlanInCharge = [SELECT Id, Name, Caprenov_Charge_split__c FROM zqu__ProductRatePlan__c WHERE Id in:productrateplanids AND Caprenov_Charge_split__c = true];
            system.debug('>>>>>>>> All Product Rate Plan: ' + lProductRatePlanInCharge);
            
            // If the list is empty, means nothing to split
            if (lProductRatePlanInCharge == null || (lProductRatePlanInCharge != null && lProductRatePlanInCharge.size() == 0))
                return ('SUCCESS;Le Simulateur d’efficacité énergétique Cap Renov+ n\'est pas sélectionnée.');
            
            // Get the charges of the rate plan to split
            List<zqu__ProductRatePlanCharge__c> ratePlanChargesToSplit = [SELECT Id, Name, zqu__ProductRatePlan__c, Caprenov_To_Split__c FROM zqu__ProductRatePlanCharge__c WHERE zqu__ProductRatePlan__c in: lProductRatePlanInCharge AND Caprenov_To_Split__c = true];
            system.debug('>>>>>>>> All Product Rate Plan Charges to split: size (' + ratePlanChargesToSplit.size() + ') :' + ratePlanChargesToSplit);
            if (ratePlanChargesToSplit == null || (ratePlanChargesToSplit != null && ratePlanChargesToSplit.size() == 0))
                return ('SUCCESS;Il n\'y a pas de charge de licence a dégroupe. Vérifier la configuration des offres.');
            
            // Get the rate plan of the degrouping rate plan
            List<zqu__ProductRatePlan__c> ratePlanDegroupement = [SELECT Id FROM zqu__ProductRatePlan__c WHERE Caprenov_Is_RatePlan_Split__c = true AND Id IN :productrateplanids AND zqu__Deleted__c = false];
            if (ratePlanDegroupement == null ||(ratePlanDegroupement != null && ratePlanDegroupement.size() == 0))
            {
                quo.Send_to_Zbilling_Status__c = 'Erreur pendant le split des licences';
                quo.Send_to_Zbilling_Message__c = 'La configuration des offres Caprenov+ n\'est pas finalisé : il faut sélectionner une offre de degroupement.';
                update quo;
                return ('ERROR;Un problème a été rencontré durant le traitement : La configuration des offres Caprenov+ n\'est pas finalisé : il faut sélectionner une offre de degroupement.');
            }
            
            // Charges needs to be split
            List<zqu.zChargeGroup> lChargeGroup = new List<zqu.zChargeGroup>();
            for (zqu.zChargeGroup chargeGroup : chargeGroupList)
            {
                system.debug('>>>>>>>> chargeGroup: ' + chargeGroup);

                // Check if the productrateplan is to split
                zqu__ProductRatePlan__c ratePlanToSplit = QuoteMethods.isProductRatePlanToSplit(chargeGroup, lProductRatePlanInCharge);
                system.debug('>>>>>>>>> ratePlanToSplit: ' + ratePlanToSplit);
                // If the rate plan is to split
                if (ratePlanToSplit != null)
                {
                    // Go through the charge to split them if needed
                    for (zqu.zCharge charge : chargeGroup.zCharges)
                    {
                        system.debug('>>>>>>> charge: ' + charge);
                        // Retrieved the charge to know of it is a charge to split
                        zqu__ProductRatePlanCharge__c chargeRatePlan = QuoteMethods.getRatePlanChargeFromZCharge(charge, ratePlanChargesToSplit);
                        system.debug('>>>>>>> chargeRatePlan: ' + chargeRatePlan);
                        
                        // If the charge is to split to split
                        Integer nb = (charge.Quantity.isNumeric() == true ? Integer.ValueOf(charge.Quantity) : 0);
                        system.debug('>>>>>>> Quantity: ' + nb);
                        if (chargeRatePlan != null && chargeRatePlan.Caprenov_To_Split__c == true && nb > 1 )
                        {
                            List<Id> ratePlanDegroupementId = new List<Id>(); 
                            // Split in different charge group
                            for (integer i = 0 ; i < (nb - 1); i++)
                            {
                                ratePlanDegroupementId.add(ratePlanDegroupement[0].Id);
                                //zqu.zChargeGroup chargeGroupCapLicence = zqu.zQuoteUtil.getChargeGroup(quoteId, ratePlanDegroupement[0].Id);
                                //lChargeGroup.add(chargeGroupCapLicence);
                            }
                            lChargeGroup = zqu.zQuoteUtil.getChargeGroups(quoteId, ratePlanDegroupementId); 
                            //lChargeGroup.addAll(zqu.zQuoteUtil.getChargeGroups(quoteId, ratePlanDegroupementId)); 
                            system.debug('>>>>>>> List of zChargeGroup: ' + lChargeGroup);
                            
                            
                            // Update the quantity of the orignal group
                            zqu__QuoteRatePlanCharge__c chargeLicence = new zqu__QuoteRatePlanCharge__c();
                            chargeLicence.Id = charge.Id;
                            chargeLicence.zqu__Quantity__c = 1;
                            chargeLicence.zqu__ListTotal__c = Decimal.valueOf(charge.LIST_PRICE);
                            update chargeLicence;
                        }
                    }
                }
            }
            
            system.debug('>>>>>> lChargeGroup to insert (' + lChargeGroup.size() + ') : ' + lChargeGroup);
            
            // Add the splitted charge group to the quote
            if (lChargeGroup != null && lChargeGroup.size() > 0)
                zqu.ZQuoteUtil.addChargeGroups(lChargeGroup);

        } catch (Exception e)
        {
            system.debug('>>>>>>>>>> EXCEPTION: ' + e.getMessage());
            quo.Send_to_Zbilling_Status__c = 'Erreur pendant le split des licences';
            quo.Send_to_Zbilling_Message__c = e.getMessage();
            update quo;
            return ('ERROR;Un problème a été rencontré durant le traitement : ' + e.getMessage());
        }
        
        system.debug('>>>>>>>>>>>>>>>>>>>>>>> manageLicenceOnSubscription END');
        return ('SUCCESS');
    }
    
    
    public static zqu__ProductRatePlan__c isProductRatePlanToSplit(zqu.zChargeGroup chargeGroupe, List<zqu__ProductRatePlan__c> lProductRatePlanInCharge)
    {
        for (zqu__ProductRatePlan__c charge : lProductRatePlanInCharge)
        {
            if (chargeGroupe.productRatePlanId == charge.Id)
                return (charge);
        }
        return (null);
    }
    
    public static zqu__ProductRatePlanCharge__c getRatePlanChargeFromZCharge(zqu.zCharge charge, List<zqu__ProductRatePlanCharge__c> ratePlanChargesToSplit)
    {
        for (zqu__ProductRatePlanCharge__c ratePlanCharge : ratePlanChargesToSplit)
        {
            if (charge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID == ratePlanCharge.Id)
                return (ratePlanCharge);
        }
        return (null);
    }
    
    /**
     public static String manageLicenceOnSubscription(Id quoteId)
    {
        system.debug('>>>>>>>>>>>>>>>>>>>>>>> manageLicenceOnSubscription START');
        
        // Step 1 : get the quote information
        zqu__Quote__c quo = [SELECT Id, zqu__Account__c, zqu__ZuoraAccountID__c, Send_to_Zbilling_Status__c, Send_to_Zbilling_Message__c, Contact__c
                            FROM zqu__Quote__c 
                            WHERE Id =: quoteId];
        try
        {
            // Step 2: Update the quantity to 1 to the chargegroup of caprenov+ on the licence line
            List<zqu.zChargeGroup> chargeGroupList = zqu.zQuoteUtil.getChargeGroups(quoteId);
            List<zqu.zCharge> newChargeToSet = new List<zqu.zCharge>();

            Integer licenceQty = 0;
            zqu.zChargeGroup chargeGroupLicence = null;

            for (zqu.zChargeGroup chargeGroup : chargeGroupList)
            {
                if (chargeGroup.ProductName == Label.OffreCaprenov)
                {
                    chargeGroupLicence = chargeGroup;
                    for (zqu.zCharge charge : chargeGroupLicence.zCharges)
                    {
                        if (charge.Name == Label.OffreCaprenov_Licence)
                        {
                            // Store the quantity asked before
                            if (charge.QUANTITY != null && charge.QUANTITY.isNumeric() == false)
                                licenceQty = 0;
                            else
                            {
                                licenceQty = Integer.valueOf(charge.QUANTITY);
                           
                                // Update the quantity and price to 1 quantity
                                zqu__QuoteRatePlanCharge__c chargeLicence = new zqu__QuoteRatePlanCharge__c();
                                chargeLicence.Id = charge.Id;
                                chargeLicence.zqu__Quantity__c = 1;
                                chargeLicence.zqu__ListTotal__c = Decimal.valueOf(charge.LIST_PRICE);
                                update chargeLicence;
                            }
                        }
                    }
                    // Update the chargegroup to set the quantity to 1
                    //zqu.zQuoteUtil.UpdateChargeGroup(chargeGroupLicence);
                }
            }

            if (chargeGroupLicence == null)
                return ('SUCCESS;L\'offre CapRenov+ n\'est pas sélectionnée.');

            
            // Step 3: Add the licence remaining in the product rate plan Caprenov+Licence
            if (chargeGroupLicence != null && licenceQty > 1)
            {
                List<zqu.zChargeGroup> lChargeGroup = new List<zqu.zChargeGroup>();
                Id caprenovProduct = [SELECT Id FROM zqu__ZProduct__c WHERE zqu__SKU__c =: Label.ProduitCaprenov_SKU].Id;
                Id ratePlanId = [SELECT Id FROM zqu__ProductRatePlan__c WHERE Name = 'Licence' AND zqu__ZProduct__c =: caprenovProduct AND zqu__Deleted__c = false].Id;
                
                for (integer i = 0 ; i < (licenceQty - 1); i++)
                {
                    zqu.zChargeGroup chargeGroupCapLicence = zqu.zQuoteUtil.getChargeGroup(quoteId, ratePlanId);
                    lChargeGroup.add(chargeGroupCapLicence);
                }
                
                if (lChargeGroup != null && lChargeGroup.size() > 0)
                    zqu.ZQuoteUtil.addChargeGroups(lChargeGroup);
                    
            }
            
        } catch (Exception e)
        {
            system.debug('>>>>>>>>>> EXCEPTION: ' + e.getMessage());
            quo.Send_to_Zbilling_Status__c = 'Erreur pendant le split des licences';
            quo.Send_to_Zbilling_Message__c = e.getMessage();
            update quo;
            return ('ERROR;Un problème a été rencontré durant le traitement : ' + e.getMessage());
        }
        
        system.debug('>>>>>>>>>>>>>>>>>>>>>>> manageLicenceOnSubscription END');
        return ('SUCCESS');
    }
    **/

    /*******************************************************************************************************
    * @description change the quote to Post Résiliation record type if type de geste equals to "Geste commercial post-résiliation"
    * @param type List<zqu__Quote__c>, trigger.new
    * @return void
    * @author Qiuyan Liu
    */
    public static void checkRTPostResiliation(List<zqu__Quote__c> zQuoteList) {
        //check if need to bypass this function
        User curUser = [SELECT Id, Bypass_Function__c FROM User WHERE Id =:UserInfo.getUserId()];
        String Bypass_Function = curUser.Bypass_Function__c == null ? '' : curUser.Bypass_Function__c;
        if (Bypass_Function.contains('checkRTPostResiliation')) return;
        
        List<zqu__Quote__c> quoteUpdateList = new List<zqu__Quote__c>();
        
        Map<String, Id> rtNameIdMap = new Map<String, Id>();
        for (RecordType zQuoteRT : [SELECT id, DeveloperName FROM RecordType WHERE SObjectType = 'zqu__Quote__c']) { //DeveloperName = 'Post_resiliation' AND 
            rtNameIdMap.put(zQuoteRT.DeveloperName, zQuoteRT.Id);
        }
        
        for (zqu__Quote__c zQuote : zQuoteList) {
            //find the new record type name for current quote
            String rtName = (zQuote.Type_de_geste__c == 'Création de souscription' && zQuote.RecordTypeName__c != 'Default' && zQuote.zqu__Status__c != 'Abandonnée') ? 'Default' : 
                      ((zQuote.Type_de_geste__c == 'Geste commercial post-résiliation' && zQuote.RecordTypeName__c != 'Post_resiliation' && zQuote.zqu__Status__c != 'Abandonnée') ? 'Post_resiliation' : 
                                      (zQuote.zqu__Status__c == 'Abandonnée' && zQuote.Type_de_geste__c == 'Geste commercial post-résiliation' && zQuote.RecordTypeName__c != 'Post_resiliation_ReadOnly') ? 'Post_resiliation_ReadOnly' : 'noChange');
                                       //(zQuote.RecordTypeName__c == 'Amendment' ? 'Amendment' : 'noChange')); 
      //System.debug('rtName ' + rtName);
            //System.debug('rtNameIdMap ' + rtNameIdMap);
            //System.debug('zQuote ' + zQuote);
            //System.debug(zQuote.zqu__Status__c == 'Abandonnée' && zQuote.Type_de_geste__c == 'Geste commercial post-résiliation' && zQuote.RecordTypeName__c != 'Post_resiliation_ReadOnly');
            if ((zQuote.Type_de_geste__c == 'Création de souscription' && zQuote.RecordTypeName__c != 'Default' && zQuote.zqu__Status__c != 'Abandonnée') || 
                (zQuote.Type_de_geste__c == 'Geste commercial post-résiliation' && zQuote.RecordTypeName__c != 'Post_resiliation' && zQuote.zqu__Status__c != 'Abandonnée') || 
                (zQuote.zqu__Status__c == 'Abandonnée' && zQuote.Type_de_geste__c == 'Geste commercial post-résiliation' && zQuote.RecordTypeName__c != 'Post_resiliation_ReadOnly') ) {
                //zQuote.RecordTypeName__c == 'Amendment') {
                    System.debug('change record type to ' + rtName);
                    zQuote.RecordTypeId = rtNameIdMap.get(rtName);
            }
        }
    }
    /*******************************************************************************************************
    * @description ajout du remplissage du TC référent sur le compte pro qui se base sur le TC référent binome
    * @param type List<zqu__Quote__c>, trigger.new
    * @return void
    * @date 20/03/2019
    * @author Leila Bouaifel/Clément Musabimana
    */
    public static void updateAccountChargeClientele(List<zqu__Quote__c> zQuoteList) {
        // remplir le owner sur le compte et le TC référent sur le compte
          
        Set<Id> objOwnerId = new Set<Id>();
        String objRecordId;
        Set<Id> objAccount = new Set<Id>();
        Set<Id> objTcReferentId = new Set<Id>();
                       
        for(zqu__Quote__c obj: zQuoteList) {
        
           system.debug('quote trigger obj '+obj);    
            if(obj.zqu__Status__c == 'Sent to Z-Billing') {
                objOwnerId.add(obj.OwnerId);
                objRecordId = obj.Id;
                objAccount.add(obj.zqu__Account__c);
                    
            }
        }
        Map<ID, Account> m = new Map<ID, Account>([SELECT Id, OwnerId,TC_Referent__c,Code_postal__r.Name FROM Account where Id =:objAccount]);           
        List <Account> accountUpdateList = new List <Account>();
            
        Map<ID, User> uMap = new Map<ID, User>([select Id, TC_ITC_Referent_Binome__c from user where IsActive = true and Id=:objOwnerId]);
        List<User> userList = new List<User>();
 
        String labelListeDepartementsBlancs = Label.Departements_Blancs;
        Set<string> listeDepartementsBlancs = new Set<string>();
        listeDepartementsBlancs.addAll(labelListeDepartementsBlancs.split(';'));
        System.debug('listeDepartementsBlancs ='+listeDepartementsBlancs);      
        
        for(zqu__Quote__c obj: zQuoteList)  {
        
            if (obj.zqu__SubscriptionType__c == 'New Subscription' && m.containsKey(obj.zqu__Account__c ) && obj.Type_de_geste__c == 'Création de souscription'){
                system.debug('quote trigger mise a jour OwnerId '); 
                //21/08/2019: affectation CC sur zones blanches
                System.debug('m.get(obj.zqu__Account__c).Code_postal__r ='+m.get(obj.zqu__Account__c).Code_postal__r);
                String codePostaleName = '';
                if(m.get(obj.zqu__Account__c).Code_postal__r != null && m.get(obj.zqu__Account__c).Code_postal__r.Name != null && m.get(obj.zqu__Account__c).Code_postal__r.Name != ''){
                    codePostaleName = (m.get(obj.zqu__Account__c).Code_postal__r.Name).substring(0, 2);
                }
                System.debug('codePostaleName ='+codePostaleName);
                System.debug('listeDepartementsBlancs.contains(codePostaleName) ='+listeDepartementsBlancs.contains(codePostaleName));  
                if(codePostaleName != '' && listeDepartementsBlancs.contains(codePostaleName) && uMap.get(obj.OwnerId).TC_ITC_Referent_Binome__c != null){
                    m.get(obj.zqu__Account__c).OwnerId = uMap.get(obj.OwnerId).TC_ITC_Referent_Binome__c;                        
                    accountUpdateList.add(m.get(obj.zqu__Account__c));
                }
                else{
                    m.get(obj.zqu__Account__c).OwnerId = obj.OwnerId;                        
                    accountUpdateList.add(m.get(obj.zqu__Account__c));
                }         
            }
            
           if (obj.zqu__SubscriptionType__c == 'New Subscription' && uMap.containsKey(obj.OwnerId) && obj.Type_de_geste__c == 'Création de souscription' && uMap.get(obj.OwnerId).TC_ITC_Referent_Binome__c != null){
                system.debug('quote trigger mise a jour tc referent '); 
                system.debug('quote trigger obj '+obj); 
                m.get(obj.zqu__Account__c).TC_Referent__c = uMap.get(obj.OwnerId).TC_ITC_Referent_Binome__c;  
                if (!accountUpdateList.contains(m.get(obj.zqu__Account__c))){
                    accountUpdateList.add(m.get(obj.zqu__Account__c));  
                    system.debug('quote trigger compte non présent dans la liste accountUpdateList');
                }    
                else {system.debug('quote trigger compte déjà présent dans la liste accountUpdateList'); }   
            }
            
           if (obj.zqu__SubscriptionType__c == 'New Subscription' && uMap.containsKey(obj.OwnerId) && obj.Type_de_geste__c == 'Création de souscription' && uMap.get(obj.OwnerId).TC_ITC_Referent_Binome__c == null){
                
                m.get(obj.zqu__Account__c).TC_Referent__c = obj.OwnerId;  
                if (!accountUpdateList.contains(m.get(obj.zqu__Account__c))){
                    accountUpdateList.add(m.get(obj.zqu__Account__c));                
                }    
                else {system.debug('quote trigger compte déjà présent dans la liste accountUpdateList'); }   
            }         
         }   
        
        if(accountUpdateList.size() > 0) {     
            update accountUpdateList;       
        } 
    }    
}