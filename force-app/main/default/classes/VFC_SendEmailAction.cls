public class VFC_SendEmailAction {
    List<SelectOption> templates;
    public String selectedvalue{get; set;}
    public String EmailTemplateValue{get; set;}
    public List<SelectOption> getTemplates() {
        return templates;
    }
    public void setTemplates(List<SelectOption> templates) {
        this.templates=templates;
    }
    
    public VFC_SendEmailAction(ApexPages.StandardController controller) {
        String templateFoldertoRetreive='Template_manuel';
        templateFoldertoRetreive = String.escapeSingleQuotes(templateFoldertoRetreive);
        templates = new List<SelectOption>(); 
        templates.add(New SelectOption('Aucun','Sélectionnez un modèle:'));
        for (EmailTemplate et : [Select Id, Name, Subject, Body,Markup,HtmlValue, IsActive, Folder.Name, Folder.DeveloperName From EmailTemplate Where IsActive = true And Folder.DeveloperName = :templateFoldertoRetreive Order by Name]) {
            templates.add(New SelectOption(et.Id,et.Name));
        }
    }
    
    public void retreiveTemplate() {
        System.debug('selectedvalue ' + selectedvalue);
        List<EmailTemplate> temps = [Select Id, Name, Subject, Body, Markup,HtmlValue
                                         From EmailTemplate Where IsActive = true And Id = :selectedvalue];        
        if (temps.size()>0 && temps[0].Id!=null) {
            //bodies.add(templates[0].Body);
             List<String> bodies = new List<String>();
            bodies.add(temps[0].HtmlValue);
            List<Messaging.RenderEmailTemplateBodyResult> RenderResult = new List<Messaging.RenderEmailTemplateBodyResult>();
            RenderResult = Messaging.renderEmailTemplate('0013E00000HJQKD', 'a013E000001SajH', bodies);
            System.debug('>>>>> VFC_SendEmail email body = ' + RenderResult); 
            EmailTemplateValue = RenderResult[0].getMergedBody();  
        }
    }
}