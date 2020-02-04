var page = require('webpage').create(),
    system = require('system'),
    args = system.args,
    codes = system.stdin.read().split('\t'),
    code = '',
    iCode = 0,
    pgUrl = 'http://hq.sinajs.cn/list=',
    reqestCodes = [];
const MAX_REQUEST_ONCE = 500;

page.settings.userAgent = 'tsp/0.0.1';
page.settings.loadImages = false;
page.onResourceTimeout = logError;
page.onResourceError = logError;

function proc() {
  code = codes[iCode++].trim();
  if (code.length > 0) reqestCodes.push((code.substr(0,1) == '6' ? 'sh' : 'sz') + code);
  if (reqestCodes.length == MAX_REQUEST_ONCE || iCode == codes.length) {
    page.open(pgUrl + reqestCodes.join(','), function(status) {
      if (status == 'success') {
        var rows = page.plainText.split('\n'), iRow = 0, vals = [];
        for (; iRow < rows.length; iRow++) {
          var cols = rows[iRow].split(','), amount, matched;

          if (cols.length > 1 && Number(cols[1]) > 0 && Number(cols[2]) > 0) {
            amount = cols[20] * cols[21] + cols[22] * cols[23] + cols[24] * cols[25] + cols[26] * cols[27] + cols[28] * cols[29];
            if (amount > 0) {
              matched = cols[0].match(/var hq_str_s[h|z](\d+)="(.+)/);
              vals.push(matched[1], matched[2], ((cols[10] * cols[11] + cols[12] * cols[13] + cols[14] * cols[15] + cols[16] * cols[17] + cols[18] * cols[19]) / amount).toFixed(2));
              system.stdout.writeLine(vals.join('\t'));
              vals.length = 0;
            }
          }
        }
        reqestCodes.length = 0;
        tryNext(Math.random() * 2000);
      } else {
        system.stderr.writeLine('Unable to access network');
        phantom.exit();
      }
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

proc();

function logError(obj) {
    system.stderr.writeLine(code + ':' + JSON.stringify(obj));
}
