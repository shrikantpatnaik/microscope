Meteor.publish 'posts', ->
  Posts.find()

Meteor.publish 'comments', (postId)->
  check postId, String
  Comments.find
    postId: postId
