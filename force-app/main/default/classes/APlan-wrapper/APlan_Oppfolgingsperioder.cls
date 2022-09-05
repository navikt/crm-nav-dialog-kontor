public with sharing class APlan_Oppfolgingsperioder {
    @AuraEnabled
    public List<APlan_Oppfolgingsperiode> oppfolgingsperioder {
        get {
            this.oppfolgingsperioder.sort();
            return this.oppfolgingsperioder;
        }
    }
    @AuraEnabled
    public List<APlan_Feil> feil;
}
