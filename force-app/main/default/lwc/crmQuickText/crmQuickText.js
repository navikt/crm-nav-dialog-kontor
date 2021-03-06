import { LightningElement, track, api, wire } from 'lwc';
import searchRecords from '@salesforce/apex/CRM_QuickTextSearchController.searchRecords';
import getQuicktexts from '@salesforce/apex/CRM_QuickTextSearchController.getQuicktexts';

const ESC_KEY_CODE = 27;
const ESC_KEY_STRING = 'Escape';
const TAB_KEY_CODE = 9;
const TAB_KEY_STRING = 'Tab';
const LIGHTNING_INPUT_FIELD = 'LIGHTNING-INPUT-FIELD';

const QUICK_TEXT_TRIGGER_KEYS = ['Enter', ' ', ','];
export default class crmQuickText extends LightningElement {
    _inputText;
    qmap;
    initialRender = true;
    loadingData = false;
    showAutocomplete = false;

    @track data = [];

    @api labelText = 'Meldingstekst';
    @api defaultRows = 15;
    @api required = false;
    @api NO_INPUT_VALIDATION_ERROR;

    get textArea() {
        return this.template.querySelector('.inputTextTextArea');
    }

    renderedCallback() {
        if (this.initialRender === true) {
            let inputField = this.textArea;
            inputField.focus();
            inputField.blur();
            this.initialRender = false;
        }
    }

    /**
     * Functions for handling modal focus
     */
    disconnectedCallback() {
        document.removeEventListener('click', this.outsideClickListener);
    }

    @api
    isOpen() {
        return this.template.querySelector('[data-id="modal"]').className === 'modalShow';
    }

    toggleModal() {
        this.isOpen = !this.isOpen;
        if (this.isOpen) {
            this.focusFirstChild();
        }
    }

    get cssClass() {
        const baseClasses = ['slds-modal'];
        baseClasses.push([this.isOpen ? 'slds-visible slds-fade-in-open' : 'slds-hidden']);
        return baseClasses.join(' ');
    }

    get modalAriaHidden() {
        return !this.isOpen;
    }

    get showAutocompleteLabel() {
        return this.showAutocomplete === true ? 'Skjul autofullfør' : 'Vis autofullfør';
    }

    showModal() {
        this.template.querySelector('[data-id="modal"]').className = 'modalShow';
        this.template.querySelector('lightning-input').focus();
    }

    hideModal() {
        this.template.querySelector('[data-id="modal"]').className = 'modalHide';
    }

    outsideClickListener = (e) => {
        e.stopPropagation();
        if (!this.isOpen) {
            return;
        }
        this.toggleModal();
    };

    innerKeyUpHandler(event) {
        if (event.keyCode === ESC_KEY_CODE || event.code === ESC_KEY_STRING) {
            this.hideModal();
        } else if (event.keyCode === TAB_KEY_CODE || event.code === TAB_KEY_STRING) {
            const el = this.template.activeElement;
            if (el.classList.contains('lastLink') || el.classList.contains('firstlink')) {
                this._getCloseButton().focus();
            }
        }
    }

    _getCloseButton() {
        let closeButton = this.template.querySelector('lightning-button-icon[title="Lukk"]');
        if (!closeButton) {
            closeButton = this.template.querySelector('lightning-button-icon');
        }
        return closeButton;
    }

    _getSlotName(element) {
        let slotName = element.slot;
        while (!slotName && element.parentElement) {
            slotName = this._getSlotName(element.parentElement);
        }
        return slotName;
    }

    async focusFirstChild() {
        const children = [...this.querySelectorAll('*')];
        for (let child of children) {
            let hasBeenFocused = false;
            if (this._getSlotName(child) === 'body') {
                continue;
            }
            await this.setFocus(child).then((res) => {
                hasBeenFocused = res;
            });
            if (hasBeenFocused) {
                return;
            }
        }
        const closeButton = this._getCloseButton();
        if (closeButton) {
            closeButton.focus();
        }
    }

    setFocus(el) {
        return new Promise((resolve) => {
            if (el.disabled || (el.tagName === LIGHTNING_INPUT_FIELD && el.required)) {
                return resolve(false);
            }
            const promiseListener = () => resolve(true);
            try {
                el.addEventListener('focus', promiseListener);
                el.focus && el.focus();
                el.removeEventListener('focus', promiseListener);

                setTimeout(() => resolve(false), 0);
            } catch (ex) {
                return resolve(false);
            }
        });
    }

    innerClickHandler(event) {
        event.stopPropagation();
    }

    setFocusOnTextArea() {
        let inputField = this.textArea;
        inputField.focus();
    }

    /**
     * Functions for conversation note/quick text
     */
    @wire(getQuicktexts, {})
    wiredQuicktexts({ error, data }) {
        if (error) {
            console.log(error);
        } else if (data) {
            this.qmap = data.map((key) => {
                return {
                    abbreviation: key.nksAbbreviationKey__c,
                    content: { message: key.Message, isCaseSensitive: key.Case_sensitive__c }
                };
            });
        }
    }

