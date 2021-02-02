public class VFC_Export_Expansion_Lead {
   
    public string header{get;set;}
    public List<wrapper> lstwrapper {get; set;}
    public class wrapper{
        public string IDLead {get; set;}
        public string DateSelecPro {get; set;}
        public string LibelleLead {get; set;}
        public string CodePostal {get; set;}
        public string Ville {get; set;}
        public string IdentifiantHY {get; set;}
        public string CodeClientPointP {get; set;}   
        public string Statut{get; set;}  
    }
   
    public string Filetype{get;set;}
    public boolean isExcel {get;set;}
    public boolean isCsv {get;set;}   
 
    public VFC_Export_Expansion_Lead () {
            Filetype = '';
            lstwrapper = new List<wrapper>();
            header = 'IDLead;DateSelecPro;2;LibelleLead;4;5;CodePostal;Ville;8;9;IdentifiantHY;CodeClientPP;12;Statut';                     
    }
 
   
    public void VFC_Export_Expansion_Lead(){
          string queryString = 'select Name,Statut__c, Date_de_s_lection__c, Projet__r.Flux_Categorie__c, Projet__r.Ville__c, Projet__r.Zip_code__c, Professionnel__r.Code_client_Point_P__c from Intermediation__c where Date_de_s_lection__c != null and isDeleted = false and Professionnel__r.Code_client_Point_P__c != null and Professionnel__r.Statut_global__c = \'CLIENT\' and Professionnel__r.isDeleted = false';
          List<Intermediation__c> subData = DataBase.Query(queryString);
          if(subData.size()>0){
              for(Intermediation__c sub : subData){
                  wrapper w = new wrapper();
                  w.IDLead = string.valueOf(sub.Name);
                  w.DateSelecPro = string.valueOf(sub.Date_de_s_lection__c);
                  w.LibelleLead = string.valueOf(sub.Projet__r.Flux_Categorie__c);
                  w.Ville = string.valueOf(sub.Projet__r.Ville__c);
                  w.CodePostal = string.valueOf(sub.Projet__r.Zip_code__c);
                  w.CodeClientPointP = string.valueOf(sub.Professionnel__r.Code_client_Point_P__c);
                  w.Statut = string.valueOf(sub.Statut__c);
                  lstwrapper.add(w);               
              }             
          }
    }
}