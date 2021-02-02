trigger CapitalizeName on Contact( before insert , before update)
    {
        for(Contact c : Trigger.new)
            {
                if(c.FirstName != null)
                    c.FirstName =  c.FirstName.subString(0 ,1).ToUpperCase() +  c.FirstName.subString(1);
                    
                c.LastName =  c.LastName.subString(0 ,1).ToUpperCase() +  c.LastName.subString(1);
            }
    }