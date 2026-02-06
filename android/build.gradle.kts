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
    afterEvaluate {
        if (name == "isar_flutter_libs") {
            try {
                val android = extensions.findByName("android")
                if (android != null) {
                    val getNamespace = android.javaClass.getMethod("getNamespace")
                    val currentNamespace = getNamespace.invoke(android)
                    if (currentNamespace == null) {
                        val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                        setNamespace.invoke(android, "dev.isar.isar_flutter_libs")
                        println("Injected namespace for isar_flutter_libs")
                    }
                }
            } catch (e: Exception) {
                println("Failed to inject namespace for isar_flutter_libs: ${e.message}")
            }
        }
    }
}
subprojects {
    afterEvaluate {
        if (plugins.hasPlugin("com.android.library")) {
            extensions.configure<com.android.build.gradle.LibraryExtension> {
                compileSdk = 35
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}



tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
