var cli = require('./index')();

cli.mode('player', 'player mode', function () {
    var song = null;
    cli.command('play {song}', 'Plays the song', {song: '[A-Za-z]+'}, function (input, args) {
        song = args.song;
        console.log('Started ' + song);
    });
    cli.command('stop', 'Stops the song', function () {
        if(song) {
            console.log('Stopped ' + song);
            song  = null;
        } else {
            console.log('No songs playing');
        }
    });
});
cli.mode('calc {operation}', 'calculator mode', {operation: '\\+|\\-|\\*|\\/|'}, function (input, args) {
    var op = args.operation;
    if (op === '+') {
        cli.command('{a} {b}', 'Adds 2 numbers', {a: '\\d+', b: '\\d+'}, function (input, args) {
            console.log(args.a + args.b);
        });
    } else if (op === '-') {
        cli.command('{a} {b}', 'Subtracts 2 numbers', {a: '\\d+', b: '\\d+'}, function (input, args) {
            console.log(args.a - args.b);
        });
    } else if (op === '*') {
        cli.command('{a} {b}', 'Multiplies 2 numbers', {a: '\\d+', b: '\\d+'}, function (input, args) {
            console.log(args.a * args.b);
        });
    } else if (op === '*') {
        cli.command('{a} {b}', 'Divides 2 numbers', {a: '\\d+', b: '\\d+'}, function (input, args) {
            console.log(args.a / args.b);
        });
    }
});

cli.history(['player', 'calculator']);
cli.interact('>');

cli.on('close', function () {
    console.log('History:' + cli.history());
    process.exit();
});