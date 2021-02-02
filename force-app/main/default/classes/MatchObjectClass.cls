/**
 * @File Name          : MatchObjectClass.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 6/27/2020, 5:17:37 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/1/2020   Hassan Dakhcha     Initial Version
**/
public class MatchObjectClass {
    public MatchObjectClass(String AccountName, String AccountURL, String ProjectName, 
                            String ProjectURL, String PartName, String PartURL, 
                            String Status, Datetime createdAt, Boolean positionable,
                             Boolean viewable, String positionedCount, String BesoinTravauxName, String BesoinTravauxURL) {
        this.AccountName = AccountName;
        this.AccountURL = AccountURL;
        this.ProjectName = ProjectName;
        this.ProjectURL = ProjectURL;
        this.PartName = PartName;
        this.PartURL = PartURL;
        this.Status = Status;
        this.createdAt = createdAt;
        this.positionable = positionable;
        this.viewable = viewable;
        this.positionedCount = positionedCount;
        this.BesoinTravauxName = BesoinTravauxName;
        this.BesoinTravauxURL = BesoinTravauxURL;
    }

    @AuraEnabled
    public String AccountName { get;set; }
    @AuraEnabled
    public String AccountURL { get;set; }
    @AuraEnabled
    public String ProjectName { get;set; }
    @AuraEnabled
    public String ProjectURL { get;set; }
    @AuraEnabled
    public String PartName { get;set; }
    @AuraEnabled
    public String PartURL { get;set; }
    @AuraEnabled
    public String BesoinTravauxName { get;set; }
    @AuraEnabled
    public String BesoinTravauxURL { get;set; }
    @AuraEnabled
    public String Status { get;set; }   
    @AuraEnabled
    public Datetime createdAt { get;set; }
    @AuraEnabled
    public Boolean positionable { get;set; }
    @AuraEnabled
    public Boolean viewable { get;set; }
    @AuraEnabled
    public String positionedCount { get;set; }
}