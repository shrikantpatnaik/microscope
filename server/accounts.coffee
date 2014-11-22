Accounts.onCreateUser (options, user) ->
  user.intercomHash = IntercomHash(user, "lGr-8CWFrj6qSN6a_DQG8J9AYnWhN9EafqRYk8wb")
  user.profile = options.profile  if options.profile
  user
