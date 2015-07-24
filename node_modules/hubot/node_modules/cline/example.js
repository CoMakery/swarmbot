var cli = require('./index')();

cli.command('start', 'starts program', function () {
    cli.password('Password:', function (str) {
        console.log(str);
        cli.prompt('next>');
    })
});
cli.command('stop', function () {
    cli.confirm('Sure?', function (ok) {
        if (ok) {
            console.log('done');
            cli.emit('close');
        } else {
            cli.prompt('next>');
        }
    })
});

cli.command('{string}', '', {string: '[A-Za-z]+'});
cli.command('{number}', '', {number: '\\d+'});

cli.on('command', function (input, cmd) {
    if ('start' !== cmd && 'stop' != cmd) {
        cli.prompt('More details on ' + input + ':');
    }
});

cli.history(['start', 'stop']);
cli.prompt('>');

cli.on('history', function (item) {
    console.log('New history item ' + item);
});

cli.on('close', function () {
    console.log('History:' + cli.history());
    process.exit();
});