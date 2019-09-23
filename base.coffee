Base = require './weya/base'

class SchedulerBase extends Base
 @extend()
 @initialize (@id, @options, @handler, @timezone, @files, @isDone) ->
  @type = @options.type
  @timeOffset = (new Date()).getTimezoneOffset() * 60 * 1000 + @timezone
  @opt = @options.options
  @_parseOptions?()
  @running = off

  @last = @gap = @key = null

  Time = new Date().getTime()
  next = @nextTime Time
  if next?
   times = @files.read @id
   if times?
    @last = times.last
    @gap = times.gap
    @key = times.key
    k = @_key()
    if @key isnt k
     @last = @lastTime Time
     @gap = next - @last
     @key = k
   else
    @last = @lastTime Time
    @gap = next - @last
   if not @key?
    @key = @_key()

 _key: ->
  throw new Error 'Sheduler::_key() is not implemented'

 _nextTime: ->
  throw new Error 'Sheduler::_nextTime() is not implemented'

 _lastTime: ->
  throw new Error 'Sheduler::_lastTime() is not implemented'

 nextTime: (Time) ->
  res = (@_nextTime Time + @timeOffset)
  if res?
   return res - @timeOffset
  else
   return null

 lastTime: (Time) ->
  res = (@_lastTime Time + @timeOffset)
  if res?
   return res - @timeOffset
  else
   return null

 update: (Time) ->
  next = @nextTime Time
  if next?
   @last = @lastTime Time
   @gap = next - @last
  return

 @listen 'check', (Time) ->
  if @running is on
   return
  if Time - @last >= @gap
   @running = on
   @update Time

   done = =>
    o =
     last: @last
     gap: @gap
     key: @key
    @files.write @id, o
    @running = off

   exe = =>
    if @isDone
     @handler done
    else
     @handler()
     done()
   setTimeout exe, 0

module.exports = SchedulerBase
