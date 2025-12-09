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
    project.evaluationDependsOn(":app")
    buildDir = file("${rootProject.buildDir}/${project.name}")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
