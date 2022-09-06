public with sharing class APlan_Oppfolgingsinfo {
    @AuraEnabled
    public Boolean underOppfolging;
    @AuraEnabled
    public String primaerVeileder;
    @AuraEnabled
    public OppfolgingsEnhet OppfolgingsEnhet;

    public class OppfolgingsEnhet {
        @AuraEnabled
        public String enhetId;
        @AuraEnabled
        public String navn;
    }
}
