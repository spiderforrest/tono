#!/usr/bin/env node
import chalk from "chalk";
import { getopt } from "stdio";

const opt = getopt({
  _meta_: { minargs: 2 },
});
switch (opt.args[0]) {
  case "a":
  case "add":
    console.log("add mode");
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
