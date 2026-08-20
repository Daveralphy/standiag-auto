plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.standiagauto.standiag_auto"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.standiagauto.standiag_auto"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // agora_rtc_engine ships its native SDK as one "full" package covering
    // audio, video, and every optional AI/vision extension — regardless of
    // which of those a given app actually uses. This app only ever calls
    // engine.enableAudio() (see call_engine_service.dart; voice calls only,
    // no video, no beauty/noise-suppression/vision features), so the video
    // codec and AI/vision extension .so files below are dead weight Agora's
    // own docs list as safe to strip per-app: the SDK loads each extension
    // dynamically only if the app's code asks for it, so removing a .so
    // for a feature this app never calls just means that dlopen never
    // happens, not a crash. This alone was ~50MB of dead weight per ABI.
    packaging {
        jniLibs {
            excludes += setOf(
                "**/libagora_clear_vision_extension.so",
                "**/libagora_lip_sync_extension.so",
                "**/libagora_spatial_audio_extension.so",
                "**/libagora_ai_noise_suppression_extension.so",
                "**/libagora_ai_noise_suppression_ll_extension.so",
                "**/libagora_segmentation_extension.so",
                "**/libagora_face_capture_extension.so",
                "**/libagora_face_detection_extension.so",
                "**/libagora_ai_echo_cancellation_extension.so",
                "**/libagora_ai_echo_cancellation_ll_extension.so",
                "**/libagora_audio_beauty_extension.so",
                "**/libagora_content_inspect_extension.so",
                "**/libagora_video_av1_encoder_extension.so",
                "**/libagora_video_quality_analyzer_extension.so",
                "**/libagora_video_encoder_extension.so",
                "**/libagora_screen_capture_extension.so",
                "**/libvideo_enc.so",
                "**/libvideo_dec.so",
                "**/libiris_rendering_android.so",
                "**/libagora_ffmpeg.so",
            )
        }
    }
}

flutter {
    source = "../.."
}