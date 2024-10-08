import { LightningElement, api } from 'lwc';

export default class PredictedTotalOutputCell extends LightningElement {
    @api value;
    @api expectedValue;

    get displayClass() {
        return this.value >= this.expectedValue ? 'above-target' : 'below-target';
    }
}