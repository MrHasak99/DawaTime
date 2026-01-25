package com.mrhasak99.dawatime

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.mrhasak99.dawatime/play_integrity"

    override fun onCreate(savedInstanceState: Bundle?) {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestIntegrityToken" -> {
                    val cloudProjectNumber = call.argument<Long>("cloudProjectNumber")
                    val nonce = call.argument<String>("nonce")
                    
                    if (cloudProjectNumber == null) {
                        result.error("INVALID_ARGUMENT", "cloudProjectNumber is required", null)
                        return@setMethodCallHandler
                    }
                    
                    if (nonce == null || nonce.isEmpty()) {
                        result.error("INVALID_ARGUMENT", "nonce is required", null)
                        return@setMethodCallHandler
                    }
                    
                    requestIntegrityToken(cloudProjectNumber, nonce, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun requestIntegrityToken(cloudProjectNumber: Long, nonce: String, result: MethodChannel.Result) {
        try {
            val integrityManager = IntegrityManagerFactory.create(applicationContext)
            
            // Create integrity token request with nonce
            val integrityTokenRequest = IntegrityTokenRequest.builder()
                .setCloudProjectNumber(cloudProjectNumber)
                .setNonce(nonce)
                .build()
            
            // Request the integrity token
            integrityManager.requestIntegrityToken(integrityTokenRequest)
                .addOnSuccessListener { response ->
                    val token = response.token()
                    result.success(token)
                }
                .addOnFailureListener { exception ->
                    result.error("INTEGRITY_ERROR", exception.message, null)
                }
        } catch (e: Exception) {
            result.error("EXCEPTION", e.message, null)
        }
    }
}
