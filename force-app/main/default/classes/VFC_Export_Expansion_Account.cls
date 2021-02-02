public class VFC_Export_Expansion_Account {
   
    public string header{get;set;}
    public List<wrapper> lstwrapper {get; set;}
    public class wrapper{
        public string CodeClientPointP {get; set;}
        public string isClient {get; set;}    
        public string hasIntermedOffre {get; set;}         
        public string hasCapRenovOffre {get; set;}         
     
    }
   
    public string Filetype{get;set;}
    public boolean isExcel {get;set;}
    public boolean isCsv {get;set;}   
 
    public VFC_Export_Expansion_Account () {
            Filetype = '';
            lstwrapper = new List<wrapper>();
            header = '0;1;2;CodeClientPointP;4;5;6;7;8;9;10;11;12;13;14;15;StatutClient;17;18;19;Etat Business+;Etat CapRenov+;Etat Solu+;23;24;25;26;27;28;29;Etat HomlyTravaux';                     
    }
 
   
    public void VFC_Export_Expansion_Account(){
          string queryString = 'select Zuora__Account__r.Code_client_Point_P__c, Zuora__Account__r.Statut_global__c, (select Zuora__ProductName__c FROM Zuora__Subscription_Product_Charges__r  WHERE IsDeleted = false) FROM Zuora__Subscription__c WHERE Zuora__Account__r.Code_client_Point_P__c != null AND Zuora__Account__r.Statut_global__c = \'CLIENT\' AND Zuora__Status__c = \'Active\' AND IsDeleted = false AND Zuora__Account__r.IsDeleted = false';
          List<Zuora__Subscription__c> subData = DataBase.Query(queryString);
          if(subData.size()>0){
              for(Zuora__Subscription__c sub : subData){
                  wrapper w = new wrapper();
                  w.CodeClientPointP = string.valueOf(sub.Zuora__Account__r.Code_client_Point_P__c);
                  w.isClient = (string.valueOf(sub.Zuora__Account__r.Statut_global__c) == 'CLIENT' ? 'New PP' : '');
                  for (Zuora__SubscriptionProductCharge__c charge : sub.Zuora__Subscription_Product_Charges__r) {
                      if (charge.Zuora__ProductName__c == 'Offre Homly Travaux')
                          w.hasIntermedOffre = 'Client';
                      else if (charge.Zuora__ProductName__c == 'Offre Caprenov +')
                          w.hasCapRenovOffre = 'Client';
                  }
                  lstwrapper.add(w);               
              }             
          }
    }
}