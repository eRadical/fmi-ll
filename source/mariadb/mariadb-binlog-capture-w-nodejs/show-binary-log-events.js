
const ZongJi = require('zongji');
const zongji = new ZongJi({
    host     : '127.0.0.1',
    user     : 'sakila',
    password : 'sakila',
    // debug: true
});

zongji.on('binlog', function(evt) {
    evt.dump();
});

zongji.start({
    startAtEnd: true,
    includeEvents: ['tablemap', 'writerows', 'updaterows', 'deleterows'],
});

process.on('SIGINT', function() {
    console.log('Got SIGINT.');
    zongji.stop();
    process.exit();
});
