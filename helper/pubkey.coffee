fs = require 'fs'
crypto = require 'crypto'
{exec} = require 'child_process'

exports.pubkey = (username, callback) ->
  home = switch process.platform
    when 'darwin' then '/Users'
    when 'linux' then '/home'
    else throw new Error 'unsupported platform'

  dirpath = "#{home}/#{username}/.ssh"
  keypath = "#{home}/#{username}/.ssh/authorized_keys"
  uid = "#{username}:staff"

  (fs.mkdirSync dirpath) unless fs.existsSync dirpath
  (fs.writeFileSync keypath, '') unless fs.existsSync keypath

  keys = {}
  for key in _.compact (fs.readFileSync keypath, 'utf-8').split '\n'
    val = new Buffer (key.split ' ')[1], 'base64'
    val = crypto.createHash('md5').update(val).digest('hex')
    val = (_.str.chop val, 2).join ':'
    keys[val] = key

  exec "chmod 700 #{dirpath} && chmod 600 #{keypath}", (err) ->
    return (callback err, null) if err
    exec "chown #{uid} #{dirpath} #{keypath}", (err) ->
      return callback err, keys
