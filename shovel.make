; Core version
; ------------

core = 7.x

; API version
; ------------

api = 2

; Core project
; ------------

projects[drupal][version] = 7.7
; Keep our .htaccess and robots.txtfiles customized even after updating
projects[drupal][patch][] = "https://raw.github.com/gist/1131120/6fffe6f21643e1b0eaab0a245cb28070a26380c6/htaccess-robots-custom-d7.patch"

; Installation Profile
; --------------------

projects[dirt][type] = profile
projects[dirt][download][type] = git
projects[dirt][download][url] = git://github.com/orangecoat/dirt.git
