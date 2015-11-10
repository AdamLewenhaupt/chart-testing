module.exports = (grunt) ->

    grunt.initConfig
        pkg: grunt.file.readJSON('package.json')
        coffee: 
            compile:
                expand: true
                flatten: true
                cwd: 'src'
                src: ['*.coffee']
                dest: 'lib/'
                ext: '.js'

        sass:
            dist:
                files: 
                    './lib/main.css': './style/main.scss'

    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-sass'
    
    grunt.registerTask('default', ['coffee', 'sass'])
