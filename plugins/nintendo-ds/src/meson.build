vala_sources = [
  'nintendo-ds-icon.vala',
  'nintendo-ds-plugin.vala',
]

c_sources = [
  'nintendo-ds-icon-extract.c',
]

c_args = [
  '-DG_LOG_DOMAIN="GamesNintendoDS"'
]

shared_module (
  'games-' + plugin_name + '-plugin',
  vala_sources + c_sources,
  dependencies: gnome_games_dep,
  c_args: c_args,
  install: true,
  install_dir: plugins_dir
)
