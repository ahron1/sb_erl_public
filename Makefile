PROJECT = es
PROJECT_DESCRIPTION = New project
PROJECT_VERSION = 0.1.0

DEPS = cowboy pgo jsx shotgun fcm
dep_pgo_commit = v0.11.0
dep_cowboy_commit = 2.9.0

BUILD_DEPS = reload_mk

DEP_PLUGINS = cowboy reload_mk pgo jsx shotgun fcm

include erlang.mk
