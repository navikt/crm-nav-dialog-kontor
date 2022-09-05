public with sharing class APlan_Oppfolgingsperiode implements Comparable {
    @AuraEnabled
    public Datetime startDato;
    @AuraEnabled
    public Datetime sluttDato;
    @AuraEnabled
    public List<APlan_Dialog> dialoger;
    @AuraEnabled
    public List<APlan_Aktivitet> aktiviteter;

    @AuraEnabled
    public Boolean activePeriod {
        get {
            return Datetime.now() > this.startDato && (Datetime.now() < this.sluttDato || this.sluttDato == null);
        }
        private set {
        }
    }

    @AuraEnabled
    public String startDatoString {
        get {
            return this.startDato?.format('dd.MM.YYYY');
        }
        private set {
        }
    }

    @AuraEnabled
    public String sluttDatoString {
        get {
            return this.sluttDato?.format('dd.MM.YYYY');
        }
        private set {
        }
    }

    public Integer compareTo(Object compareTo) {
        APlan_Oppfolgingsperiode comparePeriod = (APlan_Oppfolgingsperiode) compareTo;
        Integer retVal = 0;
        if (this.startDato > comparePeriod.startDato) {
            retVal = -1;
        } else if (this.startDato < comparePeriod.startDato) {
            retVal = 1;
        }

        return retVal;
    }
}
