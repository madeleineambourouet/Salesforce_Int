public class VFC_Export_Part {
public string header{get;set;}
    public List<wrapper> lstwrapper {get; set;}
    public class wrapper{
        public string PersonEmail {get; set;}
        public string Name {get; set;}
        
    }
   
    public string Filetype{get;set;}
    public boolean isExcel {get;set;}
    public boolean isCsv {get;set;}   
 
    public VFC_Export_Part () {
            Filetype = '';
            lstwrapper = new List<wrapper>();
            header = 'PersonEmail;Name';                     
    }
 
   
    public void VFC_Export_Part(){
          string queryString = 'select Name,PersonEmail from Account where IsPersonAccount = true and isDeleted = false and (Desinscription_newsletter__c = false or PersonHasOptedOutOfEmail = false)';
          List<Account> subData = DataBase.Query(queryString);
          if(subData.size()>0){
          
              for(Account sub : subData){
                  wrapper w = new wrapper();
                  w.PersonEmail = string.valueOf(sub.PersonEmail);
                  w.Name = string.valueOf(sub.Name);
                  
                  lstwrapper.add(w);               
              }             
          }
    }
}