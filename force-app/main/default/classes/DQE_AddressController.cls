public class DQE_AddressController 
{
    public Object   controller  {get;set;}
    public Account  recordAccount      {get;set;}
    public Contact  recordContact      {get;set;}
    public Lead  recordLead      {get;set;}
    public String   objectType    {get;set;}
    public String   fieldPays {get;set;}
    public String   fieldCP {get;set;}
    
    public String   fieldStreet {get;set;}
    public String   fieldStreetLabel
    {
        get
        {
            if (recordAccount != null)
            {
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType accSchema = schemaMap.get('Account');
                Map<String, Schema.SObjectField> fieldMap = accSchema.getDescribe().fields.getMap();
                return (fieldMap.get(fieldStreet).getDescribe().getLabel());
            }
            else if (recordContact != null)
            {
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType accSchema = schemaMap.get('Contact');
                Map<String, Schema.SObjectField> fieldMap = accSchema.getDescribe().fields.getMap();
                return (fieldMap.get(fieldStreet).getDescribe().getLabel());
            }
            else if (recordLead != null)
            {
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType accSchema = schemaMap.get('Lead');
                Map<String, Schema.SObjectField> fieldMap = accSchema.getDescribe().fields.getMap();
                return (fieldMap.get(fieldStreet).getDescribe().getLabel());
            }
            return ('');
        }
        set;
    }
    public String   fieldNumber {get;set;}
    public String   fieldNumberLabel
    {
        get
        {
            if (recordAccount != null)
            {
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType accSchema = schemaMap.get('Account');
                Map<String, Schema.SObjectField> fieldMap = accSchema.getDescribe().fields.getMap();
                return ((fieldMap != null ? fieldMap.get(fieldNumber).getDescribe().getLabel() : ''));
            }
            else if (recordContact != null)
            {
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType accSchema = schemaMap.get('Contact');
                system.debug('>>>>> accSchema: ' + accSchema);
                Map<String, Schema.SObjectField> fieldMap = accSchema.getDescribe().fields.getMap();
                system.debug('>>>>> fieldMap:' + fieldMap);
                system.debug('>>>>> fieldMap.get(fieldNumber):' + fieldMap.get(fieldNumber));
                system.debug('>>>>> fieldNumber: ' + fieldNumber);
                //return ((fieldMap != null ? fieldMap.get(fieldNumber).getDescribe().getLabel() : ''));
                return ('test');
            }
            else if (recordLead != null)
            {
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                Schema.SObjectType accSchema = schemaMap.get('Lead');
                Map<String, Schema.SObjectField> fieldMap = accSchema.getDescribe().fields.getMap();
                return ((fieldMap != null ? fieldMap.get(fieldNumber).getDescribe().getLabel() : ''));
            }
            return ('');
        }
        set;
    }
    
    public DQE_AddressController()
    {

    }
    
    public DQE_AddressController getPageCont()
	{
    	return this;
	}
    
}