User usr = new User(Id = UserInfo.getUserId());
//Set default axsys unit for scratch user
usr.INT_Units__c = '[{"name":"NAV Stord","id":"1221"},{"name":"NAV Fitjar","id":"1222"}]';

update usr;

