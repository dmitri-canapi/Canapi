import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/chartJS';
import getFins from '@salesforce/apex/FinancialsChart.getFins';



/*const generateRandomNumber = () => {
    return Math.round(Math.random() * 100);
};*/

function commarize(min) {
    if (min >= 1e3 || min <= -1e3) {
        let isMinus = false;
        if (min <= -1e3) {
            isMinus = true;
            min *= -1;
        }
        var units = ["k", "M", "B", "T"];

        var order = Math.floor(Math.log(min) / Math.log(1000));

        var unitname = units[(order - 1)];
        //var num = Math.floor(min / 1000 ** order);
        var num = Number((min / 1000 ** order).toFixed(2));

        num = isMinus ? num * -1 : num;

        return num + unitname;
    }

    return min;
}

function formatToUsNumber(val) {
    var nf = new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD',
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
    });
    return nf.format(val);

}

function createConfig(chartd, chartl, LIname, chartType) {
    if (chartType == 'Bar Graph') {
        chartType = 'bar';
    } else {
        chartType = 'line';
    }
    let backgrounds = new Array(chartl.length).fill('rgb(165, 165, 165)');
    backgrounds[chartl.length - 1] = 'RGB(165, 143, 102)';
    return {
        type: chartType,
        data: {
            labels: chartl,
            datasets: [
                {
                    label: LIname + ': ' + (chartType == 'bar' ? formatToUsNumber(chartd[chartd.length - 1]) : chartd[chartd.length - 1]),
                    fill: false,
                    backgroundColor: 'rgba(107, 95, 24)',
                    borderColor: 'rgba(107, 95, 24)',
                    /*barPercentage: 1,
                    barThickness: 10,
                    maxBarThickness: 14,
                    minBarLength: 2,*/
                    backgroundColor: backgrounds,
                    data: chartd,
                },
            ],
        },
        options: {
            scales: {
                yAxes: [{
                    ticks: {
                        beginAtZero: true,
                        callback: function (value, index, values) {
                            return commarize(value);
                        }
                    },
                    gridLines: {
                        display: false
                    }
                }],
                xAxes: [{
                    gridLines: {
                        display: false
                    }
                }]
            },
            tooltips: {
                callbacks: {
                    label: function (tooltipItem, data) {
                        /*var nf = new Intl.NumberFormat('en-US', {
                            style: 'currency',
                            currency: 'USD',
                            minimumFractionDigits: 2,
                            maximumFractionDigits: 2
                        });
                        return nf.format(data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index]);*/
                        return chartType == 'bar' ? formatToUsNumber(data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index]) : data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index];
                        //return '$' + (data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index]).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
                    }
                }
            },
            legend: {
                display: true,
                labels: {
                    boxWidth: 0,
                    fontColor: 'black'
                }
            },
            animation: {
                duration: 2000
            }


        },
    }

}

export default class FinancialsChart extends LightningElement {
    @api recordId;

    @track chartConfiguration;

    connectedCallback() {
        if (!this.recordId)
            this.recordId = '';
    }

    renderedCallback() {

    }

    @wire(getFins, { accountId: '$recordId' })
    getFinsgetFins({ error, data }) {
        if (error) {
            this.error = error;
            console.log('error => ' + JSON.stringify(error));
            this.chartConfiguration = undefined;
        } else if (data) {
            console.log(data);
            let configs = [];
            let chartData = [];
            let chartLabels = [];

            let currentLineItem = '';
            data.forEach((opp, key, arr) => {

                if (currentLineItem == '') {
                    currentLineItem = opp.Chart_of_Accounts__r.Name;
                } else if (key === arr.length - 1) {
                    chartData.push(opp.Value__c);
                    chartLabels.push(opp.Report_Period__r.Quarter__c);
                    configs.push(createConfig(chartData, chartLabels, currentLineItem, opp.Chart_of_Accounts__r.Graph_Type__c));
                    return;

                } else if (currentLineItem != opp.Chart_of_Accounts__r.Name) {
                    configs.push(createConfig(chartData, chartLabels, currentLineItem, data[key - 1].Chart_of_Accounts__r.Graph_Type__c));
                    currentLineItem = opp.Chart_of_Accounts__r.Name;
                    chartData = [];
                    chartLabels = [];

                }
                chartData.push(opp.Value__c);
                chartLabels.push(opp.Report_Period__r.Quarter__c);
            });

            console.log(configs);

            //this.chartConfiguration = ;
            Promise.all([loadScript(this, chartjs + '/Chart.min.js')])
                .then(() => {
                    //this.isChartJsInitialized = true;

                    window.Chart.platform.disableCSSInjection = true;

                    configs.forEach((config, key, arr) => {
                        const ch = document.createElement('div');
                        ch.className = 'chart';
                        ch.style.width = "340px";
                        ch.style.height = "240px";
                        this.template.querySelector('div.mainChartsDiv').appendChild(ch);

                        const canvas = document.createElement('canvas');
                        canvas.style.width = "340px";
                        canvas.style.height = "240px";
                        ch.appendChild(canvas);
                        //this.template.querySelector('div.chart').appendChild(canvas);
                        const ctx = canvas.getContext('2d');
                        this.chart = new window.Chart(ctx, config);
                        //this.chart.canvas.style.height = 'auto';
                        //this.chart.canvas.style.width = '100%';
                        /*this.chart.options.animation = {
                            duration: 1,
                            onComplete: function () {
                                var chartInstance = this.chart,
                                    ctx = chartInstance.ctx;
                                // ctx.font = Chart.helpers.fontString(Chart.defaults.global.defaultFontSize, Chart.defaults.global.defaultFontStyle, Chart.defaults.global.defaultFontFamily);
                                ctx.textAlign = 'center';
                                ctx.textBaseline = 'bottom';

                                config.data.datasets.forEach(function (dataset, i) {
                                    var meta = chartInstance.controller.getDatasetMeta(i);
                                    meta.data.forEach(function (bar, index) {
                                        var data = dataset.data[index];
                                        ctx.fillText(data, bar._model.x, bar._model.y - 5);
                                    });
                                });
                            }
                        }*/

                    });






                })
                .catch(error => {
                    console.log(error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error loading ChartJS',
                            message: error.message,
                            variant: 'error',
                        })
                    );
                });

            console.log('data => ', data);
            this.error = undefined;
        }
    }


}