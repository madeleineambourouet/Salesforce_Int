trigger CategorieExclusionTrigger on CompetenceCategorie__c (before insert, after insert, after delete) {

	if (Trigger.isInsert) {
		CategorieExclusionTrigger.OnIHM(Trigger.new);
		if (Trigger.isAfter && checkRecursiveSFDC.runEXCLU){
			CategorieExclusionTrigger.GetBackChanges(Trigger.new);
			checkRecursiveSFDC.runEXCLU = false;
		}
	}

	if (Trigger.isDelete) {
		CategorieExclusionTrigger.GetBackChanges(Trigger.old);
	}
}