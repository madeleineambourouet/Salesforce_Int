/**
* @author Qiuyan Liu
* @date 22/12/2016
*
* @description Resume the details of "mise en reation" on projects followed by the agency, send detail email in mass to each agency
*/

public with sharing class Batch_MERSelectionResume implements Database.Batchable<sObject>, Schedulable  {
    
    String query;
    private static String EMAIL_SUBJECT = '[Homly You] Mises en relation réalisées sur vos projets part';
    private static String EMAIL_HEADER = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><html xmlns="http://www.w3.org/1999/xhtml"> <head> <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"> <meta name="viewport" content="width=device-width"> <title></title> <style type="text/css">/*////// RESET STYLES //////*/body, #bodyTable, #bodyCell{height:100% !important; margin:0; padding:0; width:100% !important;}table{border-collapse:collapse;}img, a img{border:0; outline:none; text-decoration:none;}h1, h2, h3, h4, h5, h6{margin:0; padding:0;}p{margin: 1em 0;}/*////// CLIENT-SPECIFIC STYLES //////*/.ReadMsgBody{width:100%;} .ExternalClass{width:100%;} /* Force Hotmail/Outlook.com to display emails at full width. */.ExternalClass, .ExternalClass p, .ExternalClass span, .ExternalClass font, .ExternalClass td, .ExternalClass div{line-height:100%;} /* Force Hotmail/Outlook.com to display line heights normally. */table, td{mso-table-lspace:0pt; mso-table-rspace:0pt;} /* Remove spacing between tables in Outlook 2007 and up. */#outlook a{padding:0;} /* Force Outlook 2007 and up to provide a "view in browser" message. */img{-ms-interpolation-mode: bicubic;} /* Force IE to smoothly render resized images. */body, table, td, p, a, li, blockquote{-ms-text-size-adjust:100%; -webkit-text-size-adjust:100%;} /* Prevent Windows- and Webkit-based mobile platforms from changing declared text sizes. *//*////// FRAMEWORK STYLES //////*/.flexibleContainerCell{padding-top:20px; padding-Right:20px; padding-Left:20px;}/*//////ZONE SE TROUVANT AUTOUR DU NESCONTAINDER (BLOC AUTOUR DU TEXTE)/////*/.flexibleImage{height:auto;}.bottomShim{padding-bottom:20px;}/*//////ESPACE EN BAS ENTRE LE CONTENU ET LE BLOC/////*/.imageContent, .imageContentLast{padding-bottom:20px;}.nestedContainerCell{padding-top:20px; padding-Right:20px; padding-Left:20px;} /*//////ESPACE EN BAS ENTRE LE CONTENU ET LE BLOC/////*//*////// GENERAL STYLES //////*/body, #bodyTable{background-color:#f0f1f4;}/*//////COULEUR DE FOND EXTERIEUR DU MAIL/////*/#bodyCell{padding-top:20px; padding-bottom:40px;}#miroirBody{background-color:##f0f1f4; border-collapse:separate;}/*//////COULEUR ZONE LIEN MIROIR/////*/#emailBody{background-color:#FFFFFF; border:1px solid #DDDDDD; border-collapse:separate; border-radius:4px;}/*//////COULEUR DE FOND INTERIEUR DU MAIL/////*/ #footerBody{background-color:##f0f1f4; border-collapse:separate;}/*//////COULEUR ZONE DU FOOTER/////*/h1, h2, h3, h4, h5, h6{color:#202020; font-family:Helvetica; font-size:20px; line-height:125%; text-align:Left;}/*//////CARACTERISTIQUES DES TITRES/////*/.textContent, .textContentLast{color:#404040; font-family:Helvetica; font-size:15px; line-height:125%; text-align:Left; padding-bottom:20px;}/*//////POLICE DES TEXTES/////*/ .footerContent, .footerContentLast{color:#404040; font-family:Helvetica; font-size:11px; line-height:125%; text-align:center; padding-bottom:40px;}/*//////POLICE DES TEXTES/////*/.textContent a, .textContentLast a{color:#2C9AB7; text-decoration:underline;}/*//////COULEUR DES TEXTES/////*/.nestedContainer{background-color:#fff; border:1px solid #CCCCCC;}/*//////COULEUR DE FOND ET BORDURE DES BLOCS/////*/.emailButton{background-color:#e9425c; border-collapse:separate; border-radius:4px;}.buttonContent{color:#FFFFFF; font-family:Helvetica; font-size:18px; font-weight:bold; line-height:100%; padding:15px; text-align:center;}.buttonContent a{color:#FFFFFF; display:block; text-decoration:none;}.emailCalendar{background-color:#FFFFFF; border:1px solid #CCCCCC;}.emailCalendarMonth{background-color:#2C9AB7; color:#FFFFFF; font-family:Helvetica, Arial, sans-serif; font-size:16px; font-weight:bold; padding-top:10px; padding-bottom:10px; text-align:center;}.emailCalendarDay{color:#2C9AB7; font-family:Helvetica, Arial, sans-serif; font-size:60px; font-weight:bold; line-height:100%; padding-top:20px; padding-bottom:20px; text-align:center;} /*////// MON CSS //////*/ /*Réduction espace en bas du corps du mail*/ #miroirBody { padding-bottom: 20px; } /*Espace au-dessus du lien miroir*/ .miroir{ padding-top: 30px; } /*Alignement texte lien page miroir*/ .header{ font-size: 14px !important; text-align: right !important; padding-bottom: 0px !important; } /*Couleur lien header*/ .header a { color:#e9425c; } /*Espace autour du logo*/ .logoContainer{ padding-Right:0px; padding-Left:0px; padding-top: 0px; padding-bottom:0px; } /*Espace en bas du logo*/ .espacetexte{ padding-bottom:0px; } /*Couleur lien contenu texte*/ .textContent a{ color:#e9425c; line-height: 150%; } /*Interligne contenu texte*/ .interligne{ line-height: 180%; } /*Taille titre en H3*/ h3{ font-size: 18px; padding-bottom: 5px; } /*Couleur "A très vite sur Homly You"*/ .hy a { color:#e9425c; text-decoration : none; }.titlesav{ font-size: 20px; text-decoration: none; padding-bottom: 15px; color: #202020; } /*Couleur lien footer*/ .footer a { color:#e9425c; }/*////// MOBILE STYLES //////*/@media only screen and (max-width: 480px){/*////// CLIENT-SPECIFIC STYLES //////*/body{width:100% !important; min-width:100% !important;} /* Force iOS Mail to render the email at full width. *//*////// FRAMEWORK STYLES //////*//*CSS selectors are written in attributeselector format to prevent Yahoo Mailfrom rendering media query styles ondesktop.*/ table[id="miroirBody"], table[class="flexibleContainer"]{width:100% !important;}table[id="emailBody"], table[class="flexibleContainer"]{width:100% !important;} table[id="footerBody"], table[class="flexibleContainer"]{width:100% !important;} img[class="flexibleImage"]{height:auto !important; width:100% !important;}/*Make buttons in the email span thefull width of their container, allowingfor left- or right-handed ease of use.*/table[class="emailButton"]{width:100% !important;}td[class="buttonContent"]{padding:0 !important;}td[class="buttonContent"] a{padding:15px !important;}td[class="textContentLast"], td[class="imageContentLast"]{padding-top:20px !important;}/*////// GENERAL STYLES //////*/td[id="bodyCell"]{padding-top:10px !important; padding-Right:10px !important; padding-Left:10px !important;}}</style> <!--[if mso 12]> <style type="text/css"> </style> <![endif]--> <!--[if mso 14]> <style type="text/css"> </style> <![endif]--> </head> <body style="margin: 0;padding: 0;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;background-color: #f0f1f4;height: 100% !important;width: 100% !important;"> <center> <table border="0" cellpadding="0" cellspacing="0" height="100%" width="100%" id="bodyTable" style="border-collapse: collapse;mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;margin: 0;padding: 0;background-color: #f0f1f4;height: 100% !important;width: 100% !important;"> <tr> <td align="center" valign="top" id="bodyCell" style="mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;margin: 0;padding: 0;padding-top: 20px;padding-bottom: 40px;height: 100% !important;width: 100% !important;"> <!-- EMAIL CONTAINER // --> <table border="0" cellpadding="0" cellspacing="0" width="600" id="miroirBody" style="border-collapse: separate;mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;background-color: ##f0f1f4;padding-bottom: 20px;"> <!-- MODULE ROW // --> <tr> <td align="center" valign="top" style="mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse;mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"> <tr> <td align="center" valign="top" style="mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"> <table border="0" cellpadding="0" cellspacing="0" width="600" class="flexibleContainer" style="border-collapse: collapse;mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"> <tr> <td align="center" valign="top" width="600" class="flexibleContainerCell miroir" style="mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;padding-top: 30px;padding-right: 20px;padding-left: 20px;"> <!-- CONTENT TABLE // --> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse;mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"> <tr> <td valign="top" class="textContent header a" style="mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;color: #404040;font-family: Helvetica;font-size: 14px !important;line-height: 125%;text-align: right !important;padding-bottom: 0px !important;"> <!--<a href="#">Voir la version en ligne</a>--> </td> </tr> </table> <!-- // CONTENT TABLE --> </td> </tr> </table> <!-- // FLEXIBLE CONTAINER --> </td> </tr> </table> <!-- // CENTERING TABLE --> </td> </tr> <!-- // MODULE ROW --> </table> <table border="0" cellpadding="0" cellspacing="0" width="600" id="emailBody" style="border-collapse: separate;mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;background-color: #FFFFFF;border: 1px solid #DDDDDD;border-radius: 4px;"> <!-- MODULE ROW // --> <tr> <td align="center" valign="top" style="mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"> <!-- CENTERING TABLE // --> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse;mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"> <tr> <td align="center" valign="top" style="mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"> <!-- FLEXIBLE CONTAINER // --> <table border="0" cellpadding="0" cellspacing="0" width="600" class="flexibleContainer" style="border-collapse: collapse;mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"> <tr> <td align="center" valign="top" width="600" class="flexibleContainerCell logoContainer" style="mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;padding-top: 0px;padding-right: 0px;padding-left: 0px;padding-bottom: 0px;"> <!-- CONTENT TABLE // --> <!-- The table cell imageContent has padding applied to the bottom as part of the framework, ensuring images space correctly in Android Gmail. --> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse;mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"> <tr> <td valign="top" class="imageContent espacetexte" style="mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;padding-bottom: 0px;"> <a href="https://www.homly-you.com" target="_blank" style="-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"><img src="https://c.eu6.content.force.com/servlet/servlet.ImageServer?id=01558000000eEvI&oid=00D58000000Iuhr&lastMod=1464252878000" width="605" class="flexibleImage" style="max-width: 605px;border: 0;outline: none;text-decoration: none;-ms-interpolation-mode: bicubic;height: auto;"></a> </td> </tr> </table> <!-- // CONTENT TABLE --> </td> </tr> </table> <!-- // FLEXIBLE CONTAINER --> </td> </tr> </table> <!-- // CENTERING TABLE --> </td> </tr> <!-- // MODULE ROW --> <!-- MODULE ROW // --> <tr> <td align="center" valign="top" style="mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse;mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"> <tr> <td align="center" valign="top" style="mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"> <table border="0" cellpadding="0" cellspacing="0" width="600" class="flexibleContainer" style="border-collapse: collapse;mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"> <tr> <td align="center" valign="top" width="600" class="flexibleContainerCell" style="mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;padding-top: 20px;padding-right: 20px;padding-left: 20px;"> <!-- CONTENT TABLE // --> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse;mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"> <tr> <td valign="top" class="textContent interligne hy a" style="mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;color: #404040;font-family: Helvetica;font-size: 15px;line-height: 180%;text-align: Left;padding-bottom: 20px;">Bonjour,<br><br>Veuillez trouver ci-après l’ensemble des mises en relation réalisées hier sur les projets de particuliers que vous nous vous avez communiqués :<br>';
    private static String EMAIL_FOOTER = 'Nous vous souhaitons de bonnes ventes et toujours plus de collecte de projets de particuliers.<br><br> L\'équipe <a href="https://www.homly-you.com" target="_blank" style="-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;color: #e9425c;text-decoration: none;line-height: 150%;">Homly You</a><br><br></td></tr> </table> <!-- // CONTENT TABLE --> </td> </tr> </table> <!-- // FLEXIBLE CONTAINER --> </td> </tr> </table> <!-- // CENTERING TABLE --> </td> </tr> <!-- // MODULE ROW --> </table> <!-- // EMAIL CONTAINER --> <table border="0" cellpadding="0" cellspacing="0" width="600" id="footerBody" style="border-collapse: separate;mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;background-color: ##f0f1f4;"> <!-- MODULE ROW // --> <tr> <td align="center" valign="top" style="mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse;mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"> <tr> <td align="center" valign="top" style="mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"> <table border="0" cellpadding="0" cellspacing="0" width="600" class="flexibleContainer" style="border-collapse: collapse;mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"> <tr> <td align="center" valign="top" width="600" class="flexibleContainerCell" style="mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;padding-top: 20px;padding-right: 20px;padding-left: 20px;"> <!-- CONTENT TABLE // --> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="border-collapse: collapse;mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"> <tr> <td valign="top" class="footerContent footer a" style="mso-table-lspace: 0pt;mso-table-rspace: 0pt;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;color: #404040;font-family: Helvetica;font-size: 11px;line-height: 125%;text-align: center;padding-bottom: 40px;"> À tout moment, vous disposez d\'un droit d\'accès, de modification, de rectification et de suppression des données qui vous concernent (art. 34 de la loi Informatique et Libertés du 6 janvier 1978). <a href="www.homly-you.com/mentions-legales" style="-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;color: #e9425c;"><u>Consulter nos mentions légales</u></a>.<br><br> </td></tr> </table> <!-- // CONTENT TABLE --> </td> </tr> </table> <!-- // FLEXIBLE CONTAINER --> </td> </tr> </table> <!-- // CENTERING TABLE --> </td> </tr> <!-- // MODULE ROW --> </table> </td> </tr> </table> </center> </body></html>';
    
    public Batch_MERSelectionResume() {}
    
    public Database.QueryLocator start(Database.BatchableContext BC) {

        query = 'SELECT Id, Projet__r.Categorie_lkp__r.Name, Projet__r.Source__c, Projet__r.Code_postal__r.Name, Projet__r.Particulier__r.Name, Projet__r.Particulier__r.Salutation, Projet__c, Projet__r.CreatedDate, Projet__r.Adresse_mail__c, Professionnel__r.Name, Professionnel__r.SIRET_texte__c, Professionnel__r.Code_client_Point_P__c, Professionnel__r.Code_postal__r.Name, Professionnel__r.Code_postal__r.Libelle__c, Date_de_s_lection__c FROM Intermediation__c WHERE Projet__r.Adresse_mail__c != null AND Date_de_s_lection__c = YESTERDAY ORDER BY Projet__r.Adresse_mail__c DESC, Projet__r.CreatedDate DESC, Professionnel__r.Name ASC';
        if(test.Isrunningtest()){
            query = 'SELECT Id, Projet__r.Categorie_lkp__r.Name, Projet__r.Source__c, Projet__r.Code_postal__r.Name, Projet__r.Particulier__r.Name, Projet__r.Particulier__r.Salutation, Projet__c, Projet__r.CreatedDate, Projet__r.Adresse_mail__c, Professionnel__r.Name, Professionnel__r.SIRET_texte__c, Professionnel__r.Code_client_Point_P__c, Professionnel__r.Code_postal__r.Name, Professionnel__r.Code_postal__r.Libelle__c, Date_de_s_lection__c FROM Intermediation__c WHERE Projet__r.Adresse_mail__c != null ORDER BY Projet__r.Adresse_mail__c DESC, Projet__r.CreatedDate DESC, Professionnel__r.Name ASC';
        }

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {

        String content = null;
        String toAddress = null;
        Id projectId = null;
        Set<String> ccAddressSet = new Set<String>();

        List<EmailMassHelper.EmailDefination> emailList = new List<EmailMassHelper.EmailDefination>();
        String adresse = Label.OWEmailAddressesNoReply;
        OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :adresse];

        for (Intermediation__c mer : (list<Intermediation__c>)scope) {
            if (toAddress != null && toAddress != mer.Projet__r.Adresse_mail__c) {

				content += '</ul></p>' + EMAIL_FOOTER;
				
                EmailMassHelper.EmailDefination myEmail = new EmailMassHelper.EmailDefination();
                myEmail.emailHtmlBody = content;
                myEmail.fromAddress = owea.Id;
                myEmail.toAddressList = new String[]{toAddress};
                myEmail.emailSubject = EMAIL_SUBJECT;
                myEmail.ccAddressList = new List<String>(ccAddressSet);
                emailList.add(myEmail);

                
                toAddress = mer.Projet__r.Adresse_mail__c;
                projectId = mer.Projet__r.Id;
                content = EMAIL_HEADER;
                content += '<p style="margin: 1em 0;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"><strong>' + mer.Projet__r.Categorie_lkp__r.Name + ' / ' +
                          mer.Projet__r.Code_postal__r.Name + ' / ' + 
                          mer.Projet__r.Particulier__r.Salutation + ' ' +
                          mer.Projet__r.Particulier__r.Name + '</strong> déposé le ' + 
                          (mer.Projet__r.CreatedDate).format('dd/MM/yyyy') + '</p><p style="margin: 1em 0;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"><ul>';

                content += '<li style="-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;">Envoyé le <strong>' + (mer.Date_de_s_lection__c).format() + '</strong> à <strong>' + 
                           mer.Professionnel__r.Name + '</strong>'; 
                content += (mer.Professionnel__r.SIRET_texte__c == null || mer.Professionnel__r.SIRET_texte__c == '') ? ', ' : (' - ' + mer.Professionnel__r.SIRET_texte__c + ', ');          
                content += (mer.Professionnel__r.Code_client_Point_P__c == null || mer.Professionnel__r.Code_client_Point_P__c == '') ? ' ' : ('<strong>' + mer.Professionnel__r.Code_client_Point_P__c + '</strong> - ');
                content += mer.Professionnel__r.Code_postal__r.Name + ' ' + mer.Professionnel__r.Code_postal__r.Libelle__c + '</li>';
            	ccAddressSet = new Set<String>();
            	 if (mer.Projet__r.Source__c != null && (mer.Projet__r.Source__c).containsIgnoreCase('Lapeyre')) {
                	ccAddressSet.addAll((Label.EnseigneEmailLapeyre).split(';'));
                }
            } else if (toAddress == null || toAddress == mer.Projet__r.Adresse_mail__c){

                if (toAddress == null) {
                    toAddress = mer.Projet__r.Adresse_mail__c;
                    content = EMAIL_HEADER;
                }
                
                if (projectId == null || projectId != mer.Projet__r.Id) {
                    //New project for the same agency
                    if (projectId != null) {
                    	content += '</ul></p>';
                    }
                    projectId = mer.Projet__r.Id;

                    if (mer.Projet__r.Source__c != null && (mer.Projet__r.Source__c).containsIgnoreCase('Lapeyre')) {
	                	ccAddressSet.addAll((Label.EnseigneEmailLapeyre).split(';'));
	                }

                    content = (content == null ? '': content);
                    content += '<p style="margin: 1em 0;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"><strong>' + mer.Projet__r.Categorie_lkp__r.Name + ' / ' +
                          mer.Projet__r.Code_postal__r.Name + ' / ' + 
                          mer.Projet__r.Particulier__r.Salutation + ' ' +
                          mer.Projet__r.Particulier__r.Name + '</strong> déposé le ' + 
                          (mer.Projet__r.CreatedDate).format('dd/MM/yyyy') + '</p><p style="margin: 1em 0;-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;"><ul>';
                }
                
                content += '<li style="-ms-text-size-adjust: 100%;-webkit-text-size-adjust: 100%;">Envoyé le <strong>' + (mer.Date_de_s_lection__c).format() + '</strong> à <strong>' + 
                           mer.Professionnel__r.Name + '</strong>'; 
                content += (mer.Professionnel__r.SIRET_texte__c == null || mer.Professionnel__r.SIRET_texte__c == '') ? ', ' : (' - ' + mer.Professionnel__r.SIRET_texte__c + ', ');          
                content += (mer.Professionnel__r.Code_client_Point_P__c == null || mer.Professionnel__r.Code_client_Point_P__c == '') ? ' ' : ('<strong>' + mer.Professionnel__r.Code_client_Point_P__c + '</strong> - ');
                content += mer.Professionnel__r.Code_postal__r.Name + ' ' + mer.Professionnel__r.Code_postal__r.Libelle__c + '</li>';
            }
        }
        
        if (toAddress != null) {
        	content += '</ul></p>' + EMAIL_FOOTER;
        	
            EmailMassHelper.EmailDefination myEmail = new EmailMassHelper.EmailDefination();
            myEmail.emailHtmlBody = content;
            //myEmail.emailTextBody = content;
            myEmail.fromAddress = owea.Id;
            myEmail.toAddressList = new String[]{toAddress};
            myEmail.emailSubject = EMAIL_SUBJECT;
            myEmail.ccAddressList = new List<String>(ccAddressSet);
            emailList.add(myEmail);
        }

        EmailMassHelper.sendEmailMass(emailList);
    }
    public void finish(Database.BatchableContext BC) {
        
    }
    
    public void execute(SchedulableContext context) {
        Batch_MERSelectionResume b = new Batch_MERSelectionResume(); 
        database.executebatch(b);
    }
    
}