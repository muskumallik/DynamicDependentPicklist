public class multiselect {
    /**Controlling  Picklist**/
    Set<String> originalvalues = new Set<String>();
    Map<Object,List<String>> objMapDepValues ;
    Public List<string> leftselected{get;set;}
    Public List<string> rightselected{get;set;}
    Set<string> leftvalues = new Set<string>();
    Set<string> rightvalues = new Set<string>();
    /**Dependent  Picklist**/
    Set<String> originalChildvalues = new Set<String>();
    Public List<string> leftChildselected{get;set;}
    Public List<string> rightChildselected{get;set;}
    Set<string> leftChildvalues = new Set<string>();
    Set<string> rightChildvalues = new Set<string>();
    
    public multiselect(){
        originalvalues = new Set<String>();
        objMapDepValues = new Map<Object,List<String>>();
        objMapDepValues = multiselect.getDependentPicklistValues(Trailhead__c.Alphabet_Version__c);
        Schema.DescribeFieldResult fieldResult =  Trailhead__c.Alphabet__c.getDescribe();
        List<Schema.PicklistEntry> pickList = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : pickList){
            originalvalues.add(f.getValue());
        }    
        leftselected = new List<String>();
        rightselected = new List<String>();
        leftvalues.addAll(originalValues);
        leftChildselected = new List<String>();
        rightChildselected = new List<String>();
    }
    
    public PageReference selectclick(){
        rightselected.clear();
        leftChildvalues.clear();
        for(String s : leftselected){
            leftvalues.remove(s);
            rightvalues.add(s);
        }
        if(rightvalues.size() > 0){
            for(String s: rightvalues){
                leftChildvalues.addAll(objMapDepValues.get(s));
            }
        }
        return null;
    }
    
    public PageReference unselectclick(){
        leftselected.clear();
        leftChildvalues.clear();
        //rightChildvalues.clear();
        for(String s : rightselected){
            rightvalues.remove(s);
            leftvalues.add(s);
        }
         if(rightvalues.size() > 0){
            for(String s: rightvalues){
                leftChildvalues.addAll(objMapDepValues.get(s));
            }
             if(getSelectedChildValues().size() > 0){
                 for(SelectOption so: getSelectedChildValues()){
                     if(leftChildvalues.contains(so.getValue())){
                         leftChildvalues.remove(so.getValue());
                     }
                 }
             }
         } 
         return null;
    }
     public PageReference selectChildclick(){
        rightChildselected.clear();
         for(String s : leftChildselected){
            leftChildvalues.remove(s);
            rightChildvalues.add(s);
        }
        return null;
    }
    
    public PageReference unselectChildclick(){
        leftChildselected.clear();
         for(String s : rightChildselected){
            rightChildvalues.remove(s);
            leftChildvalues.add(s);
        }
        return null;
    }
    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftvalues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }
    
    public List<SelectOption> getSelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightvalues);
        tempList.sort();
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
        return options1;
    }
    public List<SelectOption> getunSelectedChildValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftChildvalues);
        tempList.sort();
        for(string s : tempList){
            if(!rightChildvalues.contains(s)){
            	options.add(new SelectOption(s,s));
            }
        }
        return options;
    }
    
    public List<SelectOption> getSelectedChildValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        system.debug(rightChildvalues);
        tempList.addAll(rightChildvalues);
        tempList.sort();
        for(String s : tempList){
            
            options1.add(new SelectOption(s,s));
        }
        return options1;
    }
    public static Map<Object,List<String>> getDependentPicklistValues( Schema.sObjectField dependToken ){
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if ( controlToken == null ) return null;
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries =
            (   control.getType() == Schema.DisplayType.Boolean
             ?   null
             :   control.getPicklistValues()
            );
        
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<Object,List<String>> dependentPicklistValues = new Map<Object,List<String>>();
        for ( Schema.PicklistEntry entry : depend.getPicklistValues() ) if ( entry.isActive() )
        {
            List<String> base64chars =
                String.valueOf
                (   ((Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( entry ) )).get( 'validFor' )
                ).split( '' );
            for ( Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++ )
            {
                Object controlValue =
                    (   controlEntries == null
                     ?   (Object) (index == 1)
                     :   (Object) (controlEntries[ index ].isActive() ? controlEntries[ index ].getLabel() : null)
                    );
                Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                if  (   controlValue == null
                     ||  (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0
                    ) continue;
                if ( !dependentPicklistValues.containsKey( controlValue ) )
                {
                    dependentPicklistValues.put( controlValue, new List<String>() );
                }
                dependentPicklistValues.get( controlValue ).add( entry.getLabel() );
            }
        }
        return dependentPicklistValues;
    }
    public void saveMethod(){
        Trailhead__c tc = new Trailhead__c();
        system.debug(rightselected);
        system.debug(rightChildselected);
        if(rightvalues.size() == 0){
             ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error ,'Please select the First picklist value'));
            return;
        }
        if(rightChildvalues.size() == 0){
             ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error ,'Please select the Second picklist value'));
            return;
        }
        List<String> valus =new List<String>();
        valus.addAll(rightvalues);
        tc.Selected_Alphabet__c = String.join(valus, ';');
        valus.clear();
        valus.addAll(rightChildvalues);
        tc.Selected_Alphabet_Version__c	 = String.join(valus, ';');
        insert tc;
    }
}