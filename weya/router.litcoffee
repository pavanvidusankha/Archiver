#Weya.Router.litcoffee

    @Weya = {} unless @Weya?
    Weya = @Weya

    if not Weya.Base?
     throw new Error 'Weya.Base not found'

##Weya.Router

Routing with hash tags or pushState

    class Router extends Weya.Base
     optionalParam: /\((.*?)\)/g
     namedParam: /(\(\?)?:\w+/g
     splatParam: /\*\w+/g
     escapeRegExp: /[\-{}\[\]+?.,\\\^$|#\s]/g

     @extend()

     @initialize ->
      @_bindRoutes()
      @_event = null
      @_history = []

     _routes: {}

####Register router

`'analyse/:analysis': 'onAnalyse'`

`dashboard': ['auth', 'dashboard']`

This will match urls of the form `analyse/\*` and call method @onAnalyse
with the parameter. Second route will first call @auth if it returns
`true` @dashboard will be called.

The most specific route should be at bottom. Routers can added or overridden
in subclasses

     @routes: (routes) ->
      temp = @::_routes
      @::_routes = {}
      @::_routes[k] = v for k, v of temp
      @::_routes[k] = v for k, v of routes

####Starts routing
Option silent will not trigger an event for the current url

     start: (options) ->
      Weya.history.start options
      fragment = Weya.history.getFragment()

      if options?.silent is on
       @_history.push fragment: fragment, title: document.title

####Goes to previous page if exists

     back: ->
      if @_history.length > 1
       Weya.history.back()

####Whether it is possible to go to previous page

     canBack: ->
      if @_history.length > 1 and Weya.history.canBack()
       return true
      else
       return false

####Registers a route

     route: (route, name) ->
      if (Object.prototype.toString.call route) isnt '[object RegExp]'
       route = @_routeToRegExp route

Registers the route with Weya.history

      Weya.history.route route, (fragment, event) =>
       args = @_extractParameters route, fragment
       @_event = event

Handle state

       if @_event?.type is "popstate"
        @_history.pop()
        if @_history.length is 0
         @_history.push
          fragment: fragment
          title: document.title
          state: @getState()
       else
        @_history.push
         fragment: fragment
         title: document.title
         state: @getState()

Calls callbacks in order

       callbacks = name
       callbacks = [callbacks] if not Array.isArray callbacks

       for callback in callbacks
        if (typeof callback) is 'string'
         callback = @[callback]
        break unless callback.apply this, args

####Gets the current HTML5 History state

     getState: ->
      if @_event?.originalEvent?.state?
       return @_event.originalEvent.state
      else
       return null

####Navigate to a new URL, while setting HTML5 History state

     navigate: (fragment, options) ->
      options = {} unless options
      if options.replace
       @_history.pop()
      if not options.trigger
       @_history.push
        fragment: fragment
        title: options.title
        state: options.state

      Weya.history.navigate fragment, options

Bind routes

     _bindRoutes: ->
      for route, name of @_routes
       @route route, name

Convert a route string into a regular expression, suitable for matching

     _routeToRegExp: (route) ->
      route = route.replace @escapeRegExp, '\\$&'
                   .replace @optionalParam, '(?:$1)?'
                   .replace @namedParam, (match, optional) ->
                    if optional then match else '([^\/]+)'
                   .replace @splatParam, '(.*?)'

       return new RegExp "^#{route}$"

Extract parameters from a route regex and URL

     _extractParameters: (route, fragment) ->
      params = route.exec(fragment).slice(1)
      for p, i in params when p?
       params[i] = decodeURIComponent p

## History class

    class History extends Weya.Base
     @extend()

Strip leading hash/slash and trailing space

     routeStripper: /^[#\/]|\s+$/g

Strip leading and trailing slashes

     rootStripper: /^\/+|\/+$/g

Remove trailing slash

     trailingSlash: /\/$/

Strip urls of hash and query

     pathStripper: /[?#].*$/

     @initialize ->
      @handlers = []
      @checkUrl = @checkUrl.bind this
      @history = window.history
      @location = window.location
      @stateList = []

Hash check interval

     interval: 50

Get hash value

     getHash: ->
      match = @location.href.match /#(.*)$/
      return (if match? then match[1] else '')

Get emulated state

     getEmulateState: ->
      if @stateList.length > 0
       return @stateList[@stateList.length - 1]
      else
       return {fragment: ""}

     popEmulateState: -> @stateList.pop()

     pushEmulateState: (state, title, fragment) ->
      @stateList.push
       state: state
       title: title
       fragment: fragment

Get the URL fragment

     getFragment: (fragment, forcePushState) ->
      if not fragment?
       if @_emulateState
        fragment = @getEmulateState().fragment
       else if @_hasPushState or not @_wantsHashChange or forcePushState
        fragment = @location.pathname
        root = @root.replace @trailingSlash, ''
        if (fragment.indexOf root) is 0
         fragment = fragment.slice root.length
       else
        fragment = @getHash()

      return fragment.replace @routeStripper, ''

####Goto the previous page

     back: ->
      if @_emulateState is on
       @popEmulateState()
       @loadUrl null, null
      else
       @history?.back?()

####Can back?

     canBack: ->
      if @_emulateState is on
       return @stateList.length > 1
      else
       return @history?.back?

####Start listening to events

     start: (options) ->
      History.started = true

      opt = {root: '/'}
      opt[k] = v for k, v of @options
      opt[k] = v for k, v of options
      @options = opt
      @root = @options.root
      @_emulateState = @options.emulateState is on
      @_wantsHashChange = @_emulateState is off and @options.hashChange isnt off
      @_wantsPushState = @_emulateState is off and @options.pushState is on
      @_hasPushState = @_wantsPushState is on and @history?.pushState?
      if @_emulateState and @options.start?
       @pushEmulateState @options.start.state,
        @options.start.title
        @options.start.fragment

      @fragment = @getFragment()

Normalize root to always include a leading and trailing slash.

      @root = "/#{@root}/".replace @rootStripper, '/'

Depending on whether we're using pushState or hashes, and whether
'onhashchange' is supported, determine how we check the URL state.

      if @_hasPushState
       window.onpopstate = @checkUrl
      else if @_wantsHashChange and window.onhashchange?
       window.onhashchange = @checkUrl
      else if @_wantsHashChange
       @_checkUrlInterval = setInterval @checkUrl, @interval

      if not @options.silent
       @loadUrl null, null

####Add a listener to a router

     route: (route, callback) ->
      @handlers.unshift route: route, callback: callback

Check current url for changes

     checkUrl: (e) ->
      fragment = @getFragment()
      return if fragment is @fragment
      @loadUrl fragment, e

Call callbacks of matching route

     loadUrl: (fragment, e) ->
      try
       fragment = @fragment = @getFragment fragment
       for handler in @handlers
        if handler.route.test fragment
         return handler.callback fragment, e
      catch e
       @onerror? e

      return

####Navigate to a URL
Triggers a route is option trigger is on
Replaces the url is option replace is on
Sets state and title

     navigate: (fragment, options) ->
      return false if not History.started

      fragment = @getFragment(fragment or '')
      url = @root + fragment

Strip the fragment of the query and hash for matching.

      fragment = fragment.replace @pathStripper, ''

      return if @fragment is fragment
      @fragment = fragment

Don't include a trailing slash on the root.

      if fragment is '' and url isnt '/'
       url = url.slice 0, -1

If pushState is available, we use it to set the fragment as a real URL.

      if @_emulateState
       if options.replace is on
        @popEmulateState()
       state = {}
       state = options.state if options.state?
       title = ''
       title = options.title if options.title?
       @pushEmulateState state, title, fragment
      else if @_hasPushState
       method = if options.replace then 'replaceState' else 'pushState'
       state = {}
       state = options.state if options.state?
       title = ''
       title = options.title if options.title?
       @history[method] state, title, url

If hash changes haven't been explicitly disabled, update the hash
fragment to store history.

      else if @_wantsHashChange
       @_updateHash @location, fragment, options.replace

If you've told us that you explicitly don't want fallback hashchange-
based history, then `navigate` becomes a page refresh.

      else
       return @location.assign url
      if options.trigger
       return @loadUrl fragment, null

Update the hash

     _updateHash: (location, fragment, replace) ->
      if replace
       href = location.href.replace /(javascript:|#).*$/, ''
       location.replace "#{href}##{fragment}"
      else
       location.hash = "##{fragment}"

    Weya.Router = Router
    Weya.history = new History

