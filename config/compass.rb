# Please, be careful when editing these settings, it may break the theme assets API push
project_path      = File.join(File.dirname(__FILE__), '..', 'public')
http_path         = '/'
css_dir           = '../tmp/stylesheets'
sass_dir          = 'stylesheets'
images_dir        = 'images'
javascripts_dir   = 'javascripts'
project_type      = :stand_alone
output_style      = :nested
line_comments     = false


# Load patches
# (We're just using the fact that this file is loaded by locomotive_editor at startup)

LocomotiveEditor::Logger.info '...loading patches'
require File.join(LocomotiveEditor.site_root, 'lib', 'editor_decorator', 'editor_decorator.rb')