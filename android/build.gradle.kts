allprojects {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        maven { url = uri("https://maven.transistorsoft.com/repository/background-fetch") }
    }
}

rootProject.buildDir = file("../build")

subprojects {
    buildDir = file("${rootProject.buildDir}/${project.name}")
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
