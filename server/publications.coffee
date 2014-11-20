Meteor.publish 'posts', ->
  Posts.find()

Meteor.publish 'comments', (postId)->
  check postId, String
  Comments.find
    postId: postId

Meteor.publish "notifications", ->
  Notifications.find
    userId: @userId
    read: false

