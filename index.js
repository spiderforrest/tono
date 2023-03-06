#!/usr/bin/env node
import chalk from "chalk";
import { getopt } from "stdio";
import { readFile, writeFile } from "fs";
const configFile = "./config.json";

// load the config file into memory
let configs; // for scope i'm lazy and hate js
let doteListJson;
readFile(configFile, (err, data) => {
  if (err) {
    console.log(chalk.bgRed(err));
    console.log(chalk.red("Could not load config"));
    throw err;
  }
  configs = JSON.parse(data);
  // on success then load the datafile
  readFile(configs.dataFile, (err, data) => {
    if (err) {
      console.log(chalk.bgRed(err));
      console.log(chalk.red("Could not load data file"));
      throw err;
    }
    doteListJson = JSON.parse(data);
    // call the actual main processing bc i forgor that async was a hoe
    main();
  });
});

// manages cli args
const opt = getopt({
  _meta_: { minargs: 2 },
});

function main() {
  // handles what action will be taken
  switch (opt.args[0]) {
    case "a":
    case "add":
      // okay. So. If we just overwrite the file instead of modifying it, it's probably as performant until
      // your todo list gets absurdly large.                                          alsoitswayeasierforme

      // strip the first arg off since we've processed it already
      opt.args.shift();
      console.log(doteListJson);
      // temp hardcoding id
      doteListJson[0] = {
        // naively set the rest to names for now
        name: opt.args.join(" "),
      };
      writeFile(
        configs.dataFile,
        JSON.stringify(doteListJson),
        "UTF8",
        (dat) => {
          console.log(dat);
        }
      );
      break;
    case "x":
    case "done":
      console.log("done mode");
      break;
    case "r":
    case "remove":
    case "delete":
      console.log("remove mode");
      break;
    case "m":
    case "modify":
      console.log("modify mode");
      break;
    case "u":
    case "undo":
      console.log("undo mode");
      break;
    case "l":
    case "list":
      console.log("undo mode");
      break;

    default:
      break;
  }
}
