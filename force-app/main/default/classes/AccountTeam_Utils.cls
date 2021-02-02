/**
 * @File Name          : AccountTeam_Utils.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 4/26/2020, 12:59:16 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    3/16/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
public class AccountTeam_Utils 
{

    public AccountTeam_Utils()
    { }

    /**
     ** PageReference calculateTCReference()
     ** ------------------------------------
     ** Called by Account button to recalculate who is the TC Référent
     **/
    public PageReference calculateTCReference()
    {
        Id accId = apexpages.currentpage().getparameters().get('AccountId');
        String proOrPart = apexpages.currentpage().getparameters().get('typeClient');

        List<AccountTeamMember> lAccTeamMember = [SELECT Id, AccountId, UserId, TeamMemberRole FROM AccountTeamMember WHERE AccountId =: accId];
        AccountTeam_Utils.Account_calculateTCReference(accId, lAccTeamMember, proOrPart, true);
        
        return (new PageReference('/' + accId));
    }

    
    public static Account Account_calculateTCReference(Id accId, List<AccountTeamMember> lAccTeamMember, String ProOrPart, Boolean updateAction)
    {
        if (accId != null)
        {
            Id tcReferent = null;
            
            // Get all Account team member
            if (lAccTeamMember != null && lAccTeamMember.size() > 0)
            {
                Id tcServiceCommercial, tcServiceClientPRO, ITCS, tcServiceClientPART = null;
                
                // Find which member is set
                for (AccountTeamMember member : lAccTeamMember)
                {
                    //if (member.TeamMemberRole == 'ATC SERVICE')
                        //atcService = member.UserId;
                    if (member.TeamMemberRole == 'TC Service Commercial')
                        tcServiceCommercial = member.UserId;
                    if (member.TeamMemberRole == 'TC Service Client PRO')
                        tcServiceClientPRO = member.UserId;
                    if (member.TeamMemberRole == 'TC Service Client PART')
                        tcServiceClientPART = member.UserId;
                    if (member.TeamMemberRole == 'ITCS')
                        ITCS = member.UserId;
                }
                
                // Set the TC Referent depending on the members
                if (proOrPart == 'Part')
                    //tcReferent = tcServiceClient;
                    tcReferent = tcServiceClientPART;
                else
                {
                    if (tcServiceClientPRO != null)
                        tcReferent = tcServiceClientPRO;
                    else if (tcServiceCommercial != null)
                        tcReferent = tcServiceCommercial;
                    //else if (atcService != null)
                        //tcReferent = atcService;
                    else if (ITCS != null)
                        tcReferent = ITCS;
                }
            }
            
            // Update the TC Référent of the account
            if (tcReferent != null)
            {
                Account acc = new Account();
                acc.Id = accId;
                acc.TC_Referent__c = tcReferent;
                if (updateAction == true)
                    update acc;
                return (acc);
            }
            else
            {
                Account acc = new Account();
                acc.Id = accId;
                acc.TC_Referent__c = null;
                if (updateAction == true)
                    update acc;
                return (acc);                
            }
        }
        
        return (null);
    }

}