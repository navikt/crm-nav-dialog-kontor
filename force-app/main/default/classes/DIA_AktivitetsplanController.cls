public with sharing class DIA_AktivitetsplanController {
    @AuraEnabled(cacheable=true)
    public static APlan_Oppfolgingsinfo getOppfolgingsInfo(String actorId) {
        return DIA_AktivitetsplanService.getOppfolgingsInfo(actorId);
    }
}
