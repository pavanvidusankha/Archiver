Base = require './base'

class MonthlyScheduler extends Base
 @extend()

 _key: -> "#{@date}:#{@hour}:#{@min}"

 _parseOptions: ->
  @date = @opt.date
  @date = parseInt @date
  @hour = parseInt @opt.hour
  @min = parseInt @opt.minute
  if not @date? or isNaN @date
   throw new Error "Scheduler missing/invalid date value in scheduler #{@id}"
  if not @hour? or isNaN @hour
   throw new Error "Scheduler missing/invalid hour value in scheduler #{@id}"
  if not @min? or isNaN @min
   throw new Error "Scheduler missing/invalid minute value in scheduler #{@id}"
  @hour = @hour % 24
  @min = @min % 60

 _nextTime: (Time) ->
  cur = new Date Time
  next = new Date cur.getFullYear(), cur.getMonth(), @date, @hour, @min
  time = next.getTime()
  if time <= cur.getTime()
   next.setMonth next.getMonth() + 1
   time = next.getTime()
  return time

 _lastTime: (Time) ->
  cur = new Date Time
  last = new Date cur.getFullYear(), cur.getMonth(), @date, @hour, @min
  time = last.getTime()
  if time > cur.getTime()
   last.setMonth last.getMonth() - 1
   time = last.getTime()
  return time

module.exports = (Types) ->
 Types.monthly = MonthlyScheduler

