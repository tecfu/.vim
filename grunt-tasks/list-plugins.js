  //Get list of plugins from .vimrc
  const jsdom = require('jsdom');
  const fs = require('fs');
  const https = require('follow-redirects').https;
  const Orgy = require('orgy');
  const deferreds = [];
  const pluginsFile = `${__dirname}/../plugins.vim`
  const readmeFile = `${__dirname}/../README.md`
  const contents = fs.readFileSync(pluginsFile, {
    'encoding' : 'utf-8'
  });
  const jqueryStr = fs.readFileSync(`${__dirname}/../grunt-tasks/libs/jquery.js`, "utf-8");


  //Set all promises to timeout after 60 seconds
  Orgy.config({
    timeout : 120000
  });

  const pluginsFileArray = contents.split('\n')
  const matches = pluginsFileArray
    .filter( line => {
      return line.match(/^Plug '(.*?)'/)
    })
    .map( line => {
      return line
        .match(/^Plug '(.*?)'/)[1]
        .replace(/'/g,'')
    })
    .sort((a, b) => {
      return a.toLowerCase().localeCompare(b.toLowerCase())
    })

  //Visit the github page of each plugin and save its description
  for(var i in matches){

    (function(){
      var match = matches[i];

      //Create a deferred for the request.
      var deferred = Orgy.deferred();
      deferreds.push(deferred);

      var options = {
        host: 'github.com',
        port: 443,
        path: '/'+match,
        method: 'GET'
      };

      var req = https.request(options, function(res) {

        var str = '';
        res.on('data', function(d) {
          //process.stdout.write(d);
          str += d;
        });

        res.on('end', function () {

          jsdom.env({
            html : str,
            src : [jqueryStr], //read synchronously from local file
            done : function (errors, window) {
              
              var githubWs = 'http://github.com/'+match;

              //Use jQuery to get data we want
              var arr = [];
              arr.push('<a href="'+githubWs+'">'+match+'</a>');
              arr.push(window
                      .$('span[itemprop="about"]')
                      .text()
                      .trim());
                    
              //If no website use github website
              var website = window
                      .$('div.repository-website')
                      .text()
                      .trim();
              if(website.length < 1){
                website = githubWs; 
              }
              arr.push(website);
              deferred.resolve(arr);
            }
          });
        });
      });
      req.end();

      req.on('error', function(e) {
        console.error('ERROR @ '+options.host + options.path);  
        console.error(e);
        deferred.reject(e);
      });
    }());
  }

  //Put the results in README.md
  var queue = Orgy.queue(deferreds);
  queue.then(function(r){

    var mdtable = require('markdown-table');

    //Get README
    var readme = fs.readFileSync(readmeFile, {
      encoding : "utf-8"
    });

    r.unshift(['Name','Description','Website']);
    var plugins = mdtable(r);

    readmeContent = readme.replace(/<!---PLUGINS-->((?:.|[\r\n])*)<!---ENDPLUGINS-->/m,
      '<!---PLUGINS-->\n'+plugins+'\n<!---ENDPLUGINS-->');

    fs.writeFileSync(readmeFile, readmeContent);
  });

  return queue;
