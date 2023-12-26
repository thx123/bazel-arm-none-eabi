"""
This module provides functions to register an arm-none-eabi toolchain
"""

load("@arm_none_eabi//toolchain:config.bzl", "cc_arm_none_eabi_config")

compatible_cpus = {
    "arm": "@platforms//cpu:arm",
    "armv6-m": "@platforms//cpu:armv6-m",
    "armv7-m": "@platforms//cpu:armv7-m",
    "armv7e-m": "@platforms//cpu:armv7e-m",
    "armv7e-mf": "@platforms//cpu:armv7e-mf",
    "armv8-m": "@platforms//cpu:armv8-m",
}

hosts = {
    "darwin_x86_64": ["@platforms//os:macos"],  # Also runs on apple silicon
    "linux_x86_64": ["@platforms//os:linux", "@platforms//cpu:x86_64"],
    "linux_aarch64": ["@platforms//os:linux", "@platforms//cpu:arm64"],
    "windows_x86_64": ["@platforms//os:windows", "@platforms//cpu:x86_64"],
}

def arm_none_eabi_toolchain(name, target_compatible_with = [], copts = [], linkopts = [], version = "9.2.1"):
    """
    Create an arm-none-eabi toolchain with the given configuration.

    Args:
        name: The name of the toolchain.
        target_compatible_with: A list of constraint values to apply to the toolchain.
        copts: A list of compiler options to apply to the toolchain.
        linkopts: A list of linker options to apply to the toolchain.
        version: The version of the gcc toolchain.
    """

    for host, exec_compatible_with in hosts.items():
        cc_arm_none_eabi_config(
            name = "config_{}_{}".format(host, name),
            gcc_repo = "arm_none_eabi_{}".format(host),
            gcc_version = version,
            host_system_name = host,
            toolchain_identifier = "arm_none_eabi_{}_{}".format(host, name),
            toolchain_bins = "@arm_none_eabi_{}//:compiler_components".format(host),
            include_path = [
                "@arm_none_eabi_{}//:arm-none-eabi/include".format(host),
                "@arm_none_eabi_{}//:lib/gcc/arm-none-eabi/{}/include".format(host, version),
                "@arm_none_eabi_{}//:lib/gcc/arm-none-eabi/{}/include-fixed".format(host, version),
                "@arm_none_eabi_{}//:arm-none-eabi/include/c++/{}".format(host, version),
                "@arm_none_eabi_{}//:arm-none-eabi/include/c++/{}/arm-none-eabi".format(host, version),
            ],
            library_path = [
                "@arm_none_eabi_{}//:arm-none-eabi/lib".format(host),
                "@arm_none_eabi_{}//:lib/gcc/arm-none-eabi/{}".format(host, version),
            ],
            copts = copts,
            linkopts = linkopts,
        )

        native.cc_toolchain(
            name = "cc_toolchain_{}_{}".format(host, name),
            all_files = "@arm_none_eabi_{}//:compiler_pieces".format(host),
            ar_files = "@arm_none_eabi_{}//:ar_files".format(host),
            compiler_files = "@arm_none_eabi_{}//:compiler_files".format(host),
            dwp_files = ":empty",
            linker_files = "@arm_none_eabi_{}//:linker_files".format(host),
            objcopy_files = "@arm_none_eabi_{}//:objcopy".format(host),
            strip_files = "@arm_none_eabi_{}//:strip".format(host),
            supports_param_files = 0,
            toolchain_config = ":config_{}_{}".format(host, name),
            toolchain_identifier = "arm_none_eabi_{}_{}".format(host, name),
        )

        native.toolchain(
            name = "{}_{}".format(name, host),
            exec_compatible_with = exec_compatible_with,
            target_compatible_with = target_compatible_with,
            toolchain = ":cc_toolchain_{}_{}".format(host, name),
            toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
        )

def register_arm_none_eabi_toolchain(name):
    for host in hosts:
        # print("debug: registering toolchain for name: () and host: {}".format(name, host))
        native.register_toolchains("{}_{}".format(name, host))
