public with sharing class APlan_Melding implements Comparable {
    @AuraEnabled
    public APlan_AvsenderType avsenderType;
    @AuraEnabled
    public Datetime sendt_dato;
    @AuraEnabled
    public Boolean lest;
    @AuraEnabled
    public String meldingstekst;

    @AuraEnabled
    public String avsenderTypeString {
        get {
            return this.avsenderType.name();
        }
    }

    public Integer compareTo(Object compareTo) {
        APlan_Melding comparePeriod = (APlan_Melding) compareTo;
        Integer retVal = 0;
        if (this.sendt_dato > comparePeriod.sendt_dato) {
            retVal = 1;
        } else if (this.sendt_dato < comparePeriod.sendt_dato) {
            retVal = -1;
        }

        return retVal;
    }
}
