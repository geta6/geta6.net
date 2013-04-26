mime = require 'mime'

module.exports =

  inspect: (uri) ->
    uri = uri.substr(0, uri.length-1) if _.str.endsWith uri, '/'
    ext =
      path: uri
      name: _.last uri.split '/'
      real: uri.replace '/media/var', ''
      type: mime.lookup uri
    if fs.existsSync uri
      stat = _.extend (fs.statSync uri), ext, live: yes
    else
      stat = _.extend ext, live: no
    return stat

  ensure: (req, res, next) ->
    return next() if req.isAuthenticated()
    res.render 'unauth', req: req

  logger: (route = null) ->
    return (req, res, next) ->
      ini = Date.now()
      end = res.end
      res.end = ->
        res.end = end
        res.emit 'end'
        res.end.apply @, arguments
      res.on 'end', ->
        util.print "\x1b[90m[#{moment().format('YY.MM.DD HH:mm:ss')}] "
        util.print "\x1b[35m#{req.method.toUpperCase()} "
        util.print "\x1b[37m#{decodeURI req.url} "
        if 500 <= @statusCode
          util.print "\x1b[31m#{@statusCode}\x1b[0m "
        else if 400 <= @statusCode
          util.print "\x1b[33m#{@statusCode}\x1b[0m "
        else if 300 <= @statusCode
          util.print "\x1b[36m#{@statusCode}\x1b[0m "
        else if 200 <= @statusCode
          util.print "\x1b[32m#{@statusCode}\x1b[0m "
        util.print '\x1b[90m('
        if req.route
          util.print "#{req.route.path}"
        else if route
          util.print "\x1b[35m#{route}"
        else
          util.print "\x1b[31mUnknown"
        util.print "\x1b[90m - #{Date.now() - ini}ms)\x1b[0m\n"
      next()
