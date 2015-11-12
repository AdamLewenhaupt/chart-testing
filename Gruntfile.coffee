module.exports = (grunt) ->

    grunt.initConfig
        pkg: grunt.file.readJSON('package.json')
        coffeeMap: 
            compile:
                expand: true
                flatten: true
                cwd: 'src'
                src: ['*.coffee']
                dest: 'lib/'
                ext: '.js'

        coffee:
            compile:
                options:
                    join: true
                    bare: true

                files:
                    'lib/main.js': ['./src/graph-helpers.coffee', './src/main.coffee', './src/result.coffee']


        sass:
            dist:
                files: 
                    './lib/main.css': './style/main.scss'

    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-sass'
    
    grunt.registerTask('default', ['coffee', 'sass'])
