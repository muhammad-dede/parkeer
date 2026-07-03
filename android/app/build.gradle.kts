plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.parkeer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.parkeer"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        ndk {
            abiFilters.addAll(setOf("armeabi-v7a", "arm64-v8a", "x86_64"))
        }
    }

    signingConfigs {
        getByName("debug") {
            // Konfigurasi debug bawaan Flutter biasanya sudah otomatis ada di sini
        }
        
        // JIKA Anda ingin membuat konfigurasi release tiruan agar tidak error:
        create("release") {
            // Untuk sementara, kita gunakan keystore debug bawaan Flutter agar bisa di-build
            val debugConfig = getByName("debug")
            storeFile = debugConfig.storeFile
            storePassword = debugConfig.storePassword
            keyAlias = debugConfig.keyAlias
            keyPassword = debugConfig.keyPassword
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
        getByName("release") {
            // Mengaktifkan pengecilan kode (minify)
            isMinifyEnabled = true
            // Mengaktifkan penghapusan resource yang tidak digunakan
            isShrinkResources = true 
            
            // Cara memanggil file proguard-rules.pro di Kotlin DSL
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // Pastikan signingConfig Anda sudah benar untuk mode release
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
