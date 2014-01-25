var sys = require('sys')
var exec = require('child_process').exec;

var gulp = require('gulp');
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');

var coreScripts = ['./compiled/events.js',
                   './compiled/editor.js'];
var pluginsScripts = ['./compiled/plugins/base.js',
                      './compiled/plugins/links.js',
                      './compiled/plugins/text.js'];

gulp.task('default', function () {
    exec('coffee -b -o compiled/ -c src/', function (error, stdout, stderr) {
        if (error) {
            sys.puts(stderr);
            process.exit(1);
        } else {
            gulp.src(coreScripts)
                .pipe(concat('editor-core.min.js'))
                .pipe(uglify())
                .pipe(gulp.dest('./dist'));
            gulp.src(pluginsScripts)
                .pipe(concat('editor-plugins.min.js'))
                .pipe(uglify())
                .pipe(gulp.dest('./dist'));
        }
    });
});
