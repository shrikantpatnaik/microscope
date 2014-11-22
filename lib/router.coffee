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

Router.route "/feed.xml",
  where: "server"
  name: "rss"
  action: ->
    feed = new RSS(
      title: "New Microscope Posts"
      description: "The latest posts from Microscope, the smallest news aggregator."
    )

    Posts.find({},
      sort:
        submitted: -1

      limit: 20
    ).forEach (post) ->
      feed.item
        title: post.title
        description: post.body
        author: post.author
        date: post.submitted
        url: "/posts/" + post._id

    @response.write feed.xml()
    @response.end()

Router.route "/api/posts",
  where: "server"
  name: "apiPosts"
  action: ->
    parameters = @request.query
    limit = (if !!parameters.limit then parseInt(parameters.limit) else 20)
    data = Posts.find({},
      limit: limit
      fields:
        title: 1
        author: 1
        url: 1
        submitted: 1
    ).fetch()
    @response.write JSON.stringify(data)
    @response.end()
    return

Router.route "/api/posts/:_id",
  where: "server"
  name: "apiPost"
  action: ->
    post = Posts.findOne(@params._id)
    if post
      @response.write JSON.stringify(post)
    else
      @response.writeHead 404,
        "Content-Type": "text/html"

      @response.write "Post not found."
    @response.end()
    return

if Meteor.isClient
  Router.onBeforeAction "dataNotFound",
    only: "postPage"

  Router.onBeforeAction requireLogin,
    only: 'postSubmit'
