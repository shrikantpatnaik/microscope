Tracker.autorun ->
  if Meteor.user() and not Meteor.loggingIn()
    intercomSettings =
      name: Meteor.user().username
      email: Meteor.user().emails[0].address
      created_at: Math.round(Meteor.user().createdAt / 1000)
      favorite_color: _.sample([
        "blue"
        "red"
        "green"
        "yellow"
      ])
      user_id: Meteor.user()._id
      widget:
        activator: '#Intercom'
        use_counter: true
      app_id: "hvoh8if7"
    Intercom "boot", intercomSettings
  return
