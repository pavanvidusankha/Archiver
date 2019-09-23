'use strict'
#intializing the directories
yaml = require('js-yaml')
fs = require('fs')
#const scheduler=require("scheduler");
methods = require('./methods')

#scanning the yaml file
doc = yaml.load(fs.readFileSync('archiver.yaml'))
Scheduler = require './scheduler'
debugger
Scheduler = new Scheduler +5.5, './', 5000


Scheduler.addEvent 'event_daily',
	{
		type: 'daily'
		options:
			hour:doc.ScheduledHour
			minute:doc.ScheduledMinute
	}
	->
		Archiver doc

Archiver = (doc) ->
  archiveDir = doc.archiveDir
  tempDir = doc.tempDir
  i = 0
  for i in [0..doc.folders.length-1]
    console.log doc.folders[i].id + ' Task Started'
    methods.process doc.folders[i], archiveDir, tempDir
    console.log 'Task Completed'
    i++
  return


Scheduler.start()


