public with sharing class APlan_Dialog {
    @AuraEnabled
    public Datetime dialog_start;
    @AuraEnabled
    public String tittel;
    @AuraEnabled
    public Boolean ventersvarnav;
    @AuraEnabled
    public Boolean ventersvarbruker;
    @AuraEnabled
    public List<APlan_Melding> meldinger {
        get {
            if (this.meldinger != null) {
                this.meldinger.sort();
            }
            return this.meldinger;
        }
    }
}
