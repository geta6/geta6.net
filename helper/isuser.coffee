{exec} = require 'child_process'

failureTimeout = 1000

exports.isuser = (username, password, done) ->
  pycode = """
    from draxoft.auth import pam
    h = pam.handle()
    h.user = '#{username}'
    h.conv = lambda style,msg,data: '#{password}'
    print h.authenticate(),
    """
  exec "python -c \"#{pycode}\"", (err, stdout, stderr) ->
    stdout = (eval (_.str.trim stdout).toLowerCase())
    unless (success = if err then no else stdout)
      return setTimeout (-> return done err, no), failureTimeout unless success
    return done err, success
