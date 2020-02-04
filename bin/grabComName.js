var page = require('webpage').create(),
    system = require('system'),
    args = system.args,
    code = args[1],
    pgUrl = 'http://basic.10jqka.com.cn/' + code + '/company.html';
page.settings.userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.4 Safari/605.1.15';
page.settings.loadImages = false;
page.onResourceTimeout = logError;
page.onResourceError = logError;

function logError(obj) {
    system.stderr.writeLine(code + ':' + JSON.stringify(obj));
}

page.open(pgUrl, function(status) {
	if (status == 'success') {
		system.stdout.write(page.evaluate(function() {
			var abbrName = $('h1').eq(0).text().trim(),
				fullName = $('.m_table')[0].rows[0].cells[1].innerText.replace(/公司名称：/,'');

			return abbrName + ' ' + fullName + '\n';
		}));
	} else {
		system.stderr.writeLine('Unable to access network');
	}

	phantom.exit();
});