crypto = require 'crypto'

exports.gravatar = (mail, size = 80) ->
  hash = crypto.createHash('md5').update(_.str.trim mail.toLowerCase()).digest('hex')
  return "//www.gravatar.com/avatar/#{hash}?size=#{size}"
