exports.logger = (options = {}) ->
  options.format or= 'YY.MM.DD HH:mm:ss'
  options.public or= 'public'
  return (req, res, next) ->
    req._startTime = new Date
    end = res.end
    res.end = (chunk, encoding) ->
      req._endTime = new Date
      res.end = end
      res.end chunk, encoding
      message = "\x1b[90m[#{_.date().format(options.format)}] "
      message+= "\x1b[35m#{req.method.toUpperCase()} "
      message+= "\x1b[37m#{decodeURI req.url} "
      if 500 <= @statusCode
        message+= '\x1b[31m'
      else if 400 <= @statusCode
        message+= '\x1b[33m'
      else if 300 <= @statusCode
        message+= '\x1b[36m'
      else if 200 <= @statusCode
        message+= '\x1b[32m'
      message+= "#{@statusCode}\x1b[0m \x1b[90m("
      if req.route
        message+= "#{req.route.path}"
      else
        message+= "\x1b[31mUnknown"
      message+= "\x1b[90m - #{req._endTime - req._startTime}ms)\x1b[0m\n"
      process.nextTick -> process.stdout.write message
    next()
