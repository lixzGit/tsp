var page = require('webpage').create(),
    system = require('system'),
    args = system.args,
    fsys = require('fs'),
    // codeTblPath = '/Users/lixz/tsp/codeTbl.txt',
    tmpPath = '/Users/lixz/tsp/tmp/10jqka',
    codes = system.stdin.read().split('\n'),
    iCode = 0,
    pgKey = args[1], 
    pgUrl = 'http://basic.10jqka.com.cn/',
    pgEvalFn, pgName,
    pgNameMap = {
      overview: ['', evalOverviewPage],
      company: ['company.html', evalCompanyPage],
      holder: ['holder.html', evalHolderPage],
      equity: ['equity.html', evalEquityPage]
    };

function evalOverviewPage() {}
function evalHolderPage() {
  var $ = window.$, tbl = $('tbody'), dates, holderNum, holderNumChg, avgHolder, avgHolderChg, mktAvgHolder, outs = [], rowIdx, rIdx, iRow;
  if (tbl[1].rows.length > 5) {
    rIdx = [];
    rowIdx = $(tbl[1].rows).map(function(){
      return $(this).text().trim();
    });
    for (iRow = 0; iRow < rowIdx.length; iRow++) {
      if (rowIdx[iRow].match(/A股股东/) || rowIdx[iRow].match(/人均流通/) || rowIdx[iRow].match(/行业平均/)) rIdx.push(iRow);
    }
  } else {
    rIdx = [0, 1, 2, 3, 4];
  }
  if (rIdx.length != 5) {
    return '\n';
  }

  dates = $(tbl[2].rows[0].cells).map(function(){
    return $(this).text().trim().replace(/-/g, '');
  }).get();
  holderNum = $(tbl[3].rows[rIdx[0]].cells).map(function(){
    var t = $(this).text().trim(), v;
    return t.indexOf('万') > 0 ? t.replace(/万/, '') : isNaN(v = t / 10000) ? 0 : v.toFixed(4);
  }).get();
  holderNumChg = $(tbl[3].rows[rIdx[1]].cells).map(function(){
    return $(this).text().trim().replace(/%/, '');
  }).get();
  avgHolder = $(tbl[3].rows[rIdx[2]].cells).map(function(){
    var t = $(this).text().trim(), v;
    return t.indexOf('万') > 0 ? t.replace(/万/, '') : isNaN(v = t / 10000) ? 0 : v.toFixed(4);
  }).get();
  avgHolderChg = $(tbl[3].rows[rIdx[3]].cells).map(function(){
    return $(this).text().trim().replace(/%/, '');
  }).get();
  mktAvgHolder = $(tbl[3].rows[rIdx[4]].cells).map(function(){
    var t = $(this).text().trim(), v;
    return t.indexOf('万') > 0 ? t.replace(/万/, '') : isNaN(v = t / 10000) ? 0 : v.toFixed(4);
  }).get();

  for (var i = 0; i < dates.length; i++) {
    outs.push(dates[i] + '\t' + holderNum[i] + '\t' + holderNumChg[i] + '\t' + avgHolder[i] + '\t' + avgHolderChg[i] + '\t' + mktAvgHolder[i]);
  }
  return outs.join('\t') + '\n';
}
function evalEquityPage() {
  var $ = window.$, tbl = $('tbody'), tblIdx = tbl.length - 1, capitalization, capFloating, text, outs = [];

  outs.push($(tbl[tblIdx].rows[0].cells[0]).text().replace(/-/g,''));  // chgDate
  text = $(tbl[tblIdx].rows[0].cells[2]).text();
  capitalization = text.match(/\d+\.*\d*/);
  if (capitalization) { 
    capitalization = capitalization[0].trim();
    if (text.indexOf('亿') > -1) capitalization = (capitalization * 10000).toFixed(2);
    outs.push(capitalization);
  } else {
    return null;
  }
  text = $(tbl[tblIdx].rows[0].cells[3]).text();
  capFloating = text.match(/\d+\.*\d*/);
  if (capFloating) {
    capFloating = capFloating[0].trim();
    if (text.indexOf('亿') > -1) capFloating = (capFloating * 10000).toFixed(2);
    outs.push(capFloating);
  } else {
    return null;
  }

  return outs.join('\t') + '\n';
}
function evalCompanyPage() {
  var $ = window.$, tbl = $('tbody'), text, outs = [];

  outs.push($('.code h1 a').text().trim().replace(/\d{6}/, '')); // comAbbr
  outs.push($(tbl[0].rows[0].cells[1].children[1]).text().trim());  // comName

  return outs.join('\t') + '\n';
}

function proc() {
  var code = codes[iCode++].trim();
  
  if (code.length > 0) {
    pgUrl = pgUrl + code + '/' + pgName;

    page.open(pgUrl, function(status) {
      if (status !== 'success') {
        system.stderr.writeLine(code + ' Unable to access network');
      } else {
        var out = null, tmpCodePath = tmpPath + '/' + code + '/';

        if (!fsys.isDirectory(tmpCodePath)) {
          fsys.makeDirectory(tmpCodePath);
        }
        fsys.write(tmpCodePath + (pgName === '' ? 'overview.html' : pgName), page.content, 'w');
        
        out = page.evaluate(pgEvalFn);
        if (out) {
          system.stdout.write(code + '\t' + out);
        }
      }
      tryNext(Math.random() * 4000);
    });
  } else {
    tryNext(0);
  }
}
function tryNext(delay) {
  if (iCode == codes.length) {
    phantom.exit();
  } else if (delay > 0) {
    setTimeout(proc, delay);
  } else {
    proc();
  }
}

if (pgNameMap.hasOwnProperty(pgKey)) {
  pgName = pgNameMap[pgKey][0];
  pgEvalFn = pgNameMap[pgKey][1];
  proc();
} else {
  system.stderr.writeLine('Unable to process this page: ' + pgKey);
  system.stderr.writeLine('Available parameters: ' + Object.keys(pgNameMap));
  phantom.exit();
}
