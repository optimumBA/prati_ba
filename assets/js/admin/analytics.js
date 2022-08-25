import Chart from 'chart.js'

const THOUSAND = 1000
const HUNDRED_THOUSAND = 100000
const MILLION = 1000000
const HUNDRED_MILLION = 100000000

const MONTHS = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
]

function numberFormatter(num) {
  if (num >= THOUSAND && num < MILLION) {
    const thousands = num / THOUSAND
    if (thousands === Math.floor(thousands) || num >= HUNDRED_THOUSAND) {
      return Math.floor(thousands) + 'k'
    } else {
      return Math.floor(thousands * 10) / 10 + 'k'
    }
  } else if (num >= MILLION && num < HUNDRED_MILLION) {
    const millions = num / MILLION
    if (millions === Math.floor(millions)) {
      return Math.floor(millions) + 'm'
    } else {
      return Math.floor(millions * 10) / 10 + 'm'
    }
  } else {
    return num
  }
}

function dateFormatter(isoDate) {
  let date = new Date(isoDate)
  return date.getUTCDate() + ' ' + MONTHS[date.getUTCMonth()]
}

export default class Analytics {
  drawMainGraph() {
    let graphContainer = document.getElementById('analytics-main-graph')
    let data = JSON.parse(graphContainer.dataset.results).map((item) => ({
      date: new Date(item[0]),
      value: item[1],
    }))
    let ctx = graphContainer.getContext('2d')

    let gradient = ctx.createLinearGradient(0, 0, 0, 300)
    gradient.addColorStop(0, 'rgba(0, 148, 255, 0.2)')
    gradient.addColorStop(1, 'rgba(0, 148, 255, 0)')

    let dashedPart = data.slice(-2).map((item) => item.value)
    let dashedPlot = new Array(5).concat(dashedPart)
    let plot = data.slice(0, -1).map((item) => item.value)

    let color = Chart.helpers.color
    let chart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: data.map((item) => item.date),
        datasets: [
          {
            label: 'Visitors',
            data: plot,
            borderWidth: 3,
            borderColor: 'rgb(0, 148, 255)',
            pointBackgroundColor: 'rgb(0, 148, 255)',
            backgroundColor: gradient,
          },
          {
            label: 'Visitors',
            data: dashedPlot,
            borderWidth: 3,
            borderDash: [5, 10],
            borderColor: 'rgb(0, 148, 255)',
            pointBackgroundColor: 'rgb(0, 148, 255)',
            backgroundColor: gradient,
          },
        ],
      },
      options: {
        aspectRatio: 3,
        animation: false,
        legend: {
          display: false,
        },
        responsive: true,
        elements: {
          line: {
            tension: 0,
          },
          point: {
            radius: 0,
          },
        },
        tooltips: {
          mode: 'index',
          intersect: false,
          titleFontSize: 18,
          footerFontSize: 14,
          bodyFontSize: 14,
          backgroundColor: 'rgba(25, 30, 56)',
          titleMarginBottom: 8,
          bodySpacing: 6,
          footerMarginTop: 8,
          xPadding: 16,
          yPadding: 12,
          multiKeyBackground: 'none',
          callbacks: {
            title: function (dataPoints) {
              const data = dataPoints[0]
              return dateFormatter(data.xLabel)
            },
            beforeBody: function () {
              this.drawnLabels = {}
            },
            label: function (item) {
              const dataset = this._data.datasets[item.datasetIndex]
              if (!this.drawnLabels[dataset.label]) {
                this.drawnLabels[dataset.label] = true
                const pluralizedLabel =
                  item.yLabel === 1 ? dataset.label.slice(0, -1) : dataset.label
                return ` ${item.yLabel} ${pluralizedLabel}`
              }
            },
          },
        },
        scales: {
          yAxes: [
            {
              ticks: {
                callback: numberFormatter,
                beginAtZero: true,
                autoSkip: true,
                maxTicksLimit: 8,
              },
              gridLines: {
                zeroLineColor: 'transparent',
                drawBorder: false,
              },
            },
          ],
          xAxes: [
            {
              gridLines: {
                display: false,
              },
              ticks: {
                autoSkip: true,
                maxTicksLimit: 8,
                callback: dateFormatter,
              },
            },
          ],
        },
      },
    })
  }
}
