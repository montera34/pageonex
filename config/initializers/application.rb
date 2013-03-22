
# should we cache the kiosko image files locally, or just show them directly from kiosko's domain?
Pageonex::Application.config.use_local_images = false

# date format used by kiosko to name their newspaper frontpage image files
Date::DATE_FORMATS[:kiosko_file_datestamp]="%Y/%m/%d"
Time::DATE_FORMATS[:file_datestamp] = "%Y-%m-%d"