/*
*   @Class          :   ContentVersionHandler
*
*   @Author         :   Juan Carlos Porras Blanco
*   @Created        :   16 April 2019
*   @Description    :   Handler for ContentVersion Trigger 
*
*/
public class ContentVersionHandler {
	
	public void afterInsert(List<ContentVersion> listNew) {
		ContentVersionHelper.createpublicLink(listNew);
	}	
}