/**
 * @File Name          : ALgo_Luhn.cls
 * @Description        : 
 * @Author             : Hassan Dakhcha
 * @Group              : 
 * @Last Modified By   : Hassan Dakhcha
 * @Last Modified On   : 5/30/2020, 1:01:39 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/29/2020   Hassan Dakhcha     Initial Version
**/
public class ALgo_Luhn {

    @InvocableMethod
    public static List<Boolean> ALgo_Luhn(List<String> ibanList) {

        String IBAN = ibanList[0];
        List<Boolean> result = new List<Boolean>();
        System.debug('##### HDAK IBAN ' + IBAN);

        Map<String, String> mapCodeLetters = new Map<String, String>{'A'=> '10', 'B'=> '11', 'C'=> '12', 'D'=> '13', 'E'=> '14', 'F'=> '15', 'G'=> '16', 'H'=> '17', 'I'=> '18',
                                                                       'J'=> '19', 'K'=> '20', 'L'=> '21', 'M'=> '22', 'N'=> '23', 'O'=> '24', 'P'=> '25', 'Q'=> '26', 'R'=> '27',
                                                                       'S'=> '28', 'T'=> '29', 'U'=> '30', 'V'=> '31', 'W'=> '32', 'X'=> '33', 'Y'=> '34', 'Z'=> '35'};
        // Replace void
        String IBAN_2 ='';
        for(Integer i = 0 ; i < IBAN.length() ; i++) {
            //System.debug('##### HDAK substring ' + IBAN.substring(i,i+1));
            if(IBAN.substring(i,i+1) != ' ') {
              IBAN_2 += IBAN.substring(i,i+1);
            }
        }
        System.debug('##### HDAK IBAN_2 ' + IBAN_2);

        IBAN = IBAN_2;

        if(IBAN.length() != 27 && IBAN.length() != 25) {
            result.add(FALSE);
            return result;
        }

        String country_code = IBAN.substring(0,2);
        String iban_key = IBAN.substring(2,4);
        String numValue = IBAN.substring(4);
        numValue += country_code+iban_key;

        System.debug('##### HDAK country_code ' + country_code);
        System.debug('##### HDAK iban_key ' + iban_key);
        System.debug('##### HDAK numValue ' + numValue);

        // replace chars in value
        String newValue ='';
        for(Integer i=0 ; i<numValue.length(); i++) {
            if(mapCodeLetters.get(numValue.substring(i,i+1)) == null) {
                newValue += numValue.substring(i,i+1);
            } else {
                newValue += mapCodeLetters.get(numValue.substring(i,i+1));
            }
        }
 
        // Modulo 97
        Long moduCst = 97;
        String subStr = '';
        Long div = 0;
        for(Integer i=0 ; i<= 27 ; i=i+9 ) {

            System.debug('##### HDAK newVALUE  #' + newValue + '#');

            subStr = newValue.length()<=9 ?  newValue : newValue.substring(0,9);
            
            System.debug('##### HDAK substr  #' + subStr + '#');

            div = math.mod(Long.valueOf(subStr), moduCst);
            String res = String.valueOf(div);
            System.debug('##### HDAK  div  #' + div + '#');
            System.debug('##### HDAK  res  #' + res + '#');
            if(newValue.length()<=9)
                break;
            newValue = res + newValue.substring(9);
 
        }
    
        if(div == 1)  {
            result.add(TRUE);
       } else {
           result.add(FALSE);
       }

       return result;
     
    }
}