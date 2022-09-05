public with sharing class APlan_Oppfolgingsinfo {
    @AuraEnabled
    public Boolean underOppfolging;
    @AuraEnabled
    public String primaerVeileder;
    @AuraEnabled
    public OppfolgingsEnhet OppfolgingsEnhet;
    @AuraEnabled
    public List<APlan_Feil> feil;

    public class OppfolgingsEnhet {
        @AuraEnabled
        public String enhetId;
        @AuraEnabled
        public String navn;
    }
}
