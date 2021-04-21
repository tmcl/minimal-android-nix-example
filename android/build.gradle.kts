// Top-level build file where you can add configuration options common to all sub-projects/modules.
buildscript {
    val kotlin_version by extra ( "1.4.32" )
    val nixMavenRepo = project.findProperty("nixMavenRepo")
    if(nixMavenRepo != null) {
      repositories {
          maven(nixMavenRepo)
      }
    } else {
      repositories {
          google()
          mavenCentral()
      }
    }

    dependencies {
        classpath ("com.android.tools.build:gradle:4.1.3")
        classpath ("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")

        // NOTE: Do not place your application dependencies here; they belong
        // in the individual module build.gradle files
    }
}

allprojects {
    val nixMavenRepo = project.findProperty("nixMavenRepo")
    if(nixMavenRepo != null) {
      repositories {
          maven(nixMavenRepo)
      }
    } else {
      repositories {
          google()
          mavenCentral()
      }
    }
}

/*
task clean(type: Delete) {
    delete rootProject.buildDir
}
*/
