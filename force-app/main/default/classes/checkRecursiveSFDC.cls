public Class checkRecursiveSFDC
{
    public static boolean run = true;
    public static boolean runWF = true;
    public static boolean runSMS = true;
    public static boolean runEXCLU = true;
    public static boolean runGEOCAT = true;
    public static boolean runGODSON = true;


    
    public static boolean runOnce()
    {
      system.debug('TEST : checkRecursiveSFDC : runOnce ');
      if(run)
      {
        run=false;
        return true;
        }
        else
         {
            return run;
         }
   }
   
   public static boolean runSMSOnce()
    {
      system.debug('TEST : checkRecursiveSFDC : runSMSOnce ');
      if(runSMS)
      {
        runSMS = false;
        return true;
        }
        else
         {
            return runSMS;
         }
   }
}