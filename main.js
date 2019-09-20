//intializing the directories
var yaml = require("js-yaml");
var fs = require("fs");
const cron = require("node-cron");
const Methods = require("./methods.js");
const methods = new Methods();
//scanning the yaml file
const doc = yaml.load(fs.readFileSync("archiver.yaml"));
//initializing the directory folders

function archiever(doc) {
	var tempDir = doc.tempDir;
	var ArchiveDir = doc.archiveDir;

	var array = [
		/* to store the chains of the YAML Doc*/
	];
	for (let j = 0; j < doc.chains.length; j++) {
		array.push(doc.chains[j]);
	}
	array.forEach(e => {
		// var schedule_type = e.schedule.type;
		var schedule_hour = e.schedule.options.hour;
		var schedule_minute = e.schedule.options.minute;
		cron.schedule(
			"0 " + schedule_minute + " " + schedule_hour + " * * *",
			() => {
				console.log( e.id+" tasks started ");
				for (let i = 0; i < e.folders.length; i++) {
					console.log(e.folders[i].id+" task started");
					methods.process(e.folders[i], ArchiveDir, tempDir);
					console.log(e.folders[i].id+" task finished");
				}
				console.log(e.id +" tasks completed")
			},
			{
				scheduled: true
			}
		);
	});
}
//calling the main method
archiever(doc);
