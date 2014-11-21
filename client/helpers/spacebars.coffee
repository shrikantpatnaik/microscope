UI.registerHelper 'pluralize', (n, thing) ->
  if(n is 1)
    "1 #{thing}"
  else
    "#{n} #{thing}s"
