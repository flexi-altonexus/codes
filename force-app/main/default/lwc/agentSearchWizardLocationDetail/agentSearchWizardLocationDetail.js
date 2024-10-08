import { LightningElement, api } from 'lwc';

export default class AgentSearchWizardLocationDetail extends LightningElement {
    @api contents;

    closePopover() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    //Hook into addListener

    addClicked() {
        const event = new CustomEvent('add', {
            detail: { id: this.contents.bcId }
        });
        this.dispatchEvent(event);
    }

    removeClicked() {
        const event = new CustomEvent('remove', {
            detail: { id: this.contents.bcId }
        });
        this.dispatchEvent(event);
    }

    get crmLink() {
        return `/${this.contents.bcId}`;
    }
}