Files = require './files'
Base = require './weya/base'
Types = {}
(require './hourly') Types
(require './interval') Types
(require './daily') Types
(require './weekly') Types
(require './monthly') Types

DEFAULT_CHECK_INTERVAL = 30000 # 30s

class Scheduler extends Base
 @extend()

 @initialize (timezoneHours, @dir, @interval) ->
  @timezone = timezoneHours * 60 * 60 * 1000
  @interval ?= DEFAULT_CHECK_INTERVAL
  @events = []
  @files = new Files @dir

 addEvent: (id, options, handler, isDone) ->
  type = options.type
  if Types[type]?
   @events.push new Types[type] id, options, handler, @timezone, @files, isDone
  else
   throw new Error "Invalid schedule event type #{type}"

 start: ->
  @on.check()
  @iid = setInterval @on.check, @interval

 @listen 'check', ->
  time = (new Date).getTime()
  for e in @events
   e.on.check time

module.exports = Scheduler
