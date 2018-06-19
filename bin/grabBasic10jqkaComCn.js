var page = require('webpage').create(),
    system = require('system'),
    fsys = require('fs'),
    codeTblPath = '/Users/lixz/tsp/codeTbl.txt',
    codes = fsys.read(codeTblPath).split('\n'),
    code;

phantom.exit();
for (iCode in codes) {
  code = codes[iCode].trim();
  if (code.length == 0) continue;
  page.open('http://basic.10jqka.com.cn/'+code+'/equity.html', function(status) {
    if (status !== 'success') {
      system.stderr.writeLine(code + ' Unable to access network');
    } else {
      var out = null;
      out = page.evaluate(function() {
        var $ = window.$,
            tbl = $('tbody'),
            capitalization,capFloating,chgDate;

            chgDate = $(tbl[4].rows[0].cells[0]).text().replace(/-/g,'');
            capitalization = $(tbl[4].rows[0].cells[2]).text().match(/\d+\.*\d*/);
            if (capitalization) { 
              capitalization = capitalization[0].trim();
            } else {
              return null;
            }
            capFloating = $(tbl[4].rows[0].cells[3]).text().match(/\d+\.*\d*/);
            if (capFloating) {
              capFloating = capFloating[0].trim();
            } else {
              return null;
            }

        return chgDate + ' ' + capitalization + ' ' + capFloating + '\n';
      });
      if (out) {
        system.stdout.write(out);
      }
    }
    if (iCode + 1 == codes.length) {
      cphantom.exit();
    }
  });
}
