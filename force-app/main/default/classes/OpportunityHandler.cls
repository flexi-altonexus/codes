public class OpportunityHandler {

	public static Map<Id, Opportunity> mapMembersOpportunities;

    /*
     * @Method          :   beforeInsert
     * @Author          :   Francisco javier Sanz <javier.sanz@empaua.com>
     * @Created         :   30 Jul 2020
     * @Description     :   Call the actions that handle the before insert trigger
     */

    public void beforeInsert(List<Opportunity> listNew) {
        OpportunityHelper.checkIfGoogleAnalyticsCode(listNew);

		//Round robin owner assignment
        List<User> userList = [SELECT Id FROM User WHERE Name = 'Flexioffices Search' LIMIT 1];
        Id currentUserId = UserInfo.getUserId();
        if(currentUserId == userList[0].Id) {
            mapMembersOpportunities = new Map<Id, Opportunity> ();
            OpportunityHelper.roundRobinOpportunitiesAssignment(listNew, mapMembersOpportunities);
        }
    }

    /*
     * @Method          :   beforeUpdate
     * @Author          :   Francisco javier Sanz <javier.sanz@empaua.com>
     * @Created         :   30 Jul 2020
     * @Description     :   Call the actions that handle the before update trigger
     */
    /*public  void beforeUpdate(List<Opportunity> listNew, Map<Id, Opportunity> mapNew, List<Opportunity> listOld, Map<Id, Opportunity> mapOld){
	}

	/*
	 * @Method          :   beforeDelete
	 * @Author          :   
	 * @Created         :   
	 * @Description     :   Call the actions that handle the before delete trigger
	 */
    //public  void beforeDelete(List<Opportunity> listOld, Map<Id, Opportunity> mapOld){
    //}

    /*
     * @Method          :   afterInsert
     * @Author          :   Francisco javier Sanz <javier.sanz@empaua.com>
     * @Created         :   30 Jul 2020
     * @Description     :   Call the actions that handle the after insert trigger
     */

    public void afterInsert(List<Opportunity> listNew, Map<Id, Opportunity> mapNew) {

		//Round robin update members
        List<User> userList = [SELECT Id FROM User WHERE Name = 'Flexioffices Search' LIMIT 1];
        Id currentUserId = UserInfo.getUserId();
        if(currentUserId == userList[0].Id) {
            OpportunityHelper.updateMembers(mapMembersOpportunities);
        }

        OpportunityHelper.OpportunityStageUpdated_SendToGA(mapNew, null);
        OpportunityHelper.OpportunityStageUpdated_SendToDC(mapNew, null);
    }

    /*
     * @Method          :   afterUpdate
     * @Author          :   Francisco javier Sanz <javier.sanz@empaua.com>
     * @Created         :   30 Jul 2020
     * @Description     :   Call the actions that handle the after update trigger
     */
    public void afterUpdate(
        List<Opportunity> listNew,
        Map<Id, Opportunity> mapNew,
        List<Opportunity> lstOld,
        Map<Id, Opportunity> mapOld
    ) {
        OpportunityHelper.OpportunityStageUpdated_SendToGA(mapNew, mapOld);
        OpportunityHelper.OpportunityStageUpdated_SendToDC(mapNew, mapOld);
        AgentTargetUtils.calculateMonthFinalFeeFromOpp(lstOld);
        AgentTargetUtils.calculateMonthFinalFeeFromOpp(listNew);
    }

    /*
     * @Method          :   afterDelete
     * @Author          :
     * @Created         :
     * @Description     :   Call the actions that handle the after delete trigger
     */
    /*public  void afterDelete(List<Opportunity> listOld, Map<Id, Opportunity> mapOld){


	}

	/*
	 * @Method          :   unDelete
	 * @Author          :   
	 * @Created         :   
	 * @Description     :   Call the actions that handle the undelete trigger
	 */
    //public void OnUndelete(List<Opportunity> lstOld){
    //}
}