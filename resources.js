//intializing the node dependencies
var fs = require("fs");
const path = require("path");
var dateFormat = require("dateformat");
var exec = require("child_process").execSync;
var fs1 = require("fs-extra");
var date = new Date();

module.exports = {
	//check and validate the epoch value of processed file ex-(bsad-1256557335.jsonl)
	checkname(fname) {
		let pfname = parseFloat(
			fname.substring(fname.lastIndexOf("-") + 1, fname.indexOf("."))
		);
		return pfname;
	},
	//set datetime values into epoch
	setDtToEpoch(xc) {
		var st = xc.substr(xc.indexOf("-") + 1, 19);
		var re = /_/gi;
		var news = st.replace(re, "-");
		const d = news.split("-");
		const epoch = new Date(d[0], d[1] - 1, d[2], d[3], d[4], d[5]).valueOf();
		return epoch;
	},
	//set folder/file date values into date format
	dateconvert(file) {
		var fDate = file.substr(0, 10);

		var pdate = new Date(fDate);
		return pdate;
	},
	//compress the directory
	compress(archiveDir, tempDir, oId, format) {
		var odirectory = path.resolve(
			archiveDir + oId + "/" + this.GetFormattedDate()
		);
		//ensure the directory is exists,otherwise create the directory
		fs1.ensureDirSync(odirectory);

		let source, dest;

		if (format == "epoch") {
			fs.readdirSync(tempDir).forEach(file => {
				let fullPath = path.join(tempDir, file + "/");
				if (fs.lstatSync(fullPath).isDirectory()) {
					dest = path.resolve(
						odirectory + "/" + file + "-" + date.getTime() + ".tar.gz"
					);
					source = path.resolve(fullPath + " .");
					shell_compress(dest, source);
				}
			});
		} else if (format == "date" || format == "datetime") {
			dest = path.resolve(
				odirectory + "/" + oId + "-" + date.getTime() + ".tar.gz"
			);
			source = path.resolve(tempDir + " .");
			shell_compress(dest, source);
		}

		function shell_compress(dest, source) {
			exec("tar -cvzf " + dest + " -C " + source, (err, stdout, stderr) => {
				console.log("Compressed ");
			});
		}
	},
	//calculate the pre date epoch value which is need to keep the records
	epochval(keep) {
		var date = new Date();

		date.setDate(date.getDate() - keep);
		var preEP = date.getTime();
		return preEP;
	},

	//get the date in a predefined format
	GetFormattedDate() {
		var todayTime = new Date();
		return dateFormat(todayTime, "yyyy-mm-dd");
	},
	//validate the file by considering format and kdays
	validate(file, format, kdays) {
		let kDate, fileDate;
		if (format == "epoch") {
			kDate = this.epochval(kdays);
			fileDate = this.checkname(file);
		}

		if (format == "datetime") {
			kDate = this.epochval(kdays);
			fileDate = this.setDtToEpoch(file);
		}
		if (format == "date") {
			fileDate = this.dateconvert(file);
			var tDate = new Date();

			//Change it so that it is the days in the past.
			var pastDate = tDate.getDate() - kdays;
			kDate = tDate.setDate(pastDate);
		}

		if (fileDate < kDate) return true;
		else return false;
	},
	//execute the I/O function specified
	executeFile(source, dest, status) {
		if (status == "c") {
			fs1.copySync(source, dest);
			console.log("copying file " + dest);
		} else if (status == "m") {
			fs1.moveSync(source, dest, { overwrite: true });
			console.log("moving file " + dest);
		} else if (status == "d") {
			fs1.removeSync(source);
			console.log("deleting file " + source);
		}
	}
};
