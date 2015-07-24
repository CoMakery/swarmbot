cline
=====

Command-line apps building library for Node.

Cline is based on Node module [readline](http://nodejs.org/api/readline.html) and includes history, completions, prompt,
password, confirm, input mask and (most interesting) regexp commands support.

## Installation

    $ npm install cline

## Usage

```js
    require('cline')();
```

  If you need to provide your own command line interface,
  you can pass it as parameter, visit [tests.js]( https://github.com/kucoe/cline/blob/master/tests.js) for mock example.

```js
    var cli = require('cline')(mock);
```

  Passing second parameter allows to get direct commands access and clean function (for test purposes)

```js
    var cli = require('cline')(mock, true);
```

### Methods

  __command(cmd, description, args, callback)__ - adds command to match user input with.

  *cmd* - could be simple name or any other string with arguments placeholders. For ex.

  ```js
    cli.command('#{number}', '', {number: '\\d+'});
  ```
  *{number}* is an argument placeholder literal that will be replaced with argument regexp

  *description* - command description used for help output

  *args* - object containing argument name as key and valid regexp as value to form command matching pattern.
      Arguments should be unique and follow placeholders order

  *callback* - is function to be called when command is matched,
      it gets user input and matched arguments values as parameters.
      Could be empty if you need just to register command and listen later for 'command' event.
  ```js
    cli.command('#{number}{cmd}', 'task command by number', {number: '\\d{1,3}', cmd: 'x|\\+|-'},
      function (input, args) {
        args.number.should.eql(12, 'number');
        args.cmd.should.eql('x', 'command');
        done();
      });
    cli.parse('#12x');
  ```
  here '#{number}{cmd}' will be replaced into '^(\\d{1,3})(x|\\+|-)$' regexp

  additionally you can register 'match all' command using '*' to react on any input,
  though this match will not invoke 'command' event.
  ```js
    cli.command('*', function (input) {
      console.log(input + 'is not good, type "help" for more info');
    });
  ```
  this method have 2 short forms: name with callback only and name with description and callback.

  ```js
    cli.command('my_command', function(){});
    cli.command('my_command', 'do it', function(){});
  ```
  __mode(name, description, args, callback)__ - similar to command. The callback is called every time mode matched,
  and all not mode commands will be removed from the scope and prompt string will change to mode name.
  Inside mode callback you can rebuild currently available commands in relation to current application status.
  See the examples section below.

  __init(stream)__ - reinitialize cli with different input output streams interface

  __usage__ - prints and returns help message

  __history(items)__ - if items are specified updates history in reverse order, else returns collected history items

  __parse(string)__ - parses user input string for matched commands

  __prompt(string, callback)__ - prompts with string specified and returns user input into callback.
      If callback function is not specified calls parse function

  __password(string, mask, callback)__ - prompts with string specified for password and returns user input into callback.
          If mask specified - hide input behind mask symbols. If mask not specified use empty symbol.
          If callback function is not specified calls parse function

  __confirm(string, callback)__ - asks user for confirmation with string specified and returns user input (converted to boolean) into callback.
          If callback function is not specified calls parse function

  __interact(string)__ - start interactive prompt for user input. Every input is parsed for matching command and prompt again.
          Calling this method second time with different string will replace prompt string.

  __setPrompt(string)__ - modifies prompt string, during interact.

  __close()__ - closes cli and stream. Allows to continue program execution after some command matched.

### System commands

    clear or \c - clears the terminal screen

    help or \? - shows help with all commands listed

    exit or \q  - close shell and exit

### Events

    close - fires when interface is closed

    command - fires when command is matched (except system commands and '*' wildcard command),
              passes user input and matched command as listener arguments

    history - fires when history item was added,
              passes history item as listener argument

    usage - fires when usage was requested,
            passes printed help as listener argument


## Example

```js
    var cli = require('cline')();

    cli.command('start', 'starts program', function () {
        cli.password('Password:', function (str) {
            console.log(str);
        })
    });
    cli.command('stop', function () {
        cli.confirm('Sure?', function (ok) {
            if (ok) {
                console.log('done');
            }
        })
    });

    cli.command('{string}', '', {string: '[A-Za-z]+'});
    cli.command('{number}', '', {number: '\\d+'});

    cli.on('command', function (input, cmd) {
        if ('start' !== cmd && 'stop' != cmd) {
            cli.prompt('More details on ' + cmd + ':');
        }
    });

    cli.history(['start', 'stop']);
    cli.interact('>');

    cli.on('history', function (item) {
        console.log('New history item ' + item);
    });

    cli.on('close', function () {
        console.log('History:' + cli.history());
        process.exit();
    });
```

##  Modes Example

```js
    var cli = require('cline')();

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
```


## License

(The MIT License)

Copyright (c) 2013 Wolf Bas &lt;becevka@gmail.com&gt;

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
