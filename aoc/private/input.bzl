"""stuff"""

COUNT_DAYS = {
    2025: 12,
    2024: 25,
    2023: 25,
}

input_url_base = "https://adventofcode.com/{0}/day/{1}/input"

_SAMPLE_ROOT = Label("//aoc/private/sample_input:BUILD.bazel")

def _sample_files(day_dir):
    if not day_dir.exists:
        return []
    return sorted([
        f.basename
        for f in day_dir.readdir()
        if f.basename.startswith("sample") and f.basename.endswith(".txt")
    ])

def _year_repo_impl(rctx):
    year_counts = []
    if len(rctx.attr.use_years) > 0:
        year_counts = [(year, days) for year, days in COUNT_DAYS.items() if year in rctx.attr.use_years]
    else:
        year_counts = COUNT_DAYS.items()
    sample_root = rctx.path(_SAMPLE_ROOT).dirname
    rctx.watch_tree(sample_root)
    for year, day_count in year_counts:
        year_dir = sample_root.get_child(str(year))
        for day in range(1, day_count + 1):
            path = "{0}/day{1}".format(year, day)
            day_dir = year_dir.get_child("day{0}".format(day))

            build = [
                'package(default_visibility = ["//visibility:public"])',
                'filegroup(name = "input", srcs = ["input.txt"])',
            ]
            for filename in _sample_files(day_dir):
                rctx.symlink(day_dir.get_child(filename), "{0}/{1}".format(path, filename))
                build.append(
                    'filegroup(name = "{0}", srcs = ["{1}"])'.format(
                        filename.removesuffix(".txt"),
                        filename,
                    ),
                )
            rctx.file("{0}/BUILD.bazel".format(path), "\n".join(build) + "\n")

            rctx.download(
                url = input_url_base.format(year, day),
                headers = {"Cookie": rctx.attr.auth[:-1]},
                output = "{0}/input.txt".format(path),
            )

input_repo = repository_rule(
    attrs = {
        "auth": attr.string(
            mandatory = True,
        ),
        "use_years": attr.int_list(
            doc = "only use specific years",
            default = [],
        ),
    },
    implementation = _year_repo_impl,
)
