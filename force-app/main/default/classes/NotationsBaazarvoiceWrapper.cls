/**
* @author Clement Musabimana
* @date 18/06/2018
* @description Modele de données à récupérer dans le flux JSON retourné par l'API Reviews de Baazarvoice
**/
public class NotationsBaazarvoiceWrapper {


    public class Error {
        public String Code {get; set;}
        public String Message {get; set;}
    }

    public class ContextDataItem {
        public String Id {get; set;}
        public String Value {get; set;}
        public String ValueLabel {get; set;}
        public String DimensionLabel {get; set;}
    }

    public class ContextDataValuesItem {
        public ContextDataItem ContactPro {get; set;}
    }

    public class ProjectIdItem {
        public String Id {get; set;}
        public String Value {get; set;}
        public String Label {get; set;}
    }

    public class AdditionalFieldsItem {
        public ProjectIdItem ProjectId {get; set;}
    }

    public class Notation {
        public String Id {get; set;}
        public String LastModeratedTime {get; set;}
        public String LastModificationTime {get; set;}
        public String SubmissionTime {get; set;}
        public String Rating {get; set;}
        public String ModerationStatus {get; set;}
        public String ReviewText {get; set;}
        public String Title {get; set;}
        public String[] ModeratorCodes {get; set;}
        public ContextDataValuesItem ContextDataValues {get; set;}
        public AdditionalFieldsItem AdditionalFields {get; set;}
    }

    public class DataNotations {
        //public String Limit {get; set;}
        public Integer Offset {get; set;}
        public Integer TotalResults {get; set;}
        public List<Notation> Results {get; set;}
        public Boolean HasErrors {get; set;}
        public List<Error> Errors {get; set;}
    }


}