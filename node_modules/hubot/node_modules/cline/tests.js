if (module == require.main) {
    var mochaPath = 'node_modules/mocha/bin/mocha';
    var args = [mochaPath, '--colors', '--growl', '--require', 'should', '--reporter', 'tap', __filename];
    var proc = require('child_process').spawn(process.argv[0], args, {stdio: 'inherit'});
    proc.on('close', function (code) {
        process.exit(code);
    });
} else {

    var cli = require('./index')(undefined, true);
    var should = require('should');

    var nop = function () {
    };

    var stream = function (input, output) {
        return {
            p: '>',
            close: nop,
            write: function (str) {
                var o = output;
                if (Array.isArray(output)) {
                    o = output.shift();
                }
                if (o && str !== o) {
                    throw new Error('Expectations failed:' + o + ' got ' + str);
                }
            },
            print: function (str) {
                this.write(str);
            },
            setPrompt: function (str) {
                this.p = str;
            },
            prompt: function () {
                this.write(this.p);
                if (this.online) {
                    var i = input;
                    if (Array.isArray(input)) {
                        i = input.shift();
                    }
                    if (i) {
                        this.online(i);
                        this.write(i);
                    }
                }
            },
            emit: function(evt, i) {
                if (input && evt === 'line') {
                    this.online(i);
                }
            },
            once: nop,
            on: function (evt, fn) {
                if (input && evt === 'line') {
                    this.online = fn;
                }
            },
            removeAllListeners: nop
        }
    };

    describe('cli', function () {
        afterEach(function () {
            cli.clean();
        });
        it('should prompt', function () {
            cli.init(stream('abc', ['test>', 'abc']));
            cli.prompt('test>');
        });
        it('should fail on wrong expectations', function () {
            (function () {
                cli.init(stream('abc', ['prompt>', 'abc']));
                cli.prompt('test>');
            }).should.throw('Expectations failed:prompt> got test>');
        });
        it('should prompt for password with mask', function () {
            cli.init(stream('abc', ['pass', 'abc']));
            cli.password('pass', '*');
        });
        it('should prompt for confirm with false', function (done) {
            cli.init(stream('abc'));
            cli.confirm('sure?', function (ok) {
                ok.should.be.not.ok;
                done();
            });
        });
        it('should prompt for confirm with true', function (done) {
            cli.init(stream('y'));
            cli.confirm('sure?', function (ok) {
                ok.should.be.ok;
                done();
            });
        });
        it('should interact', function (done) {
            cli.init(stream(['abc', '\\q']));
            cli.stream.close = function () {
                done();
            };
            cli.interact('i>');
        });
        it('should allow negotiations during interact', function (done) {
            var s = '';
            cli.init(stream(['abc', 'aaa']));
            cli.interact('i>');
            cli.password('pass', function(pass) {
                pass.should.eql('try', 'pass');
            });
            cli.init(stream(['try', '\\q']));
            cli.stream.close = function () {
                done();
            };
        });
        it('should print usage by command', function () {
            cli.init(stream('\\?', ['i>', 'usage:\nstart - start command\nstop \n' +
                'exit, \\q - close shell and exit\nhelp, \\? - print this usage\nclear, \\c - clear the terminal screen']));
            cli.command('start', 'start command', {}, nop);
            cli.command('stop', nop);
            cli.prompt('i>');
        });
        it('should print usage', function () {
            cli.init(undefined);
            cli.command('start', 'start command', {}, nop);
            cli.command('stop', nop);
            cli.usage().should.eql('usage:\nstart - start command\nstop \n' +
                'exit, \\q - close shell and exit\nhelp, \\? - print this usage\nclear, \\c - clear the terminal screen', 'usage');
        });
        it('should fire history', function (done) {
            cli.init(stream('aaa'));
            cli.on('history', function (line) {
                line.should.eql('aaa', 'history item');
                done();
            });
            cli.prompt('i>');
        });
        it('should add history items', function () {
            cli.init(undefined);
            cli.history(['a', 'b', 'c']);
            cli.history().should.eql(['c', 'b', 'a'], 'history');
        });
        it('should fill completer', function (done) {
            cli.init();
            cli.command('start', nop);
            cli.command('stop', nop);
            cli.stream.completer('s', function (err, res) {
                res[0].should.eql(['start', 'stop'], 'completions');
                done();
            });
        });
        it('should parse command', function (done) {
            cli.command('#{number}{cmd}', 'task command by number', {number: '\\d{1,3}', cmd: 'x|\\+|-'}, function (input, args) {
                args.number.should.eql(12, 'number');
                args.cmd.should.eql('x', 'command');
                done();
            });
            cli.command('*', function (input) {
                throw new Error(input);
            });
            cli.parse('#12x');
        });
        it('should parse command medium declaration', function (done) {
            cli.command('#aaa', 'do aaa', function (input) {
                input.should.eql('#aaa', 'input');
                done();
            });
            cli.command('*', function (input) {
                throw new Error(input);
            });
            cli.parse('#aaa');
        });
        it('should parse command short declaration', function (done) {
            cli.command('#aaa', function (input) {
                input.should.eql('#aaa', 'input');
                done();
            });
            cli.command('*', function (input) {
                throw new Error(input);
            });
            cli.parse('#aaa');
        });
        it('should respect empty string in command', function (done) {
            cli.command('#{number}{cmd}', 'task command by number', {number: '\\d{1,3}', cmd: 'x|\\+|-|'}, function (input, args) {
                args.number.should.eql(12, 'number');
                args.cmd.should.eql('', 'command');
                done();
            });
            cli.command('*', function (input) {
                throw new Error(input);
            });
            cli.parse('#12');
        });
	it('should respect special chars', function (done) {
            cli.command('?{number}+{cmd}$', 'task command by number', {number: '\\d{1,3}', cmd: 'x|\\+|-|'}, function (input, args) {
                args.number.should.eql(12, 'number');
                args.cmd.should.eql('x', 'command');
                done();
            });
            cli.command('*', function (input) {
                throw new Error(input);
            });
            cli.parse('?12+x$');
        });
	it('should respect inner groups', function (done) {
            cli.command('?{numbers}{cmd}', 'task command by numbers', {numbers: '((\\d)+,?)+', cmd:'x|>|<'}, function (input, args) {
                args.numbers.should.eql('12,3', 'numbers');
		args.cmd.should.eql('>', 'command');
                done();
            });
            cli.command('*', function (input) {
                throw new Error(input);
            });
            cli.parse('?12,3>');
        });
        it('should parse command and return', function () {
            cli.command('#{number}{cmd}', 'task command by number', {number: '\\d{1,3}', cmd: 'x|\\+|-'}, function (input, args) {
                args.number.should.eql(12, 'number');
                args.cmd.should.eql('x', 'command');
                return 'cool';
            });
            cli.command('*', function (input) {
                throw new Error(input);
            });
            cli.parse('#12x').should.eql('cool', 'return');
        });
        it('should fire command', function (done) {
            cli.command('{str}', '', {str:'[A-Za-z]+'});
            cli.command('{number}', '', {number:'\\d+'});

            cli.once('command', function(input, cmd) {
                input.should.eql('aaaa', 'string');
                cmd.should.eql('{str}', 'cmd');
                done();
            });
            cli.parse('aaaa');
        });
        it('should match whole command', function (done) {
            cli.command('{str}', '', {str:'[A-Za-z]+'});
            cli.command('{str} {str}', '', {str:'\\w+'});

            cli.once('command', function(input, cmd) {
                cmd.should.eql('{str} {str}', 'cmd');
                input.should.eql('aaaa bbb', 'string');
                done();
            });
            cli.parse('aaaa bbb');
        });
        it('should override command', function (done) {
            cli.command('#{number}{cmd}', 'task command by number', {number: '\\d{1,3}', cmd: 'x|\\+|-'}, function () {
                console.log('wrong');
            });
            cli.command('#{number}{cmd}', 'task command by number', {number: '\\d{1,3}', cmd: 'x|\\+|-'}, function (input, args) {
                args.number.should.eql(12, 'number');
                args.cmd.should.eql('x', 'command');
                done();
            });
            cli.command('*', function (input) {
                throw new Error(input);
            });
            cli.parse('#12x');
        });
        it('should respect command order', function (done) {
            cli.command('#{number}{cmd}', 'task command by number', {number: '\\d{1,3}', cmd: 'x|\\+|-'}, function () {
                console.log('wrong');
            });
            cli.command('*', function (input) {
                throw new Error(input);
            });
            cli.command('#{number}x', 'task command by number', {number: '\\d{1,3}'}, function () {
                console.log('wrong');
            });
            cli.command('#{number}{cmd}', 'task command by number', {number: '\\d{1,3}', cmd: 'x|\\+|-'}, function (input, args) {
                args.number.should.eql(12, 'number');
                args.cmd.should.eql('x', 'command');
                done();
            });
            cli.parse('#12x');
        });
        it('should support modes', function (done) {
            cli.mode('a', function () {
                done();
            });
            cli.mode('b', function () {
                cli.parse('a');
            });
            cli.parse('b');
        });
        it('should clean commands on mode', function (done) {
            cli.mode('a', function () {
                should.not.exist(cli.parse('test'));
                done();
            });
            cli.mode('b', function () {
                cli.command('test', nop);
                cli.parse('test').should.be.ok;
                cli.parse('a');
            });
            cli.parse('b');
        });
    });
}
