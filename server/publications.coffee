Meteor.publish 'posts',(options) ->
  check options,
    sort: Object
    limit: Number
  Posts.find {}, options

Meteor.publish 'singlePost', (id) ->
  check id, String
  Posts.find(id)

Meteor.publish 'comments', (postId)->
  check postId, String
  Comments.find
    postId: postId

Meteor.publish "notifications", ->
  Notifications.find
    userId: @userId
    read: false

Meteor.publish "currentUser", ->
  Meteor.users.find @userId,
    fields:
      createdAt: 1
      intercomHash: 1

