#!/usr/bin/env node
import chalk from "chalk";
import { ask, getopt } from "stdio";

const args = getopt({
  tmp: { key: "n", args: 1, required: false },
  _meta_: { minargs: 0 },
});

console.log(args);

console.log(
  chalk.blue.bgRed.bold(await ask("i'll echo anything but in blue lol"))
);
