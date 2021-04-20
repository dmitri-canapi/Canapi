import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getDocs from '@salesforce/apex/docManFilesReport.getDocs';
import getNext from '@salesforce/apex/docManFilesReport.getNext';
import getPrevious from '@salesforce/apex/docManFilesReport.getPrevious';


const DELAY = 300;

export default class DocManFilesReport extends NavigationMixin(LightningElement) {
    searchKey = '';

    @track gridColumns = [{
        type: 'button',
        typeAttributes: {
            label: { fieldName: "docName" },
            name: "gotoOpportunity", variant: "base"
        },
        initialWidth: 320
    },
    {
        fieldName: 'AccountId',
        type: 'url',
        typeAttributes: { label: { fieldName: 'AccountName' }, target: '_blank' },
        label: 'Account'
    },
    {
        type: 'date',
        fieldName: 'CreatedDate',
        label: 'Created Date',
        initialWidth: 130
    },
    {
        type: 'text',
        fieldName: 'Notes',
        label: 'Notes'
    },
    {
        type: 'text',
        fieldName: 'BoardMeetingName',
        label: 'Board Meeting Name'
    },
    {
        type: 'text',
        fieldName: 'DocumentFolder',
        label: 'Document Folder'
    },
    {
        type: 'text',
        fieldName: 'DealName',
        label: 'DealName'
    },
    {
        type: 'url',
        fieldName: 'CreatedById',
        typeAttributes: { label: { fieldName: 'CreatedByName' }, target: '_blank' },
        label: 'Created By'
    },
    {
        type: 'text',
        fieldName: 'viewCount',
        label: 'Views',
        initialWidth: 150
    },
    {
        type: 'text',
        fieldName: 'downloadCount',
        label: 'Downloads',
        initialWidth: 150
    }
    ];
    @track gridData;
    @track allRows;

    @track v_Offset = 0;
    @track v_TotalRecords = 0;
    @track page_size = 25;


    @wire(getDocs, { filter: '$searchKey', v_Offset: '$v_Offset', v_pagesize: '$page_size' })
    accountTreeData({ error, data }) {

        if (data) {

            var tempData = JSON.parse(JSON.stringify(data.documents));
            console.log(JSON.parse(JSON.stringify(data)));
            /*var tempjson = JSON.parse( JSON.stringify( data ).split( 'Contacts' ).join( '_children' ) );
            console.log( 'Temp JSON is ' + tempjson );*/
            for (var i = 0; i < tempData.length; i++) {

                var downloads = tempData[i]['downloads'];

                if (downloads) {

                    tempData[i]._children = downloads;
                    delete tempData[i].downloads;
                    //tempData[i]._children[0].LastName = 'test/n\nddf';

                }

                if (tempData[i]['views']) {
                    if (tempData[i]._children) {
                        tempData[i]._children = tempData[i]._children.concat(tempData[i]['views']);
                    } else {
                        tempData[i]._children = tempData[i]['views']
                    }
                }

            }
            this.gridData = tempData;
            this.allRows = tempData;
            this.v_TotalRecords = JSON.parse(JSON.stringify(data.totalCount))

            /* if (this.v_TotalRecords <= this.page_size) {
                 this.template.querySelector('c-paginator').changeView('falseprevious');
                 this.template.querySelector('c-paginator').changeView('truenext');
             }*/

        } else if (error) {

            if (Array.isArray(error.body))
                console.log('Error is ' + error.body.map(e => e.message).join(', '));
            else if (typeof error.body.message === 'string')
                console.log('Error is ' + error.body.message);

        }

    }

    previousHandler2() {
        getPrevious({ v_Offset: this.v_Offset, v_pagesize: this.page_size }).then(result => {
            this.v_Offset = result;
            if (this.v_Offset === 0) {
                this.template.querySelector('c-paginator').changeView('trueprevious');
            } else {
                this.template.querySelector('c-paginator').changeView('falsenext');
            }
        });
    }
    nextHandler2() {
        getNext({ v_Offset: this.v_Offset, v_pagesize: this.page_size }).then(result => {
            this.v_Offset = result;
            if (this.v_Offset + this.page_size > this.v_TotalRecords) {
                this.template.querySelector('c-paginator').changeView('truenext');
            } else {
                this.template.querySelector('c-paginator').changeView('falseprevious');
            }
        });
    }

    changeHandler2(event) {
        const det = event.detail;
        this.page_size = det;
        this.firstpagehandler();
    }
    firstpagehandler() {
        this.v_Offset = 0;
        this.template.querySelector('c-paginator').changeView('trueprevious');
        this.template.querySelector('c-paginator').changeView('falsenext');
    }
    lastpagehandler() {
        this.v_Offset = this.v_TotalRecords - (this.v_TotalRecords) % (this.page_size);
        this.template.querySelector('c-paginator').changeView('falseprevious');
        this.template.querySelector('c-paginator').changeView('truenext');
    }


    handleKeyChange(event) {
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.firstpagehandler();
            this.searchKey = searchKey;
        }, DELAY);
    }

    handleRowAction(event) {
        console.log('row: ' + JSON.stringify(event.detail.row));
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                // assigning ContentDocumentId to show the preview of file
                selectedRecordId: event.detail.row.filePreviewId
            }
        })

    }

}