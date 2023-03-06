#!/usr/bin/env node
import { getopt } from "stdio";
import { initialize, writeDataFile } from "./lib/io.js";

// manages cli args
const opt = getopt({
  _meta_: { minargs: 2 },
});

async function main() {
  const { configs, doteListJson } = await initialize();
  // handles what action will be taken
  switch (opt.args[0]) {
    case "a":
    case "add":
      // strip the first arg off since we've processed it already
      opt.args.shift();
      console.log(doteListJson);
      // temp hardcoding id
      doteListJson[0] = {
        // naively set the rest to names for now
        name: opt.args.join(" "),
      };
      // call the write function
      writeDataFile(doteListJson, configs);
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
main();
