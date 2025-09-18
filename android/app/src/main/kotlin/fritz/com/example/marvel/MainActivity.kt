package fritz.com.example.marvel

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.firebase.analytics.FirebaseAnalytics
import com.google.firebase.analytics.ktx.analytics
import com.google.firebase.analytics.ktx.logEvent
import com.google.firebase.ktx.Firebase

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.marvel.analytics"
    private lateinit var analytics: FirebaseAnalytics

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Initialize Firebase Analytics
        analytics = Firebase.analytics
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    // Analytics initialized
                    android.util.Log.d("Analytics", "Firebase Analytics initialized")
                    result.success("MethodChannel OK")
                }
                
                "trackEvent" -> {
                    val eventName = call.argument<String>("eventName")
                    val parameters = call.argument<Map<String, Any>>("parameters")
                    
                    if (eventName != null) {
                        // Log only important events
                        if (shouldLogEvent(eventName)) {
                            android.util.Log.d("Analytics", "$eventName - ${parameters ?: emptyMap()}")
                        }
                        trackEvent(eventName, parameters ?: emptyMap())
                        result.success("Event '$eventName' processed successfully!")
                    } else {
                        android.util.Log.e("Analytics", "Event name is required")
                        result.error("INVALID_ARGUMENT", "Event name is required", null)
                    }
                }
                
                "setUserProperty" -> {
                    val name = call.argument<String>("name")
                    val value = call.argument<String>("value")
                    
                    if (name != null && value != null) {
                        analytics.setUserProperty(name, value)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Name and value are required", null)
                    }
                }
                
                "trackScreen" -> {
                    val screenName = call.argument<String>("screenName")
                    
                    if (screenName != null) {
                        android.util.Log.d("Analytics", "Tela: $screenName")
                        analytics.logEvent(FirebaseAnalytics.Event.SCREEN_VIEW) {
                            param(FirebaseAnalytics.Param.SCREEN_NAME, screenName)
                            param(FirebaseAnalytics.Param.SCREEN_CLASS, "Flutter")
                        }
                        result.success(null)
                    } else {
                        android.util.Log.e("Analytics", "Screen name is required")
                        result.error("INVALID_ARGUMENT", "Screen name is required", null)
                    }
                }
                
                "trackError" -> {
                    val error = call.argument<String>("error")
                    val stackTrace = call.argument<String>("stackTrace")
                    val fatal = call.argument<Boolean>("fatal") ?: false
                    
                    if (error != null) {
                        analytics.logEvent("app_exception") {
                            param("error_message", error)
                            if (stackTrace != null) {
                                param("stack_trace", stackTrace)
                            }
                            param("fatal", if (fatal) "true" else "false")
                        }
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Error message is required", null)
                    }
                }
                
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun trackEvent(eventName: String, parameters: Map<String, Any>) {
        analytics.logEvent(eventName) {
            parameters.forEach { (key, value) ->
                when (value) {
                    is String -> param(key, value)
                    is Int -> param(key, value.toLong())
                    is Long -> param(key, value)
                    is Double -> param(key, value)
                    is Boolean -> param(key, if (value) "true" else "false")
                    else -> param(key, value.toString())
                }
            }
        }
    }
    
    private fun shouldLogEvent(eventName: String): Boolean {
        val importantEvents = listOf(
            "page_load_time",
            "character_search_initiated", 
            "api_error",
            "character_view",
            "character_list_load"
        )
        return importantEvents.contains(eventName)
    }
}