import chalk from "chalk";
import { readFile, writeFile } from "fs";
import { readFileSync } from "fs";
const configFile = "./config.json";

function err(error, msg) {
  console.log(chalk.bgRed(error));
  console.log(chalk.red(msg));
  throw error;
}

function initializeSync() {
  readFileSync(configFile, (error, data) => {
    if (error) err(error, "failed to read config");
    const configs = JSON.parse(data);
    // on success then load the datafile
    readFileSync(configs.dataFile, (err, data) => {
      if (error) err(error, "Could not load data file");
      const doteListJson = JSON.parse(data);
      // return an object with the config object and DoTe data
      return {
        configs,
        doteListJson,
      };
    });
  });
}
// load the config file into memory
async function initialize() {
  let configs = {};
  let doteListJson = {};
  await readFile(configFile, async (error, data) => {
    if (error) err(error, "failed to read config");
    configs = JSON.parse(data);
    // on success then load the datafile
    await readFile(configs.dataFile, (err, data) => {
      if (error) err(error, "Could not load data file");
      doteListJson = JSON.parse(data);
      // return an object with the config object and DoTe data
    });
  });
  return {
    configs,
    doteListJson,
  };
}

// okay. So. If we just overwrite the file instead of modifying it, it's probably as performant until
// your todo list gets absurdly large. Might change later idk                   alsoitswayeasierforme
function writeDataFile(newData, configs) {
  writeFile(configs.dataFile, JSON.stringify(newData), "UTF8", (dat) => {
    console.log(dat);
  });
}
export { initialize, writeDataFile, initializeSync };
