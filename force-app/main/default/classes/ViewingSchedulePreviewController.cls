public with sharing class ViewingSchedulePreviewController {
	public static String viewingScheduleId {get;set;}
	public boolean sendEmailShow {get;set;}
	
	public ViewingSchedulePreviewController() {
		 viewingScheduleId = Apexpages.currentPage().getParameters().get('viewingScheduleId');
		 sendEmailShow = true;
	}

	public PageReference sendEmail(){

		viewingScheduleId = Apexpages.currentPage().getParameters().get('viewingScheduleId');
		system.debug('Before Email Send'+viewingScheduleId);
		String response = AgentCreateViewingsUtil.sendEmailViewingSchedule(viewingScheduleId);
		if(response == 'OK'){
			sendEmailShow = false;
			ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm, ' Email sent'));
		}else{
			ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, ' Error sending Email'));
		}

		return null;

	}
}