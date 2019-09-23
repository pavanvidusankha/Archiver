var resources = require("./resources.js");
var fs = require("fs");
const path = require("path");
var rimraf = require("rimraf");

class methods {
	process(obj, archiveDir, tempDir) {
		let dir = obj.inputDir;
		let format = obj.fileNameFormat; //set date format
		let compressKeep = obj.compressKeep; //wanted days to keep records
		let delKeep=obj.deleteKeep;
		let oId = obj.id;
		let method = obj.opMethod;

		//cleaning the temp directory
		this.clean_temp(tempDir);
		/* "c"- compress "m"- compress & delete "d"-delete */
		switch (method) {
			case "compress":
				this.validatefiles(dir, tempDir, format, compressKeep, "m");
				resources.compress(archiveDir, tempDir, oId, format);
				this.clean_temp(tempDir);
				break;

			case "compress_del":
				let comp_dir=path.resolve(archiveDir+"/"+oId);
				this.validatefiles(dir, tempDir, format, compressKeep, "m");
				resources.compress(archiveDir, tempDir, oId, format);
				this.delete_compressed(comp_dir,delKeep);
				this.clean_temp(tempDir);
				break;
			case "delete":
				this.validatefiles(dir, tempDir, format, compressKeep, "d");
				break;

			default:
				console.log("Invalid method");
		}
	}

	validatefiles(dir, tempDir, format, kdays, status) {
		function traverseDir(dir, kdays) {
			fs.readdirSync(dir).forEach(file => {
				let source = path.join(dir, file);
				if (format == "epoch") {
					if (fs.lstatSync(source).isDirectory()) {
						traverseDir(source, kdays);
					} else {
						let subd = file.substring(0, file.lastIndexOf("-"));
						let dest = path.resolve(tempDir + "/" + subd + "/" + file);
						if (resources.validate(file, format, kdays)) {
							resources.executeFile(source, dest, status);
						}
					}
				} else if (format == "date" || format == "datetime") {
					let dest = path.resolve(tempDir + "/" + file);
					if (resources.validate(file, format, kdays)) {
						resources.executeFile(source, dest, status);
					}
				}
			});
		}
		traverseDir(dir, kdays);
	}

	delete_compressed(comp_dir, delKeep) {
		fs.readdirSync(comp_dir).forEach(file => {
			let fullPath = path.join(comp_dir, file + "/");
			if (fs.lstatSync(fullPath).isDirectory()) {
				if (resources.validate(file, "date", delKeep)) {
					resources.executeFile(fullPath, null, "d");
				}
			}
		});
	}

	//clean the temp folder
	clean_temp(dir) {
		rimraf.sync(path.resolve(dir + "*"));
		console.log("cleaned temp folder");
	}
}
module.exports = methods;
