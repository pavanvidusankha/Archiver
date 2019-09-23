Base = require './base'

DAY = 24 * 60 * 60 * 1000
WEEK = 7 * 24 * 60 * 60 * 1000
DAYS = [
 'sun'
 'mon'
 'tue'
 'wed'
 'thu'
 'fri'
 'sat'
]


class WeeklyScheduler extends Base
 @extend()

 _key: -> "#{@day}:#{@hour}:#{@min}"

 _parseOptions: ->
  @day = @opt.day
  if 'string' is typeof @day
   @day = @day.toLowerCase().trim()
   for d, i in DAYS
    if d is @day
     @day = i
     break
  @day = parseInt @day
  @hour = parseInt @opt.hour
  @min = parseInt @opt.minute
  if not @day? or isNaN @day
   throw new Error "Scheduler missing/invalid day value in scheduler #{@id}"
  if not @hour? or isNaN @hour
   throw new Error "Scheduler missing/invalid hour value in scheduler #{@id}"
  if not @min? or isNaN @min
   throw new Error "Scheduler missing/invalid minute value in scheduler #{@id}"
  @day = @day & 7
  @hour = @hour % 24
  @min = @min % 60

 _nextTime: (Time) ->
  cur = new Date Time
  dayAdd = (@day - cur.getDay() + 7) % 7
  next = new Date cur.getFullYear(), cur.getMonth(), cur.getDate(), @hour, @min
  time = next.getTime() + DAY * dayAdd
  if time <= cur.getTime()
   time += WEEK
  return time

 _lastTime: (Time) -> (@_nextTime Time) - WEEK

module.exports = (Types) ->
 Types.weekly = WeeklyScheduler

