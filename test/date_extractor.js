import extractor from "../src/extractor";
import cheerio from "cheerio";
const fs = require("fs");
const spawn = require("child_process").spawn;
import pythonBridge from 'python-bridge';

import PythonAdapter from './bridge';
const python = new PythonAdapter()

const HTML = require("./withHTML.json");
const { promisify } = require("util");
const writeFile = promisify(fs.appendFile);
const OUTPUT_FNAME = "./test/withDate.json";

const getPythonDate = (url) =>
  new Promise((resolve, reject) => {
    spawn('htmldate',["-u", url]).stdout.on('data', (data) => {
        resolve(data.toString().replace('\n',''))
    })
    setTimeout(() => reject("timeOuted"), 20000);
  });


const python = new PythonAdapter()

const main = async function () {
  await writeFile(OUTPUT_FNAME, "[\n", "utf8");

  let delimiter = "";

  for await (const record of HTML) {
    try {
      const doc = cheerio.load(record.html);
      const date = extractor.date(doc);
      // const pythondate = await getPythonDate(record.html);

      const jsonRecord = {
        date,
        // pythondate,
        url: record.url,
      };
      console.log(jsonRecord);
      await writeFile(
        OUTPUT_FNAME,
        delimiter + JSON.stringify(jsonRecord),
        "utf8"
      );

      delimiter = "\n,\n";
    } catch (err) {
      console.log(err);
    }
  }
  await writeFile(OUTPUT_FNAME, "\n]", "utf8");
};


// main().then(() => console.log("main done"));

const foo = async () => {

  python.testFun(4,2).then(x=>console.log(x));

  const htmldoc = '<html><body><span class="entry-date">July 12th, 2016</span></body></html>'
  await python.find_date(htmldoc).then(x=>console.log(x));
}


foo().then(() => console.log("main done"));
// main().then(() => console.log("main done"));



