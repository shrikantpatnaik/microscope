Template.header.helpers activeRouteClass: -> # route names
  args = Array::slice.call(arguments, 0)
  args.pop()
  active = _.any(args, (name) ->
    Router.current() and Router.current().route.getName() is name
  )
  active and "active"
