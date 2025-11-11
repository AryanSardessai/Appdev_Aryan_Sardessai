plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.firebasecounterapp"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.firebasecounterapp"
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    // ✅ Add Compose support
    buildFeatures {
        compose = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.14"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    // ✅ Compose BOM (manages versions automatically)
    val composeBom = platform("androidx.compose:compose-bom:2024.10.00")

    implementation(composeBom)
    androidTestImplementation(composeBom)

    // ✅ Compose UI dependencies
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.compose.ui:ui:1.7.0")
    implementation("androidx.compose.material3:material3:1.3.0")
    implementation("androidx.activity:activity-compose:1.9.2")

    // Firebase Auth
    implementation("com.google.firebase:firebase-auth:23.1.0")
    implementation("com.google.android.gms:play-services-auth:21.2.0")

    // For Google Sign-In (Firebase Auth UI)
    implementation("androidx.credentials:credentials:1.3.0")
    implementation("androidx.credentials:credentials-play-services-auth:1.3.0")

    // Optional: Coroutines (for async calls)
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")

}
apply(plugin = "com.google.gms.google-services")
