import { LightningElement, api, wire } from 'lwc';
import getSumOrdersByAccount from '@salesforce/apex/OrderController.getSumOrdersByAccount';

export default class Orders extends LightningElement {
@api recordId;
sumOrdersOfCurrentAccount;
errorMessage;

@wire(getSumOrdersByAccount, { accountId: '$recordId' })
wiredOrders({ error, data }) {
    if (data) {
        this.sumOrdersOfCurrentAccount = data;
        this.errorMessage = undefined;
    } else if (error) {
        this.errorMessage = 'Erreur lors de la récupération des données, veuillez réessayer.';
        console.error('Erreur lors de l\'appel @wire', error);
    }
}

// Propriété calculée pour distinguer quand les données sont valides (>0) ou non
get hasData() {
    return this.sumOrdersOfCurrentAccount !== null && this.sumOrdersOfCurrentAccount > 0;
}
}