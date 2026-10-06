plugins {

  // ...


  // Add the dependency for the Google services Gradle plugin

  id("com.google.gms.google-services") version "4.5.0" apply false

}
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

subprojects {
    if (project.name != "app") {
        val configureSdk = {
            val android = project.extensions.findByName("android")
            if (android != null) {
                try {
                    val setCompileSdk = android.javaClass.getMethod("setCompileSdk", java.lang.Integer::class.java)
                    setCompileSdk.invoke(android, 36)
                } catch (_: Exception) {
                    try {
                        val compileSdkVersion = android.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                        compileSdkVersion.invoke(android, 36)
                    } catch (_: Exception) {}
                }
            }
        }
        if (project.state.executed) {
            configureSdk()
        } else {
            project.afterEvaluate { configureSdk() }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
