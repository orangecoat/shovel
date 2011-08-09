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
projects[drupal][patch][] = "https://raw.github.com/gist/1131120/0b4e69fd39ddfafd4b56619065a7e03e9fc027fb/htaccess-robots-custom-d7.patch"

; Installation Profile
; --------------------

projects[dirt][type] = profile
projects[dirt][download][type] = git
projects[dirt][download][url] = git://github.com/orangecoat/dirt.git
