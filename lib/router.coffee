Router.configure
  layoutTemplate: "layout"
  loadingTemplate: 'loading'
  notFoundTemplate: 'notFound'
  waitOn: ->
    [
      Meteor.subscribe 'notifications'
    ]

@PostsListController = RouteController.extend(
  template: "postsList"
  increment: 5
  postsLimit: ->
    parseInt(@params.postsLimit) or @increment

  findOptions: ->
    sort: @sort
    limit: @postsLimit()

  subscriptions: ->
    @postsSub = Meteor.subscribe("posts", @findOptions())
    return

  posts: ->
    Posts.find {}, @findOptions()

  data: ->
    hasMore = @posts().count() is @postsLimit()
    posts: @posts()
    ready: @postsSub.ready
    nextPath: (if hasMore then @nextPath() else null)
)

@NewPostsController = PostsListController.extend(
  sort:
    submitted: -1
    _id: -1

  nextPath: ->
    Router.routes.newPosts.path postsLimit: @postsLimit() + @increment
)

@BestPostsController = PostsListController.extend(
  sort:
    votes: -1
    submitted: -1
    _id: -1

  nextPath: ->
    Router.routes.bestPosts.path postsLimit: @postsLimit() + @increment
)

Router.route "/",
  name: "home"
  controller: NewPostsController

Router.route "/new/:postsLimit?",
  name: "newPosts"

Router.route "/best/:postsLimit?",
  name: "bestPosts"

Router.route "/posts/:_id",
  name: "postPage"
  waitOn: ->
    Meteor.subscribe 'comments', @params._id
    Meteor.subscribe 'singlePost', @params._id
  data: ->
    Posts.findOne @params._id

Router.route "/posts/:_id/edit",
  name: "postEdit"
  waitOn: ->
    Meteor.subscribe 'singlePost', @params._id
  data: ->
    Posts.findOne @params._id

Router.route '/submit',
  name: 'postSubmit'

requireLogin = ->
  unless Meteor.user()
    if Meteor.loggingIn()
      @render @loadingTemplate
    else
      @render "accessDenied"
  else
    @next()
  return

Router.onBeforeAction "dataNotFound",
  only: "postPage"

Router.onBeforeAction requireLogin,
  only: 'postSubmit'
