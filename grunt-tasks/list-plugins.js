var fn = function(){

  //Get list of plugins from .vimrc
  var jsdom = require('jsdom');
  var fs = require('fs');
  var https = require('follow-redirects').https;
  var Orgy = require('orgy');
  var deferreds = [];
  var contents = fs.readFileSync('./.vim/plugins.vim',{
    'encoding' : 'utf-8'
  });
  var jquery = fs.readFileSync("./grunt-tasks/libs/jquery.js", "utf-8");


  //Set all promises to timeout after 60 seconds
  Orgy.config({
    timeout : 120000
  });

  //var matches = contents.match( /NeoBundle '(.*?)'/g );
  var matches = contents.match( /Plug '(.*?)'/g );
  matches = matches.map(function(match){
    var arr = match.split(' ');
    var str = arr[1].replace(/'/g,'');
    return str;
  });

  //Sort 'em
 matches.sort(function (a, b) {
   return a.toLowerCase().localeCompare(b.toLowerCase());
 });

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
            src : [jquery], //read synchronously from local file
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
    var readme = fs.readFileSync("./.vim/README.md",{
      encoding : "utf-8"
    });

    r.unshift(['Name','Description','Website']);
    var plugins = mdtable(r);

    readme = readme.replace(/<!---PLUGINS-->((?:.|[\r\n])*)<!---ENDPLUGINS-->/m,
      '<!---PLUGINS-->\n'+plugins+'\n<!---ENDPLUGINS-->');

    fs.writeFileSync("./.vim/README.md",readme);
  });

  return queue;
};

module.exports = fn;
