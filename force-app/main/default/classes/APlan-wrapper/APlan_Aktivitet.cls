public with sharing class APlan_Aktivitet {
    public APlan_AktivitetType aktivitet_type;
    @AuraEnabled
    public String aktivitet_type_navn;
    /*
    public String aktivitet_id;
    public String oppfolgingsperiode_id;
    */
    @AuraEnabled
    public Boolean avtalt_med_nav;
    public APlan_Status status;
    @AuraEnabled
    public String status_navn;
    @AuraEnabled
    public String beskrivelse;
    @AuraEnabled
    public String tittel;
    @AuraEnabled
    public Datetime fra_dato;
    @AuraEnabled
    public Datetime til_dato;
    @AuraEnabled
    public Datetime opprettet_dato;
    @AuraEnabled
    public Datetime endret_dato;
    @AuraEnabled
    public APlan_Dialog dialog;

    //Jobbsoeking, StillingFraNav
    @AuraEnabled
    public String arbeidsgiver;
    @AuraEnabled
    public String arbeidssted;

    //Sokeavtale
    @AuraEnabled
    public Integer antallStillingerIUken;
    @AuraEnabled
    public String avtaleOppfolging;

    //Behandling
    @AuraEnabled
    public String behandlingSted;

    //Mote, Samtalereferat
    @AuraEnabled
    public String kanal;
    @AuraEnabled
    public String referat;

    //Mote
    @AuraEnabled
    public String adresse;
    @AuraEnabled
    public String forberedelser;

    //StilligFraNav
    @AuraEnabled
    public APlan_CvKanDelesData cvKanDelesData;
    @AuraEnabled
    public String soknadsfrist;
    @AuraEnabled
    public Date svarfrist;
    public String bestillingsId;
    public String stillingsId;
    @AuraEnabled
    public String soknadsstatus;

    @AuraEnabled
    public String friendlyStatus {
        get {
            switch on this.status {
                when PLANLAGT {
                    return 'Planlagt';
                }
                when GJENNOMFORES {
                    return 'Gjennomføres';
                }
                when FULLFORT {
                    return 'Fullført';
                }
                when BRUKER_ER_INTERESSERT {
                    return 'Bruker er interessert';
                }
                when AVBRUTT {
                    return 'Avbrutt';
                }
                when else {
                    return 'Undefined';
                }
            }
        }
        private set {
        }
    }

    @AuraEnabled
    public String uniqueKey {
        get {
            return this.aktivitet_type_navn + this.tittel + this.opprettet_dato.format();
        }
        private set {
        }
    }

    @AuraEnabled
    public String status_enum {
        get {
            return this.status.name();
        }
        private set {
        }
    }

    @AuraEnabled
    public String aktivitet_type_enum {
        get {
            return this.aktivitet_type.name();
        }
        private set {
        }
    }
}
