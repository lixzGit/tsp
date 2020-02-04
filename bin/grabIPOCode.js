var page = require('webpage').create(),
    system = require('system'),
    args = system.args,
    pgNum = args[2] ? args[2] : '1',
    pgUrl = 'http://data.10jqka.com.cn/ipo/xgsgyzq/board/all/field/SSRQ/page/' + pgNum + '/order/desc/ajax/1/';
page.settings.userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.4 Safari/605.1.15';
page.settings.loadImages = false;
page.onResourceTimeout = logError;
page.onResourceError = logError;

function logError(obj) {
	if (obj.url && obj.url.search(/localhost\.10jqka\.com\.cn/) == -1) system.stderr.writeLine(JSON.stringify(obj));
}

page.open('http://data.10jqka.com.cn/ipo/xgsgyzq/', function(s) {
	if (s == 'success') {
		page.open(pgUrl, function(status) {
			if (status == 'success') {
				system.stdout.write(page.evaluate(function(date) {
					var tbl = document.getElementById('maintable'), outs = [], code;
					for (var iRow = 2; iRow < tbl.rows.length; iRow++) {
						code = tbl.rows[iRow].cells[0].innerText.trim();
						if (code.substr(0,3) != '688' && tbl.rows[iRow].cells[14].innerText.trim() == date) outs.push(code);
					}

					return outs.length == 0 ? '' : outs.join('\n') + '\n';
				}, args[1] ? args[1] : (new Date).toISOString().substr(5,5)));
			} else {
				system.stderr.writeLine('Unable to access network');
			}

			phantom.exit();
		});
	} else {
		system.stderr.writeLine('Unable to access network');
		phantom.exit();
	}
});
