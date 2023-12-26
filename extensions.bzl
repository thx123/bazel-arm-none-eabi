load("@arm_none_eabi//:deps.bzl", "arm_none_eabi_deps")

def _arm_none_eabi_impl(ctx):
    for mod in ctx.modules:
        # Avoiding duplicate repo generations from outside the module
        if mod.name != "arm_none_eabi":
            continue
        for attr in mod.tags.toolchain:
            arm_none_eabi_deps(attr.version)

_toolchain = tag_class(attrs = {
    "version": attr.string(),
})

arm_none_eabi_extension = module_extension(
    implementation = _arm_none_eabi_impl,
    tag_classes = {
        "toolchain": _toolchain,
    },
)
