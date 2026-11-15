load("//aoc:defs.bzl", "input_repo")

input_hub = tag_class(
    attrs = {
        "cookie_file": attr.label(
            mandatory = True,
        ),
        "hub_name": attr.string(
            default = "aoc_files",
        ),
        "use_years": attr.int_list(
            doc = "only use specific years",
        ),
    },
)

def _aoc_puzzle_input_impl(module_ctx):
    hub_names = []
    for mod in module_ctx.modules:
        for hub in mod.tags.input_hub:
            hub_name = hub.hub_name
            hub_names.append(hub_name)
            aoc_cookie = module_ctx.read(hub.cookie_file)
            input_repo(name = hub_name, auth = aoc_cookie, use_years = hub.use_years)

    return module_ctx.extension_metadata(
        root_module_direct_deps = hub_names,
        root_module_direct_dev_deps = [],
        reproducible = True,  # repo state is only a function of the lockfile
    )

aoc_puzzle_input = module_extension(
    implementation = _aoc_puzzle_input_impl,
    tag_classes = {"input_hub": input_hub},
)
