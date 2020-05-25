const request = require("request");
const {promisify} = require('util')
const fs = require('fs')
const writeFile = promisify(fs.appendFile)

const URLS = require('./dateValidFailed.json')
const OUTPUT_FNAME = './test/withHTML.json'

const getHTML = (url) => new Promise((resolve, reject) => {
        request(url, (err, res, body) => err ? reject(err) : resolve(body))
    })

const htmlToFile = async () => {
    await writeFile(OUTPUT_FNAME,'[\n', 'utf8')    
    let delimiter = '';
    for await (const url of URLS) {
        try {
            let html = await getHTML(url)
            console.log(url)
            await writeFile(OUTPUT_FNAME,
                delimiter+
                JSON.stringify({
                    ...url,
                    html
                })
            , 'utf8')
            // console.log('google-index.html written.')
            delimiter = '\n,\n'
        } catch(err) {
            console.log(err)
        }
    }
    await writeFile(OUTPUT_FNAME,'\n]', 'utf8')    

}


suite('Extractor', function() {

    test('download urls HTML', function() {
        htmlToFile()
        return eq(1,1);
      });

});
