/**
 * Cline
 *
 * Copyright 2013, Wolfgang Bas
 * Released under the MIT License
 */
var EventEmitter = require('events').EventEmitter;


var Commands = function () {
    this.map = function (fn) {
        var res = [];
        for (var prop in this) {
            if (this.hasOwnProperty(prop)) {
                if (prop === '*' || prop == 'map') {
                    continue;
                }
                var r = fn(prop, this[prop]);
                res.push(r);
                if (r === false) {
                    break;
                }
            }
        }
        return res;
    };
};

var command = function (cmd, desc, args, fn) {
    this.cmd = cmd;
    if (!fn && typeof args == 'function') {
        fn = args;
        args = {};
    }
    if (!fn && typeof desc == 'function') {
        fn = desc;
        desc = '';
        args = {};
    }
    this.desc = desc;
    this.args = args;
    this.listener = fn;
};

var defaultFn = function (val, fn) {
    if ('\\q' === val || 'exit' === val) {
        this.close();
    } else if ('\\?' === val || 'help' === val) {
        this.usage();
    } else if ('\\c' === val || 'clear' === val) {
        this.stream.write(null, {ctrl: true, name: 'l'});
    }
    fn ? fn.call(this, val) : this.parse(val);
};

var nextTick = function (str, mask, fn) {
    var cb = function () {
        this.ask(str, mask, function (line) {
            fn(line);
            if (typeof this._nextTick == 'function') {
                this._nextTick();
            }
        });
    };
    cb.call(this);
};

