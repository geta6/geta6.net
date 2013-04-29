#!/usr/bin/env node
require('coffee-script');

// Global Scope
global._ = require('underscore');
global._.str = require('underscore.string');
global._.date = require('moment'); // underscore.date

// Local Scope
var path = require('path')
  , util = require('util')
  , http = require('http')
  , argv = require('optimist').argv
  , cpus = require('os').cpus().length
  , hooker = require('hooker')
  , cluster = require('cluster');

// Colorize log
hooker.hook(console, ['log', 'info', 'warn', 'error'], {
  passName: true,
  pre: function (lv, log) {
    switch(lv) {
      case 'log':   util.print("\x1b[37m"); break;
      case 'info':  util.print("\x1b[32m"); break;
      case 'warn':  util.print("\x1b[33m"); break;
      case 'error': util.print("\x1b[31m"); break;
      default: return hooker.preempt();
    }
  },
  post: function (res, name) {
    util.print('\x1b[0m');
  }
});

// Args Parser
if (argv.h) {
  console.warn('Usage:', path.basename(process.argv[1]), '[arguments]');
  console.log('  -p "port"       set listening port (3000 default)');
  console.log('  -f "fork"       process concurrency nums ('+cpus+' default)');
  console.log('  -e "env"        set application environment (development default)');
  console.log('  -c              start clock works and exit');
  console.log('  -h              show this message');
  process.exit(1);
}

// Environments
process.env.NODE_ENV = process.env.NODE_ENV || argv.e || argv.env || 'development';
process.env.PORT = process.env.PORT || argv.p || argv.port || 3000;
process.env.FORK = process.env.FORK || argv.f || argv.FORK || cpus;

// Main Application
var app = require(path.resolve('config', 'app'))
  , env = app.get('env')
  , port = app.get('port');

// Clock Works
var clockwork = function () {
  try {
    var id = ~~(new Date()/1000);
    console.log('>>', 'ClockWorks#start', '@'+id);
    require(path.resolve('config', 'clock'))(app, id, function(err) {
      if (err) { console.error('ClockWorks:', err.message); }
      console.log('>>', 'ClockWorks#done', '@'+id);
      if (argv.c) {
        process.exit(0);
      }
    });
    delete(require.cache[path.resolve('config', 'clock.coffee')]);
  } catch (e) {
    console.error('ClockWorks:', e.message);
  }
};

// Cluster Server
if (cluster.isMaster) {
  if (!argv.c) {
    console.log('==', 'Express has left the station on', port, 'for', env);
    var i = 0;
    for (i = 0; i < process.env.FORK; i++) { cluster.fork(); }
    cluster.on('exit', function (worker) {
      console.error('>>', 'HTTPServer#dead', '@'+worker.process.pid, '#'+worker.process.exitCode);
      cluster.fork();
    });
    cluster.on('listening', function(worker, address) {
      console.log('>>', 'HTTPServer#start', '@'+process.pid);
    });
  }
  // Clock Works
  console.log('>>', 'ClockWorks#set', '@'+process.pid);
  argv.c ? clockwork() : setInterval(clockwork, 120 * 1000);
} else {
  http.createServer(app).listen(port);
}
