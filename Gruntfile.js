/**
 * To debug gruntfile:
 * node-debug $(which grunt) task
 */

module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
  });

  grunt.registerTask('list-plugins', '', function() {
    var done = this.async();
    var list_plugins = require('./grunt-tasks/list-plugins.js');
    var promise = list_plugins();
    promise.done(function(){
      console.log("Motherfucker done.");
      done();
    });
  });

  grunt.registerTask('default', [
    'list-plugins'
  ]);
};
