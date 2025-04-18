trigger CalculMontant on Order (before update) 
{ 
	for (Order o : Trigger.new) 
	{
		 Decimal total = (o.TotalAmount == null) ? 0 : o.TotalAmount; 
		 Decimal shipmentCost = (o.ShipmentCost__c == null) ? 0 : o.ShipmentCost__c;
		  o.NetAmount__c = total - shipmentCost;
	} 
}