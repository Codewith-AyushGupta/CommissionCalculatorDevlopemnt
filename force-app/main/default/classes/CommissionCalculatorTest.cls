public with sharing class CommissionCalculatorTest {

    public static void segregateinvoiceDetails(List<invoice_Detail__c> invoiceDetails){

        Map<id,List<Invoice_Detail__c>> invoiceDetailsByOpportunities = new Map<id,List<Invoice_Detail__c>>();
        Map<id,List<Invoice_Detail__c>> invoiceDetailsByAccounts = new Map<id,List<Invoice_Detail__c>>();
        Map<id,List<Splits>> splitsByOpportunity = new Map<id,List<Splits>>();
        Set<Id> opportunityIds = new Set<Id>();
        Set<Id> opportunityIdsToBeRemoved = new Set<Id>();
        List<OpportunitySplit> opportunitySplits = new List<OpportunitySplit>();
        List<Opportunity> opportunitiesWithOwnerDetails = new List<Opportunity>();
        for(invoice_Detail__c invoiceDetail : invoiceDetails){
            if(invoiceDetail.Opportunity__c != null){
                if(invoiceDetailsByOpportunities.containsKey(invoiceDetail.Opportunity__c)){
                    invoiceDetailsByOpportunities.get(invoiceDetail.Opportunity__c).add(invoiceDetail);
                }
                else{
                    invoiceDetailsByOpportunities.put(invoiceDetail.Opportunity__c,new List<invoice_Detail__c>{invoiceDetail});
                }
            }
            else{
                if(invoiceDetailsByAccounts.containsKey(invoiceDetail.Account__c)){
                    invoiceDetailsByAccounts.get(invoiceDetail.Account__c).add(invoiceDetail);
                }
                else{
                    invoiceDetailsByAccounts.put(invoiceDetail.Account__c,new List<invoice_Detail__c>{invoiceDetail});
                }
            }
        }
        opportunityIds = invoiceDetailsByOpportunities.keySet();
        opportunitySplits = OpportunitySplitSelector.getOpportunitySplitByOpportunity(opportunityIds);
        for(OpportunitySplit split :opportunitySplits){
            opportunityIdsToBeRemoved.add(split.OpportunityId);
            if(splitsByOpportunity.containsKey(split.OpportunityId)){
                splitsByOpportunity.get(split.OpportunityId).add(new Splits(split.SplitOwnerId,split.SplitOwner.Profile.Name,split.SplitPercentage));
            }
            else{
                splitsByOpportunity.put(split.OpportunityId,new List<Splits>{new Splits(split.SplitOwnerId,split.SplitOwner.Profile.Name,split.SplitPercentage)});
            }
        }
        opportunityIds.removeAll(opportunityIdsToBeRemoved);
        opportunitiesWithOwnerDetails = OpportunitySelector.getOpportunitiesById(opportunityIds);

        for(Opportunity Opportunity :opportunitiesWithOwnerDetails){
            if(splitsByOpportunity.containsKey(Opportunity.Id)){
                splitsByOpportunity.get(Opportunity.Id).add(new Splits(Opportunity.OwnerId,Opportunity.owner.profile.name,100));
            }
            else{
                splitsByOpportunity.put(Opportunity.Id,new List<Splits>{new Splits(Opportunity.OwnerId,Opportunity.owner.profile.name,100)});
            }
        }
    }
    public class Splits{
        public Id ownerId;
        public String ownerProfile;
        public Decimal split;
        public splits(Id ownerId,String ownerProfile,Decimal split){
            This.ownerId = ownerId;
            This.ownerProfile = ownerProfile;
            This.split = split;
        }

    }
}