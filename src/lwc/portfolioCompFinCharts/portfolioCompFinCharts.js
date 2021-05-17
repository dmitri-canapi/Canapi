import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/chartJS';
import getFins from '@salesforce/apex/PortfolioCompanyFinancials.getCapTableData';



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

function createConfig(chartd, chartl, col, median) {
    console.log(median);
    var chartType = '';
    if (col.Graph_Type__c == 'Bar') {
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
                    label: col.Portfolio_Column__c,
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
            horizontalLine: [{
                y: median,
            }],
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
                        if (col.Type__c == 'Currency') {
                            return formatToUsNumber(data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index]);
                        } else if (col.Type__c == 'Number') {
                            return data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index];
                        }
                        return data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index] + '%';
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

export default class PortfolioCompFinCharts extends LightningElement {
    @track
    qValue = 'Q' + Math.floor(((new Date()).getMonth() + 3) / 3) + ', ' + (new Date()).getFullYear();

    //@track
    //vfSrc = `/apex/PortfolioCompanyFinancials?skin=terrace&amp;componentHeight=400&amp;quarter=${this.qValue}`;
    get vfSrc() {
        return `/apex/PortfolioCompanyFinancials?skin=terrace&componentHeight=400&quarter=${this.qValue}`;
    }

    get qOptions() {
        let today = new Date();
        let currentQ = Math.floor((today.getMonth() + 3) / 3);
        let options = [];
        for (let i = currentQ; i >= 1; i--) {
            let q = { 'label': 'Q' + i + ', ' + today.getFullYear(), 'value': 'Q' + i + ', ' + today.getFullYear() };
            options.push(q);
        }
        for (let i = 4; (i >= 1 && options.length <= 6); i--) {
            let q = { 'label': 'Q' + i + ', ' + (today.getFullYear() - 1), 'value': 'Q' + i + ', ' + (today.getFullYear() - 1) };
            options.push(q);
        }
        if (options.length == 5) {
            let q = { 'label': 'Q4, ' + (today.getFullYear() - 2), 'value': 'Q4, ' + (today.getFullYear() - 2) };
            options.push(q);
        }

        return options;
    }

    handleChange(event) {
        this.qValue = event.detail.value;
    }


    @track chartConfiguration;

    connectedCallback() {

    }

    renderedCallback() {

    }



    @wire(getFins, { quarter: '$qValue' })
    getFinsgetFins({ error, data }) {
        if (error) {
            this.error = error;
            console.log('error => ' + JSON.stringify(error));
            this.chartConfiguration = undefined;
        } else if (data) {
            console.log(data.columns);
            console.log(JSON.parse(data.data));
            var rows = [];
            var columns = [];

            let d = JSON.parse(data.data);
            rows = d.rows;
            columns = data.columns;


            let configs = [];
            let chartData = [];
            let chartLabels = [];
            if (true) {
                for (var c = 0; c < columns.length; c++) {
                    if (columns[c].Graph_Type__c) {
                        chartData = [];
                        chartLabels = [];
                        let max = 0;
                        for (var r = 0; r < rows.length; r++) {
                            chartData.push(rows[r].data[c + 1]);
                            chartLabels.push((rows[r].data[0]).substring(0, (rows[r].data[0]).indexOf('^/')));
                            if (!Number.isNaN(rows[r].data[c + 1])) {
                                if (typeof rows[r].data[c + 1] === 'number') {
                                    if (rows[r].data[c + 1] > max) max = rows[r].data[c + 1];
                                } else {
                                    if (Number.parseInt(rows[r].data[c + 1]) > max) max = Number.parseInt(rows[r].data[c + 1]);
                                }

                                console.log(rows[r].data[c + 1]);
                            }
                        }
                        configs.push(createConfig(chartData, chartLabels, columns[c], max / 2));
                    }
                }
                /*
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
                */

                console.log(configs);

                Promise.all([loadScript(this, chartjs + '/Chart.min.js')])
                    .then(() => {
                        window.Chart.platform.disableCSSInjection = true;
                        this.template.querySelector('div.mainChartsDiv').innerHTML = '';

                        let horizonalLinePlugin = {
                            afterDraw: function (chartInstance) {
                                var yScale = chartInstance.scales["y-axis-0"];
                                var canvas = chartInstance.chart;
                                var ctx = canvas.ctx;
                                var index;
                                var line;
                                var style;

                                if (chartInstance.options.horizontalLine) {
                                    for (index = 0; index < chartInstance.options.horizontalLine.length; index++) {
                                        line = chartInstance.options.horizontalLine[index];
                                        let yValue;
                                        if (!line.style) {
                                            style = "rgba(169,169,169, .6)";
                                        } else {
                                            style = line.style;
                                        }

                                        if (line.y) {
                                            yValue = yScale.getPixelForValue(line.y);
                                        } else {
                                            yValue = 0;
                                        }

                                        ctx.lineWidth = 3;

                                        if (yValue) {
                                            ctx.beginPath();
                                            ctx.moveTo(0, yValue);
                                            ctx.lineTo(canvas.width, yValue);
                                            ctx.strokeStyle = style;
                                            ctx.stroke();
                                        }

                                        if (line.text) {
                                            ctx.fillStyle = style;
                                            ctx.fillText(line.text, 0, yValue + ctx.lineWidth);
                                        }
                                    }
                                    return;
                                };
                            }
                        };

                        window.Chart.pluginService.register(horizonalLinePlugin);


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
                            const ctx = canvas.getContext('2d');
                            this.chart = new window.Chart(ctx, config);

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


}