var convert = function (string, context) {
    var res = string;
    var reviver = function (k, v) {
        if (typeof v == 'string' && v[0] == '#') {
            return context[v.substring(1)];
        }
        return v;
    };
    if ('true' === string) {
        res = true
    } else if ('false' === string) {
        res = false
    } else if (/^\d+$/.test(string)) {
        if (string.indexOf('.') != -1) {
            res = parseFloat(string);
        } else {
            res = parseInt(string, 10);
        }
    } else if (string[0] == '[' && string[string.length - 1] == "]") {
        string = string.replace(/'/g, '"');
        res = JSON.parse(string, reviver);
    } else if (string[0] == '{' && string[string.length - 1] == "}") {
        string = string.replace(/'/g, '"');
        res = JSON.parse(string, reviver);
    } else if (string[0] == '"' || string[0] == "'") {
        res = string.substring(1, string.length - 1);
    }
    return res;
};

var defaultStream = function () {
    var completer = function (line) {
        var completions = this.commands.map(function (prop, val) {
            return val.cmd;
        });
        completions.unshift('help', '\\?', 'clear', '\\c', 'exit', '\\q');
        var hits = completions.filter(function (c) {
            return c.indexOf(line) == 0
        });
        return [hits.length ? hits : completions, line]
    }.bind(this);
    var stream = require('readline').createInterface(process.stdin, process.stdout, completer, true);
    stream.print = function (msg) {
        console.log(msg);
    };
    var self = this;
    var oldInsertString = stream._insertString;
    stream._insertString = function (c) {
        if (self.mask != undefined) {
            self._buf += c;
            oldInsertString.call(stream, self.mask);
        } else {
            oldInsertString.call(stream, c);
        }
    };
    return stream;
};

var Cli = function (stream) {
    this.init(stream);
    EventEmitter.call(this);
    this.commands = new Commands();
    this.modes = [];
};

require('util').inherits(Cli, EventEmitter);

Cli.prototype.init = function (stream) {
    var old = this.stream;
    if (!stream) {
        stream = defaultStream.call(this);
    }
    this.stream = stream;
    var self = this;
    stream.once('close', function () {
        self.emit('close');
    });
    stream.on('line', function (line) {
        self.emit('history', line);
        if (self.fn) {
            self.fn(line);
        }
    });
    if (old) {
        process.nextTick(function () {
            old.emit('line', '\n');
            old.removeAllListeners('close');
            old.removeAllListeners('line');
        });
    }
};

Cli.prototype.usage = function () {
    var res = 'usage:';
    this.commands.map(function (prop, val) {
        res += '\n';
        res += val.cmd;
        res += val.desc ? ' - ' + val.desc : ' ';
    });
    res += '\nexit, \\q - close shell and exit';
    res += '\nhelp, \\? - print this usage';
    res += '\nclear, \\c - clear the terminal screen';
    this.stream.print(res);
    this.emit('usage', res);
    return res;
};

Cli.prototype.interact = function (promptStr) {
    this.setPrompt(promptStr);
    if (this._nextTick) {
        return;
    }
    this._nextTick = function () {
        this.ask(this._prompt, function (val) {
            this.parse(val);
            if (typeof this._nextTick == 'function') {
                this._nextTick();
            }
        });
    };
    this._nextTick.call(this);
};

Cli.prototype.setPrompt = function (promptStr) {
    this._prompt = promptStr;
    return this._prompt;
}

Cli.prototype.ask = function (str, mask, fn) {
    var stream = this.stream;
    // default mask
    if (typeof mask == 'function') {
        fn = mask;
        mask = null;
    }
    stream.setPrompt(str);
    this.mask = mask;
    if (this.mask != undefined) {
        this._buf = '';
    }
    this.fn = function (line) {
        if (this._buf) {
            line = this._buf;
            this._buf = '';
        }
        var val = line.trim();
        if (!val.length) {
            this.ask(str, mask, fn);
        } else {
            defaultFn.call(this, val, fn);
        }
    };
    stream.prompt();
};

Cli.prototype.prompt = function (str, fn) {
    var self = this;
    nextTick.call(this, str, null, function (line) {
        fn ? fn(line) : self.parse(line);
    });
};

Cli.prototype.password = function (str, mask, fn) {
    if (typeof mask == 'function') {
        fn = mask;
        mask = '';
    }
    var self = this;
    nextTick.call(this, str, mask, function (line) {
        fn ? fn(line) : self.parse(line);
    });
};

Cli.prototype.confirm = function (str, fn) {
    var self = this;
    nextTick.call(this, str, null, function (line) {
        fn ? fn(/^y|yes|ok|true$/i.test(line)) : self.parse(line);
    });
};

Cli.prototype.mode = function (name, desc, args, fn) {
    var c = new command(name, desc, args, fn);
    this.modes.push(name);
    var self = this;
    this.command(c.cmd, c.desc, c.args, function (input, args) {
        self.commands.map(function (prop, val) {
            if (self.modes.indexOf(val.cmd) == -1) {
                delete self.commands[prop];
            }
        });
        var cb = c.listener;
        cb && cb(input, args);
        self._prompt = input + '>';
    });
};

Cli.prototype.close = function () {
    delete this._nextTick;
    this.stream.close();
};

Cli.prototype.command = function (cmd, desc, args, fn) {
    var c = new command(cmd, desc, args, fn);
    var p = c.cmd;
    if (p != '*') {
      p = p.replace('?', '\\?').replace('$', '\\$').replace('+', '\\+').replace('^', '\\^').replace('*', '\\*');
    }
    for (var prop in args) {
        if (args.hasOwnProperty(prop)) {
            var regex = new RegExp('{' + prop + '}', 'g');
            if (regex.test(p)) {
                p = p.replace(regex, '(' + args[prop] + ')');
            }
        }
    }
    this.commands[p] = new command(c.cmd, c.desc, c.args, c.listener);
};

Cli.prototype.parse = function (str) {
    var resp = null;
    var self = this;
    this.commands.map(function (prop, val) {
        var regex = new RegExp('^' + prop + '$');
        if (str.match(regex)) {
            var matches = regex.exec(str);
            var main = matches.shift();
            var args = {};
            for (var p in val.args) {
                if (val.args.hasOwnProperty(p)) {
                    var s = matches.shift();
                    if (s) {
                        s = convert(s);
                    }
                    args[p] = s;
                    var r = val.args[p];
                    if (r.indexOf(')') != -1) {
                        for (var i = 0; i < r.length; i++) {
                            if (r.charAt(i) == ')') {
                                matches.shift();
                            }
                        }
                    }
                }
            }
            var fn = val.listener;
            resp = (fn ? fn(main, args) : true) || true;
            self.emit('command', main, val.cmd, args);
            return false;
        }
        return true;
    });
    if (!resp && this.commands['*']) {
        resp = this.commands['*'].listener(str);
    }
    return resp;
};

Cli.prototype.history = function (items) {
    if (items != undefined) {
        this.stream.history = items.reverse();
        this.stream.historyIndex = -1;

    }
    return this.stream.history;
};

module.exports = function (stream, tests) {
    var cli = new Cli(stream);
    if (tests) {
        cli.clean = function () {
            this.commands = new Commands();
            this.modes = [];
            this.stream = undefined;
        };
    }
    return cli;
};
