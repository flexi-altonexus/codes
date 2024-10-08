global with sharing class EmailServerMessageController {
	global Id introId {get; set;}
	global static String strFileName {get; set;}

	public EmailServerMessageController() {}

	public String getstrBody(){
		return EmailToProviderUtils.getEmailBody(introId);
	}

	public String getstrXMLAttachment(){
		//TO DO IFF this.strFileName = 'ultrasoft.xml';
		return EmailToProviderUtils.getXMLFile();
	}


}