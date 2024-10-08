import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createEnhancedListings from '@salesforce/apex/SearchParameterYearUpFrontController.createEnhancedListings';

export default class SearchParameterYearUpFront extends LightningElement {
    @api recordId;
    controllerResult = '';
    error;

    handleCreation(event) {
        createEnhancedListings({ recordId: this.recordId })
            .then((result) => {
                this.controllerResult = result;
                this.error = undefined;
                this.handleSuccess(event);
            })
            .catch((error) => {
                this.error = error;
                this.controllerResult = undefined;
                this.handleError(event);
                console.log('error: ' + JSON.stringify(error));
            });
    }

    handleSuccess(event) {
        // Close the modal window and display a success toast
        this.dispatchEvent(new CloseActionScreenEvent());
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Records created!',
                variant: 'success'
            })
        );
    }

    handleError(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'There was an error. Please contact your salesforce admin.',
                variant: 'error'
            })
        );
    }

    handleCancel(event) {
        // Add your cancel button implementation here
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}