module.exports = (app) ->

  events = (require path.resolve 'config', 'events') app
  LG = app.get('util').logger()
  EN = app.get('util').ensure

  # method routing          flags   route
  app.post '/auth/signin',  LG,     events.auth.signin
  app.get  '/auth/signout', LG,     events.auth.signout
  app.get  '*',             LG, EN, events.main

  return app.get('util').logger()