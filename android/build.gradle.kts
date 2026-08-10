allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// AGP 9 dropped the need to apply the Kotlin plugin by hand, but
// mapbox_maps_flutter's build script still configures the `kotlin { }`
// extension that plugin registers, and fails evaluating without it.
// Applying it for that one module keeps the plugin buildable without
// pinning this app back to AGP 8.
subprojects {
    if (name == "mapbox_maps_flutter") {
        apply(plugin = "org.jetbrains.kotlin.android")
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
