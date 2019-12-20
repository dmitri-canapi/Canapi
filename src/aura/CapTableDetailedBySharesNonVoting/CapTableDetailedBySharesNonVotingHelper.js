({
    getSeriesModalId : function(component) {
        return component.getGlobalId() + 'seriesModal';
    },

    initDatatable : function(component, rawCapTableData) {

        // get the id for our seriesModal (prefixed by component global id)
        var seriesModalId = this.getSeriesModalId(component);

        // use the datatables number formatter
        var numberFormatter = $.fn.dataTable.render.number(',');
        var formatNumber = function(value) {
            if (value)
                return numberFormatter.display(value);
            else
                return numberFormatter.display(0);;
        }

        // ***********************
        // initialize the columns
        // ***********************
        var columns = [];
        columns.push({
            title: "Shareholder",
            data: "shareholderName",
            render: function(data, type, row, meta) {
                return '<a id="shareholderLink">'+data+'</a>';
            }
        });
        for (var round of rawCapTableData.rounds) {
            columns.push({
                seriesId:                               round.id,
                seriesName:                             round.fullName,
                totalInvestedDollars:   formatNumber(   round.totalInvestedDollars),
                sharePrice:             formatNumber(   round.sharePrice),
                preMoneyValuation:      formatNumber(   round.preMoneyValuation),
                targetAmount:           formatNumber(   round.targetAmount),
                // datatables stuff below
                title:      '<a id="seriesLink" data-seriesId="' + round.id + '">'+round.fullName+'</a>',
                data:       round.id + "numberOfSharesNonVoting",
                render:     numberFormatter,
                className:  'dt-body-right dt-head-center'
            });
        }
        columns.push({
            title: "Total:",
            data: "totalSharesNonVotingForInvestor",
            render: numberFormatter,
            className: 'dt-body-right dt-head-center'
        });

        // ***********************
        // initialize our dataSet
        // ***********************
        var rowsByInvestorId = {};
        var totalSharesInvestedOverall = rawCapTableData.totalSharesInvested;
        for (var investment of rawCapTableData.investments) {

            var investorAccountId =         investment.investorId;
            var investorAccountName =       investment.investorName;
            var percentageOfSeries =        investment.percentageOfSeries * 100;
            var numberOfShares =            investment.numberOfShares;
            var numberOfSharesVoting =      (investment.numberOfSharesVoting ? investment.numberOfSharesVoting : 0);
            var numberOfSharesNonVoting =   (investment.numberOfSharesNonVoting ? investment.numberOfSharesNonVoting : 0);
            var investmentAmount =          investment.totalDollarAmount;
            var investmentSeriesId =        investment.seriesId;

            if (!(rowsByInvestorId[investorAccountId])) {

                // initialize a new row, start with 0 investment for each round and
                // we'll overwrite later
                var newInvestor = {
                    shareholderName :   investorAccountName,
                    shareholderId :     investorAccountId
                };
                for (var round of rawCapTableData["rounds"]) {
                    newInvestor[round.id + 'investmentAmount'] = 0;
                    newInvestor[round.id + 'percentage'] = 0;
                    newInvestor[round.id + 'numberOfShares'] = 0;
                    newInvestor[round.id + 'numberOfSharesVoting'] = 0;
                    newInvestor[round.id + 'numberOfSharesNonVoting'] = 0;
                }
                newInvestor.totalDollarsForInvestor = 0;
                newInvestor.totalSharesForInvestor = 0;
                newInvestor.totalSharesVotingForInvestor = 0;
                newInvestor.totalSharesNonVotingForInvestor = 0;
                rowsByInvestorId[investorAccountId] = newInvestor;
            }

            var currentInvestor = rowsByInvestorId[investorAccountId];

            currentInvestor[investmentSeriesId + 'investmentAmount'] = investmentAmount;
            currentInvestor[investmentSeriesId + 'percentage'] = percentageOfSeries / 100;
            currentInvestor[investmentSeriesId + 'numberOfShares'] = numberOfShares;
            currentInvestor[investmentSeriesId + 'numberOfSharesVoting'] = numberOfSharesVoting;
            currentInvestor[investmentSeriesId + 'numberOfSharesNonVoting'] = numberOfSharesNonVoting;
            
            // adjust totals for this investor
            currentInvestor.totalDollarsForInvestor += investmentAmount;
            currentInvestor.totalSharesForInvestor += numberOfShares;
            currentInvestor.totalSharesVotingForInvestor += numberOfSharesVoting;
            currentInvestor.totalSharesNonVotingForInvestor += numberOfSharesNonVoting;
            currentInvestor.totalPercentageForInvestor = currentInvestor.totalSharesForInvestor / totalSharesInvestedOverall * 100;
        }
        var dataSet = Object.values(rowsByInvestorId);

        // DOM manipulation starts in here
        $(document).ready(function() {

            // This is goofy, and should be revisited.  This code went through
            // a lot of iterations, and I can't remember why I ended up doing this,
            // but it seemed to fix an issue with the datatable not showing up
            // because lightning creates multiple copies of things in the DOM, and
            // I think a background copy was or something.  I think lightning must
            // create the "background" copy after the component gets fully loaded,
            // because at this point there seems to be only 1 copy of
            // #dtableByShares.
            var timestamp = + new Date();
            var datatableId = 'dtableBySharesNonVoting' + timestamp;
            $('#dtableBySharesNonVoting').prop('id', datatableId);
            var datatableSelector = '#' + datatableId;

            // Add an empty footer so it's there when we summarize the totals.
            // Datatables needs the footer to exist with the correct number
            // of columns in order to work.
            var footer = '<tfoot><tr><td><b>Total:</b></td>';
            for (var round of rawCapTableData["rounds"]) {
                footer += '<td>--------------------</td>';
            }
            footer += '<td>--------------------</td></tr></tfoot>';
            $(footer).appendTo(datatableSelector);

            // initialize the datatable itself - this will add everything to
            // the DOM
            var dTable = $(datatableSelector).DataTable( {
                data:           dataSet,
                columns:        columns,
                searching:      false,
                paging:         false,
                info:           false,
                scrollX:        true,
                colReorder:     {fixedColumnsLeft: 1},
                fixedColumns:   true,

                // more options not used currently
                //scrollY:        400,
                //scrollCollapse: true,
                //fixedHeader:    {header:true,footer:true},

                // callback to summarize data for the "Total" footer row
                "footerCallback": function( tfoot, data, start, end, display ) {
                    var api = this.api();

                    // summarize all the round rows (they start at index 1, after the shareholder
                    // row), and add 1 to the length so we get the total row as well
                    for (var i=0; i<rawCapTableData["rounds"].length+1; i++) {
                        var footerCell = $(api.column( i+1 ).footer());
                        footerCell.html(
                            formatNumber(
                                api.column( i+1 ).data().reduce( function ( a, b ) {
                                    return a + b;
                                }, 0 )
                            )
                        );
                    }
                }
            } );

            // **************************************
            // set up the popups showing series info
            // **************************************
            $('table').on('mouseenter', '#seriesLink', function (event) {

                // get the seriesId from the link that was clicked
                var seriesId = event.target.getAttribute('data-seriesId');

                // grad the appropriate column data matching on seriesId
                var columnData;
                for (columnData of columns) {
                    if (columnData.seriesId == seriesId) break;
                }

                // grab the modal, update the contents, and then show it
                var seriesModal = document.getElementById(seriesModalId);
                seriesModal.innerHTML = 
                    '<div class="slds-popover__body">' +
                    '   <p align="left">' + columnData.seriesName + '</p>' +
                    '   <table>' +
                    '       <tr><td class="slds-text-align_left">Target Amount:</td><td class="slds-text-align_right">' + columnData.targetAmount + '</td></tr>' +
                    '       <tr><td class="slds-text-align_left">Total Committed:</td><td class="slds-text-align_right">' + columnData.totalInvestedDollars + '</td></tr>' +
                    '       <tr><td class="slds-text-align_left">Share Value:</td><td class="slds-text-align_right">' + columnData.sharePrice + '</td></tr>' +
                    '       <tr><td class="slds-text-align_left">Pre-Money Valuation:</td><td class="slds-text-align_right">' + columnData.preMoneyValuation + '</td></tr>' +
                    '   </table>' +
                    '</div>';
                seriesModal.classList.add("slds-show");
                seriesModal.classList.remove("slds-hide");
            } );

            $('table').on('mouseleave', '#seriesLink', function () {
                // grab the modal, remove the contents, and then hide it
                var seriesModal = document.getElementById(seriesModalId);
                seriesModal.innerHTML = '';
                seriesModal.classList.add("slds-hide");
                seriesModal.classList.remove("slds-show");
            } );

            // *****************************************************
            // set up the links on the series and shareholder names
            // *****************************************************
            $('table').on('click', '#shareholderLink', function () {
                var index = dTable.row( this ).index();

                var data = dataSet[index];
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": data.shareholderId
                });
                navEvt.fire();
            } );

            $('table').on('click', '#seriesLink', function (event) {

                var seriesId = event.target.getAttribute('data-seriesId');
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": seriesId
                });
                navEvt.fire();
            } );
        } );
    }
})