    @api get inputText() {
        return this._inputText;
    }

    set inputText(value) {
        this._inputText = value;
    }

    @api get inputTextRich() {
        return this._inputText;
    }

    set inputTextRich(value) {
        this._inputText = value;
    }

    handlePaste(evt) {
        const editor = this.textArea;
        editor.setRangeText(
            this.toPlainText((evt.clipboardData || window.clipboardData).getData('text')),
            editor.selectionStart,
            editor.selectionEnd,
            'end'
        );
        evt.preventDefault();
        evt.stopImmediatePropagation();

        this._inputText = editor.value;
        const attributeChangeEvent = new CustomEvent('commentschange', {
            detail: this.inputText
        });
        this.dispatchEvent(attributeChangeEvent);
    }

    handleKeyUp(evt) {
        const queryTerm = evt.target.value;

        if (evt.key.length > 1 && evt.key !== 'Enter') {
            return;
        }

        if (evt.key === 'Enter' || (queryTerm.length > 2 && this.loadingData === false)) {
            this.loadingData = true;
            searchRecords({
                search: queryTerm
            })
                .then((result) => {
                    this.numberOfRows = result.length;
                    this.data = result;
                })
                .catch((error) => {
                    console.log(error);
                })
                .finally(() => {
                    this.loadingData = false;
                });
        }
    }

    insertText(event) {
        const editor = this.textArea;
        editor.focus();
        editor.setRangeText(
            this.toPlainText(event.currentTarget.dataset.message),
            editor.selectionStart,
            editor.selectionEnd,
            'select'
        );

        this.hideModal(undefined);
        this._inputText = editor.value;
        const attributeChangeEvent = new CustomEvent('commentschange', {
            detail: this.inputText
        });
        this.dispatchEvent(attributeChangeEvent);
    }

    handleChange(event) {
        this[event.target.name] = event.target.value;
        this._inputText = event.target.value;
        const attributeChangeEvent = new CustomEvent('commentschange', {
            detail: this.inputText
        });
        this.dispatchEvent(attributeChangeEvent);
    }

    insertquicktext(event) {
        if (QUICK_TEXT_TRIGGER_KEYS.includes(event.key)) {
            const editor = this.textArea;
            const carretPositionEnd = editor.selectionEnd;
            const lastItem = editor.value
                .substring(0, carretPositionEnd)
                .replace(/(\r\n|\n|\r)/g, ' ')
                .trim()
                .split(' ')
                .pop();

            const abbreviation = lastItem.replace(event.key, '');

            let obj;
            for (const item of this.qmap) {
                if (item.abbreviation.toUpperCase() !== item.content.message) {
                    item.abbreviation = item.abbreviation.toUpperCase();
                    if (item.abbreviation === abbreviation.toUpperCase()) {
                        obj = item;
                    }
                }
                if (item.abbreviation === abbreviation) {
                    obj = item;
                }
            }

            const quickText = obj.content.message;
            const isCaseSensitive = obj.content.isCaseSensitive;
            const startindex = carretPositionEnd - abbreviation.length - 1;
            const lastChar = event.key === 'Enter' ? '\n' : event.key;

            if (isCaseSensitive) {
                const words = quickText.split(' ');

                if (lastItem.charAt(0) === lastItem.charAt(0).toLowerCase()) {
                    words[0] = words[0].toLowerCase();
                    const lowerCaseQuickText = words.join(' ');
                    editor.setRangeText(lowerCaseQuickText + lastChar, startindex, carretPositionEnd, 'end');
                } else if (lastItem.charAt(0) === lastItem.charAt(0).toUpperCase()) {
                    const upperCaseQuickText = quickText.charAt(0).toUpperCase() + quickText.slice(1);
                    editor.setRangeText(upperCaseQuickText + lastChar, startindex, carretPositionEnd, 'end');
                }
            } else {
                editor.setRangeText(quickText + lastChar, startindex, carretPositionEnd, 'end');
            }
        }
    }

    toggleAutocomplete() {
        this.showAutocomplete = !this.showAutocomplete;
    }

    toPlainText(value) {
        let plainText = value ? value : '';
        plainText = plainText.replace(/<\/[^\s>]+>/g, '\n'); //Replaces all ending tags with newlines.
        plainText = plainText.replace(/<[^>]+>/g, ''); //Remove remaining html tags
        plainText = plainText.replace(/&nbsp;/g, ' '); //Removes &nbsp; from the html that can arise from copy-paste
        return plainText;
    }

    @api
    validate() {
        if (this.required === true) {
            return this.inputText && this.inputText.length > 0
                ? { isValid: true }
                : { isValid: false, errorMessage: this.NO_INPUT_VALIDATION_ERROR };
        } else {
            return { isValid: true };
        }
    }
}
