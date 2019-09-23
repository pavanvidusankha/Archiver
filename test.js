

function Archiever(doc){
	let archiveDir=doc.archiveDir;
	let tempDir=doc.tempDir;
	for(let i=0;i<doc.folders.length;i++){
	console.log(doc.folders[i].id+" Task Started");
	methods.process (e.folders[i],archiveDir,tempDir);
}
}
let scheduled_hour=doc.scheduledTime.hour;
let scheduled_minute=doc.scheduledTime.minute;
