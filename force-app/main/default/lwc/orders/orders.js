import { LightningElement, api } from 'lwc';
import getSumOrdersByAccount from '@salesforce/apex/OrderController.getSumOrdersByAccount';

export default class Orders extends LightningElement {
@api recordId;
sumOrdersOfCurrentAccount;

connectedCallback() {
    this.fetchSumOrders();
}

fetchSumOrders() {
    getSumOrdersByAccount({ accountId: this.recordId })
        .then(result => {
            this.sumOrdersOfCurrentAccount = result;
        })
        .catch(error => {
            console.error('Error fetching total orders: ', error);
            this.sumOrdersOfCurrentAccount = 0;
        });
}
}