/*
*   @Class          :   MitelAPIConnector
*
*   @Author         :   Juan Carlos Porras Blanco
*   @Created        :   16 Sep 2019
*   @Description    :   Queueable Class to do the Mitel callouts
*          
*
*/
public class MitelAPIConnector implements Queueable, Database.AllowsCallouts {
	
	private List<MitelAPIConnector.MitelCallBackClass> records;
	
	public MitelAPIConnector(List<MitelAPIConnector.MitelCallBackClass> records){
		this.records = records;
	}

	public void execute(QueueableContext context) {
		
		String jsonToSend;

		for(MitelAPIConnector.MitelCallBackClass callbackRec:records){
			
			//Prepare Body
			jsonToSend = JSON.serialize(callbackRec);
				
			//Send request	
			WebAPIUtils.sendPOSTCallBackToMitel(jsonToSend);
		
		}

	}


	public class MitelCallBackClass {
		
		public String Name {get;set;}
		public String CountryName {get;set;}
		public String CallerPhoneNumber {get;set;}
		public String DestinationNumber {get;set;}
		public String Message {get;set;}
		public String ClientAvailableFrom {get;set;}
		public String OutboundWorkflowId {get;set;}
		public String Type {get;set;}

		public MitelCallBackClass(){

			this.Name = null;
			this.CountryName = null;
			this.CallerPhoneNumber = null;
			this.Message = null;
			this.DestinationNumber = null;
			
		}

	}

}