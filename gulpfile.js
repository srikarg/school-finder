var gulp = require('gulp');
var plugins = require('gulp-load-plugins')();
plugins.connect = require('gulp-connect');
plugins.jshint = require('gulp-jshint');

var port = 4000;

gulp.task('styles', function() {
    return gulp.src('sass/main.scss')
        .pipe(plugins.rubySass({ style: 'compressed' }))
        .pipe(plugins.autoprefixer('last 15 version'))
        .pipe(plugins.rename({ suffix: '.min' }))
        .pipe(gulp.dest('css'))
        .pipe(plugins.connect.reload());
        // .pipe(plugins.notify({ message: 'Styles task complete.' }));
});

gulp.task('scripts', function() {
    return gulp.src('coffee/**/*.coffee')
        .pipe(plugins.coffee())
        .pipe(plugins.concat('main.js'))
        .pipe(plugins.jshint.reporter('default'))
        .pipe(plugins.rename({ suffix: '.min' }))
        .pipe(plugins.uglify())
        .pipe(gulp.dest('js'))
        .pipe(plugins.connect.reload());
        // .pipe(plugins.notify({ message: 'Scripts task complete.' }));
});

gulp.task('clean', function() {
    return gulp.src(['css', 'js'], {read: false})
        .pipe(plugins.clean());
        // .pipe(plugins.notify({ message: 'Clean task complete.' }));
});

gulp.task('connect', function() {
    plugins.connect.server({
        port: port,
        livereload: true
    });
});

gulp.task('open', function() {
    var options = {
        url: 'http://localhost:' + port
    };
    gulp.src('./index.html')
        .pipe(plugins.open('', options));
});

gulp.task('html', function() {
    gulp.src('index.html')
        .pipe(plugins.connect.reload());
});

gulp.task('watch', function() {
    gulp.watch('index.html', ['html']);
    gulp.watch(['sass/main.scss', 'sass/partials/*.scss'], ['styles']);
    gulp.watch('coffee/**/*.coffee', ['scripts']);
});

gulp.task('default', ['clean', 'styles', 'scripts', 'connect', 'open', 'watch']);
