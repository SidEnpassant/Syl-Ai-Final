plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter Gradle Plugin
}

android {
    namespace = "com.example.sylai2"
    compileSdk = 35 // ✅ Fix: Update to match plugin requirements

    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true // ✅ Enabled
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.sylai2"
        minSdk = 21 // ✅ Minimum SDK for MultiDex
        targetSdk = 35 // ✅ Updated to match compileSdk
        versionCode = 1
        versionName = "1.0"

        multiDexEnabled = true // ✅ Correct Kotlin DSL syntax
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Fix: Add missing core library desugaring dependency
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")

    // ✅ Required for MultiDex
    implementation("androidx.multidex:multidex:2.0.1")
}