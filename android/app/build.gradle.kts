plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.snake"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
}
android {
        ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Uygulama ID'nizi belirleyin (örneğin, "com.example.snake")
        applicationId = "com.example.snake"
        // Flutter'dan gelen değerleri kullanmaya devam edin
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Yayınlama için özel imzalama ayarlarını buraya ekleyin
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."  // Flutter kaynağının yolu (proje kök dizini)
}
