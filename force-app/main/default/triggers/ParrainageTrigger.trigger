trigger ParrainageTrigger on Account (before update, before insert) {

	system.debug('checkRecursiveSFDC.runGODSON = ' + checkRecursiveSFDC.runGODSON);
	if (checkRecursiveSFDC.runGODSON == true) {
		String msg = ParrainageTrigger.beGodSon(trigger.new, trigger.oldMap, trigger.isInsert);
		if (msg != null) {
			trigger.new[0].addError(msg);
		}
		checkRecursiveSFDC.runGODSON = false;
	}

//	if (trigger.isUpdate)
//		ParrainageTrigger.subscribeGodSon(trigger.new, trigger.oldMap);
}