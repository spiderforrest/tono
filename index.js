#!/usr/bin/env node
import chalk from "chalk";
import { ask } from "stdio";


console.log(chalk.blue.bgRed.bold(await ask("i'll echo anything but in blue lol")));
